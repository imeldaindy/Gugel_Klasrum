<?php

namespace App\Http\Controllers;

use App\Models\Assignment;
use App\Models\Comment;
use App\Models\Post;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    /** Pastikan objek ada dan user terdaftar di kelasnya. Mengembalikan kelas. */
    private function courseOf(Request $request, string $type, int $id)
    {
        $courseId = $type === 'post'
            ? Post::findOrFail($id)->course_id
            : Assignment::findOrFail($id)->course_id;

        return $request->user()->courses()->whereKey($courseId)->firstOrFail();
    }

    /** type = post | assignment */
    public function index(Request $request, string $type, int $id)
    {
        $this->courseOf($request, $type, $id);

        $list = Comment::with('user')
            ->where('commentable_type', $type)
            ->where('commentable_id', $id)
            ->orderBy('created_at')
            ->get();

        return response()->json(['data' => $list->map->toApi()->values()]);
    }

    public function store(Request $request, string $type, int $id)
    {
        $course = $this->courseOf($request, $type, $id);
        $data = $request->validate(['content' => 'required|string']);

        if ($course->post_policy === 'teacher_only' && $course->teacher_id !== $request->user()->id) {
            return response()->json(['message' => 'Hanya pengajar yang dapat berkomentar di kelas ini'], 403);
        }

        $c = Comment::create([
            'user_id' => $request->user()->id,
            'commentable_type' => $type,
            'commentable_id' => $id,
            'content' => $data['content'],
        ]);

        return response()->json(['data' => $c->load('user')->toApi()], 201);
    }
}
