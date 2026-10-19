<?php

namespace App\Http\Controllers;

use App\Models\Assignment;
use App\Models\Course;
use App\Models\Post;
use App\Models\Topic;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Tugas kelas: tugas, kuis, pertanyaan, materi, dan topik. */
class ClassworkController extends Controller
{
    private const LABELS = [
        'assignment' => 'Tugas',
        'quiz' => 'Kuis',
        'question' => 'Pertanyaan',
        'material' => 'Materi',
    ];

    private function enrolled(Request $request, int $id): Course
    {
        return $request->user()->courses()->whereKey($id)->firstOrFail();
    }

    private function owned(Request $request, int $id): Course
    {
        $course = $this->enrolled($request, $id);
        abort_unless($course->teacher_id === $request->user()->id, 403, 'Hanya pengajar yang dapat melakukan ini');

        return $course;
    }

    private function relations(): array
    {
        return ['course', 'topic', 'attachments', 'questions'];
    }

    /** Daftar tugas kelas (siswa hanya melihat yang ditujukan kepadanya). */
    public function index(Request $request, int $id)
    {
        $course = $this->enrolled($request, $id);
        $uid = $request->user()->id;

        $list = $course->assignments()
            ->visibleTo($uid)
            ->with($this->relations())
            ->orderBy('id')
            ->get();

        return response()->json(['data' => $list->map(fn ($a) => $a->toApi($uid))->values()]);
    }

    /** Buat tugas / kuis / pertanyaan / materi (hanya pengajar). */
    public function store(Request $request, int $id)
    {
        $course = $this->owned($request, $id);

        $data = $request->validate([
            'type' => 'required|in:assignment,quiz,question,material',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'points' => 'nullable|integer|min:0|max:1000',
            'deadline' => 'nullable|date',
            'topic_id' => 'nullable|integer',
            'student_ids' => 'nullable|array',
            'student_ids.*' => 'integer',
            'attachments' => 'nullable|array',
            'attachments.*.type' => 'required|in:drive,photo,scan,file,link,created',
            'attachments.*.name' => 'required|string|max:255',
            'attachments.*.url' => 'nullable|string|max:500',
            'question_type' => 'nullable|in:short_answer,multiple_choice',
            'choices' => 'nullable|array',
            'choices.*' => 'required|string|max:255',
            'questions' => 'nullable|array',
            'questions.*.text' => 'required|string',
            'questions.*.options' => 'required|array|min:2',
            'questions.*.options.*' => 'required|string|max:255',
            'questions.*.correct_index' => 'nullable|integer|min:0',
            'questions.*.points' => 'nullable|integer|min:0|max:1000',
        ]);

        $type = $data['type'];

        if ($type === 'question') {
            $data['question_type'] = $data['question_type'] ?? 'short_answer';
            if ($data['question_type'] === 'multiple_choice') {
                abort_if(count($data['choices'] ?? []) < 2, 422, 'Pertanyaan pilihan ganda minimal punya 2 pilihan');
            } else {
                $data['choices'] = null;
            }
        } else {
            $data['question_type'] = null;
            $data['choices'] = null;
        }

        if ($type === 'quiz') {
            abort_if(empty($data['questions']), 422, 'Kuis minimal punya 1 soal');
            foreach ($data['questions'] as $i => $q) {
                $ci = $q['correct_index'] ?? null;
                abort_if($ci !== null && $ci >= count($q['options']), 422, 'Kunci jawaban soal '.($i + 1).' tidak valid');
            }
        }

        if ($type === 'material') {
            $data['points'] = null;
            $data['deadline'] = null;
        }

        if (! empty($data['topic_id'])) {
            abort_unless(
                Topic::where('course_id', $course->id)->whereKey($data['topic_id'])->exists(),
                422,
                'Topik tidak ditemukan di kelas ini'
            );
        }

        $assignment = $this->build($course, $request->user()->id, $data);

        return response()->json(['data' => $assignment->toApi($request->user()->id)], 201);
    }

    /** Gunakan kembali postingan dari kelas lain milik pengajar yang sama. */
    public function reuse(Request $request, int $id)
    {
        $course = $this->owned($request, $id);
        $uid = $request->user()->id;
        $input = $request->validate(['assignment_id' => 'required|integer']);

        $src = Assignment::with(['course', 'topic', 'attachments', 'questions'])
            ->findOrFail($input['assignment_id']);
        abort_unless($src->course->teacher_id === $uid, 403, 'Anda bukan pengajar kelas sumber');

        // topik: cari / buat dengan nama yang sama di kelas tujuan
        $topicId = null;
        if ($src->topic) {
            $topicId = Topic::firstOrCreate(['course_id' => $course->id, 'name' => $src->topic->name])->id;
        }

        $data = [
            'type' => $src->type,
            'title' => $src->title,
            'description' => $src->description,
            'points' => $src->points,
            'deadline' => null,
            'topic_id' => $topicId,
            'question_type' => $src->question_type,
            'choices' => $src->choices,
            'attachments' => $src->attachments->map(fn ($a) => [
                'type' => $a->type, 'name' => $a->name, 'url' => $a->url,
            ])->all(),
            'questions' => $src->questions->map(fn ($q) => [
                'text' => $q->text,
                'options' => $q->options,
                'correct_index' => $q->correct_index,
                'points' => $q->points,
            ])->all(),
        ];

        $assignment = $this->build($course, $uid, $data);

        return response()->json(['data' => $assignment->toApi($uid)], 201);
    }

    /** Simpan item + relasinya, lalu buat pengumuman di forum & notifikasi. */
    private function build(Course $course, int $uid, array $data): Assignment
    {
        $studentIds = $course->students()->pluck('users.id')->all();
        $picked = array_values(array_intersect($studentIds, $data['student_ids'] ?? []));
        $assignAll = empty($picked);
        $recipients = $assignAll ? $studentIds : $picked;

        return DB::transaction(function () use ($course, $uid, $data, $assignAll, $picked, $recipients) {
            $questions = $data['questions'] ?? [];
            $points = $data['points'] ?? null;
            if (($data['type'] ?? '') === 'quiz') {
                $points = collect($questions)->sum(fn ($q) => $q['points'] ?? 1);
            }

            $assignment = Assignment::create([
                'course_id' => $course->id,
                'type' => $data['type'],
                'title' => $data['title'],
                'description' => $data['description'] ?? null,
                'points' => $points,
                'deadline' => $data['deadline'] ?? null,
                'topic_id' => $data['topic_id'] ?? null,
                'assign_all' => $assignAll,
                'question_type' => $data['question_type'] ?? null,
                'choices' => $data['choices'] ?? null,
            ]);

            if (! $assignAll) {
                $assignment->recipients()->attach($picked);
            }

            foreach ($data['attachments'] ?? [] as $att) {
                $assignment->attachments()->create([
                    'type' => $att['type'],
                    'name' => $att['name'],
                    'url' => $att['url'] ?? null,
                ]);
            }

            foreach (array_values($questions) as $i => $q) {
                $assignment->questions()->create([
                    'text' => $q['text'],
                    'options' => array_values($q['options']),
                    'correct_index' => $q['correct_index'] ?? null,
                    'points' => $q['points'] ?? 1,
                    'position' => $i,
                ]);
            }

            $label = self::LABELS[$assignment->type];

            Post::create([
                'course_id' => $course->id,
                'user_id' => $uid,
                'content' => $assignment->title, // kartu forum mencocokkan lewat judul
                'is_assignment' => true,
            ]);

            $now = now();
            if ($recipients) {
                DB::table('notifications')->insert(array_map(fn ($sid) => [
                    'user_id' => $sid,
                    'course_id' => $course->id,
                    'title' => $course->name,
                    'body' => $label.' baru: '.$assignment->title,
                    'created_at' => $now,
                    'updated_at' => $now,
                ], $recipients));
            }

            return $assignment->load($this->relations());
        });
    }

    // ---------- Topik ----------

    public function topics(Request $request, int $id)
    {
        $course = $this->enrolled($request, $id);

        return response()->json([
            'data' => Topic::where('course_id', $course->id)->orderBy('id')->get()->map->toApi()->values(),
        ]);
    }

    public function storeTopic(Request $request, int $id)
    {
        $course = $this->owned($request, $id);
        $data = $request->validate(['name' => 'required|string|max:100']);
        $name = trim($data['name']);

        abort_if(
            Topic::where('course_id', $course->id)->where('name', $name)->exists(),
            422,
            'Topik dengan nama itu sudah ada'
        );

        $topic = Topic::create(['course_id' => $course->id, 'name' => $name]);

        return response()->json(['data' => $topic->toApi()], 201);
    }

    public function destroyTopic(Request $request, int $id, int $topicId)
    {
        $course = $this->owned($request, $id);
        Topic::where('course_id', $course->id)->whereKey($topicId)->firstOrFail()->delete();

        return response()->json(['message' => 'Topik dihapus']);
    }
}
