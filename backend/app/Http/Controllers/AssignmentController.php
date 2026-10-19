<?php

namespace App\Http\Controllers;

use App\Models\Assignment;
use App\Models\Submission;
use Illuminate\Http\Request;

class AssignmentController extends Controller
{
    private function find(Request $request, int $id): Assignment
    {
        $uid = $request->user()->id;
        $a = Assignment::with(['course', 'topic', 'attachments', 'questions'])->findOrFail($id);
        // pastikan user terdaftar di kelas tugas ini
        $request->user()->courses()->whereKey($a->course_id)->firstOrFail();
        // siswa hanya boleh membuka tugas yang ditujukan kepadanya
        abort_unless(Assignment::visibleTo($uid)->whereKey($a->id)->exists(), 404, 'Tugas tidak ditemukan');

        return $a;
    }

    /** Detail satu tugas. */
    public function show(Request $request, int $id)
    {
        $a = $this->find($request, $id);

        return response()->json(['data' => $a->toApi($request->user()->id)]);
    }

    /** Ubah tugas (hanya pengajar kelasnya). */
    public function update(Request $request, int $id)
    {
        $a = $this->find($request, $id);
        $this->requireTeacher($request, $a);

        $data = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'points' => 'nullable|integer|min:0|max:1000',
            'deadline' => 'nullable|date',
        ]);
        $a->update($data);

        return response()->json(['data' => $a->toApi($request->user()->id)]);
    }

    /** Hapus tugas (hanya pengajar kelasnya). */
    public function destroy(Request $request, int $id)
    {
        $a = $this->find($request, $id);
        $this->requireTeacher($request, $a);
        $a->delete();

        return response()->json(['message' => 'Tugas dihapus']);
    }

    private function requireTeacher(Request $request, Assignment $a): void
    {
        $isTeacher = $a->course()->where('teacher_id', $request->user()->id)->exists();
        abort_unless($isTeacher, 403, 'Hanya pengajar yang dapat melakukan ini');
    }

    /** Daftar tugas lintas kelas (layar "Daftar tugas"). */
    public function todo(Request $request)
    {
        $uid = $request->user()->id;
        $courseIds = $request->user()->courses()->pluck('courses.id');
        // yang perlu dikerjakan: bukan materi, dan bukan di kelas yang diajar sendiri
        $list = Assignment::whereIn('course_id', $courseIds)
            ->where('type', '!=', 'material')
            ->whereDoesntHave('course', fn ($c) => $c->where('teacher_id', $uid))
            ->visibleTo($uid)
            ->with(['course', 'topic', 'attachments', 'questions'])
            ->orderBy('id')
            ->get();

        return response()->json(['data' => $list->map(fn ($a) => $a->toApi($uid))->values()]);
    }

    /** Serahkan tugas / jawab pertanyaan / kerjakan kuis. */
    public function submit(Request $request, int $id)
    {
        $a = $this->find($request, $id);
        $uid = $request->user()->id;

        abort_if($a->course->teacher_id === $uid, 403, 'Pengajar tidak dapat menyerahkan tugas');
        abort_if($a->type === 'material', 422, 'Materi tidak perlu diserahkan');

        $values = ['status' => 'done', 'submitted_at' => now()];
        $attachments = [];

        if ($a->type === 'question') {
            $data = $request->validate(['answer' => 'required|string|max:5000']);
            if ($a->question_type === 'multiple_choice') {
                abort_unless(in_array($data['answer'], $a->choices ?? [], true), 422, 'Pilihan jawaban tidak valid');
            }
            $values['answer'] = $data['answer'];
        } elseif ($a->type === 'quiz') {
            $already = Submission::where('assignment_id', $a->id)->where('user_id', $uid)
                ->where('status', 'done')->exists();
            abort_if($already, 422, 'Kuis ini sudah Anda kerjakan');

            $data = $request->validate([
                'answers' => 'required|array',
                'answers.*' => 'nullable|integer|min:0',
            ]);

            $answers = [];
            $score = 0;
            foreach ($a->questions as $i => $q) {
                $pick = $data['answers'][$i] ?? null;
                $answers[] = $pick;
                if ($pick !== null && $q->correct_index !== null && (int) $pick === (int) $q->correct_index) {
                    $score += $q->points;
                }
            }
            $values['answers'] = $answers;
            $values['score'] = $score;
        } else {
            $data = $request->validate([
                'attachments' => 'nullable|array',
                'attachments.*.type' => 'required|in:drive,photo,scan,file,link,created',
                'attachments.*.name' => 'required|string|max:255',
                'attachments.*.url' => 'nullable|string|max:500',
            ]);
            $attachments = $data['attachments'] ?? [];
        }

        $sub = Submission::updateOrCreate(
            ['assignment_id' => $a->id, 'user_id' => $uid],
            $values
        );

        if ($a->type === 'assignment') {
            $sub->attachments()->delete();
            foreach ($attachments as $att) {
                $sub->attachments()->create([
                    'type' => $att['type'],
                    'name' => $att['name'],
                    'url' => $att['url'] ?? null,
                ]);
            }
        }

        return response()->json(['data' => $a->toApi($uid)]);
    }

    /** Batal serahkan (kuis tidak bisa dibatalkan). */
    public function unsubmit(Request $request, int $id)
    {
        $a = $this->find($request, $id);
        $uid = $request->user()->id;

        abort_if($a->type === 'quiz', 422, 'Kuis tidak dapat dibatalkan setelah dikerjakan');

        Submission::where('assignment_id', $a->id)->where('user_id', $uid)
            ->update(['status' => 'assigned', 'submitted_at' => null]);

        return response()->json(['data' => $a->toApi($uid)]);
    }

    /** Pekerjaan siswa untuk satu tugas (pengajar). */
    public function submissions(Request $request, int $id)
    {
        $a = $this->find($request, $id);
        $this->requireTeacher($request, $a);

        $students = $a->assign_all
            ? $a->course->students()->orderBy('users.name')->get()
            : $a->recipients()->orderBy('users.name')->get();

        $subs = Submission::with('attachments')->where('assignment_id', $a->id)->get()->keyBy('user_id');

        $rows = $students->map(function ($u) use ($subs) {
            $s = $subs->get($u->id);

            return [
                'user' => $u->toApi(),
                'status' => $s?->status === 'done' ? 'done' : 'assigned',
                'submitted_at' => $s?->submitted_at?->format('Y-m-d\TH:i:s'),
                'answer' => $s?->answer,
                'answers' => $s?->answers,
                'score' => $s?->score,
                'attachments' => $s ? $s->attachments->map(fn ($f) => [
                    'type' => $f->type, 'name' => $f->name, 'url' => $f->url,
                ])->values() : [],
            ];
        })->values();

        return response()->json(['data' => $rows]);
    }

    /** Beri nilai pekerjaan seorang siswa (pengajar). */
    public function grade(Request $request, int $id, int $userId)
    {
        $a = $this->find($request, $id);
        $this->requireTeacher($request, $a);

        $data = $request->validate(['score' => 'nullable|integer|min:0|max:1000']);

        $isStudent = $a->course->students()->where('users.id', $userId)->exists();
        abort_unless($isStudent, 404, 'Siswa tidak ditemukan di kelas ini');

        $sub = Submission::firstOrCreate(
            ['assignment_id' => $a->id, 'user_id' => $userId],
            ['status' => 'assigned']
        );
        $sub->update(['score' => $data['score'] ?? null]);

        return response()->json(['message' => 'Nilai disimpan', 'score' => $sub->score]);
    }
}
