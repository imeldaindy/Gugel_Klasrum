<?php

namespace App\Http\Controllers;

use App\Models\Assignment;
use App\Models\Course;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class CourseController extends Controller
{
    /** Ambil kelas hanya jika user terdaftar di dalamnya (pivot ikut terbawa). */
    private function enrolled(Request $request, int $id): Course
    {
        return $request->user()->courses()->whereKey($id)->firstOrFail();
    }

    /** Ambil kelas hanya jika user adalah pengajarnya. */
    private function owned(Request $request, int $id): Course
    {
        $course = $this->enrolled($request, $id);
        abort_unless($course->teacher_id === $request->user()->id, 403, 'Hanya pengajar yang dapat melakukan ini');

        return $course;
    }

    private function newCode(): string
    {
        do {
            $code = Str::lower(Str::random(8));
        } while (Course::where('code', $code)->exists());

        return $code;
    }

    /** Terima kode biasa atau link undangan (…?cjc=kode). */
    private function extractCode(string $input): string
    {
        $input = trim($input);
        $query = parse_url($input, PHP_URL_QUERY);
        if ($query) {
            parse_str($query, $params);
            if (!empty($params['cjc'])) {
                return Str::lower(trim((string) $params['cjc']));
            }
        }

        return Str::lower($input);
    }

    public function index(Request $request)
    {
        $courses = $request->user()->courses()->with('teacher')->orderBy('courses.id')->get();

        return response()->json(['data' => $courses->map->toApi()->values()]);
    }

    public function show(Request $request, int $id)
    {
        $course = $this->enrolled($request, $id)->load('teacher');

        return response()->json(['data' => $course->toApi()]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'section' => 'nullable|string|max:255',
            'room' => 'nullable|string|max:255',
            'subject' => 'nullable|string|max:255',
            'level' => 'nullable|string|max:255',
        ]);

        $course = Course::create($data + [
            'code' => $this->newCode(),
            'teacher_id' => $request->user()->id,
        ]);
        $course->members()->attach($request->user()->id, ['role' => 'teacher']);

        return response()->json(['data' => $course->load('teacher')->toApi('teacher')], 201);
    }

    /** Setelan kelas (hanya pengajar). */
    public function update(Request $request, int $id)
    {
        $course = $this->owned($request, $id);

        $data = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'section' => 'nullable|string|max:255',
            'room' => 'nullable|string|max:255',
            'subject' => 'nullable|string|max:255',
            'level' => 'nullable|string|max:255',
            'invite_enabled' => 'sometimes|boolean',
            'post_policy' => ['sometimes', Rule::in(Course::POST_POLICIES)],
            'notify_mode' => ['sometimes', Rule::in(Course::NOTIFY_MODES)],
        ]);

        $course->update($data);

        return response()->json(['data' => $course->load('teacher')->toApi('teacher')]);
    }

    /** Buat kode kelas baru; kode & link lama langsung tidak berlaku. */
    public function resetCode(Request $request, int $id)
    {
        $course = $this->owned($request, $id);
        $course->update(['code' => $this->newCode()]);

        return response()->json(['data' => $course->load('teacher')->toApi('teacher')]);
    }

    /** Gabung lewat kode atau link undangan. */
    public function join(Request $request)
    {
        $data = $request->validate(['code' => 'required|string|max:500']);
        $code = $this->extractCode($data['code']);

        if (!preg_match('/^[a-z0-9]{5,8}$/', $code)) {
            return response()->json(['message' => 'Kode kelas tidak valid. Gunakan 5-8 huruf atau angka.'], 422);
        }

        $course = Course::where('code', $code)->first();
        if (!$course) {
            return response()->json(['message' => 'Kelas tidak ditemukan. Periksa kembali kode kelas.'], 404);
        }
        if (!$course->invite_enabled) {
            return response()->json(['message' => 'Undangan untuk kelas ini sedang dinonaktifkan oleh pengajar.'], 403);
        }

        $user = $request->user();
        if ($course->teacher_id === $user->id) {
            return response()->json(['message' => 'Anda adalah pengajar di kelas ini.'], 409);
        }
        if ($course->members()->whereKey($user->id)->exists()) {
            return response()->json(['message' => 'Anda sudah bergabung di kelas ini.'], 409);
        }

        $course->members()->attach($user->id, ['role' => 'student']);

        return response()->json(['data' => $course->load('teacher')->toApi('student')]);
    }

    /** Keluar dari kelas (pengajar tidak bisa keluar). */
    public function leave(Request $request, int $id)
    {
        $course = $this->enrolled($request, $id);
        abort_if($course->teacher_id === $request->user()->id, 403, 'Pengajar tidak dapat keluar dari kelasnya sendiri');

        $course->members()->detach($request->user()->id);

        return response()->json(['message' => 'Anda telah keluar dari kelas']);
    }

    public function posts(Request $request, int $id)
    {
        $course = $this->enrolled($request, $id);
        $posts = $course->posts()->with('author')->orderByDesc('created_at')->get();

        return response()->json(['data' => $posts->map->toApi()->values()]);
    }

    public function storePost(Request $request, int $id)
    {
        $course = $this->enrolled($request, $id);
        $data = $request->validate(['content' => 'required|string']);

        $isTeacher = $course->teacher_id === $request->user()->id;
        if (!$isTeacher && $course->post_policy !== 'students_post_and_comment') {
            return response()->json(['message' => 'Hanya pengajar yang dapat memposting di forum ini'], 403);
        }

        $post = Post::create([
            'course_id' => $course->id,
            'user_id' => $request->user()->id,
            'content' => $data['content'],
            'is_assignment' => false,
        ]);

        return response()->json(['data' => $post->load('author')->toApi()], 201);
    }

    public function assignments(Request $request, int $id)
    {
        $course = $this->enrolled($request, $id);
        $uid = $request->user()->id;
        $list = $course->assignments()->orderBy('id')->get();

        return response()->json(['data' => $list->map(fn ($a) => $a->toApi($uid))->values()]);
    }

    /** Buat tugas (hanya pengajar) + pengumuman otomatis di forum. */
    public function storeAssignment(Request $request, int $id)
    {
        $course = $this->owned($request, $id);

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'points' => 'nullable|integer|min:0|max:1000',
            'deadline' => 'nullable|date',
        ]);

        $assignment = Assignment::create($data + ['course_id' => $course->id]);

        Post::create([
            'course_id' => $course->id,
            'user_id' => $request->user()->id,
            'content' => $assignment->title,
            'is_assignment' => true,
        ]);

        return response()->json(['data' => $assignment->toApi($request->user()->id)], 201);
    }

    public function people(Request $request, int $id)
    {
        $course = $this->enrolled($request, $id);

        return response()->json([
            'teacher' => $course->teacher?->toApi(),
            'data' => $course->students()->orderBy('users.name')->get()->map->toApi()->values(),
        ]);
    }
}
