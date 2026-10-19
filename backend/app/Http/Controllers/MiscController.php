<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MiscController extends Controller
{
    public function notifications(Request $request)
    {
        $rows = DB::table('notifications')
            ->where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->get(['id', 'course_id', 'title', 'body', 'read_at', 'created_at']);

        return response()->json(['data' => $rows]);
    }

    /** Tandai satu notifikasi sudah dibaca. */
    public function markRead(Request $request, int $id)
    {
        $updated = DB::table('notifications')
            ->where('id', $id)
            ->where('user_id', $request->user()->id)
            ->update(['read_at' => now(), 'updated_at' => now()]);

        abort_unless($updated, 404, 'Notifikasi tidak ditemukan');

        return response()->json(['message' => 'Ditandai sudah dibaca']);
    }

    public function feedback(Request $request)
    {
        $data = $request->validate([
            'message' => 'required|string',
            'include_screenshot' => 'nullable|boolean',
            'include_system_info' => 'nullable|boolean',
        ]);

        DB::table('feedback')->insert([
            'user_id' => $request->user()->id,
            'message' => $data['message'],
            'include_screenshot' => $data['include_screenshot'] ?? false,
            'include_system_info' => $data['include_system_info'] ?? false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['message' => 'Terima kasih atas masukan Anda'], 201);
    }
}
