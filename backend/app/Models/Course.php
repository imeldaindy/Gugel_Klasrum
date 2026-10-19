<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Course extends Model
{
    protected $guarded = [];

    public function teacher()
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function members()
    {
        return $this->belongsToMany(User::class, 'course_user')
            ->withPivot('role')
            ->withTimestamps();
    }

    public function students()
    {
        return $this->members()->wherePivot('role', 'student');
    }

    public function assignments()
    {
        return $this->hasMany(Assignment::class);
    }

    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    public const POST_POLICIES = [
        'students_post_and_comment',
        'students_comment_only',
        'teacher_only',
    ];

    public const NOTIFY_MODES = ['condensed', 'full', 'hidden'];

    protected function casts(): array
    {
        return ['invite_enabled' => 'boolean'];
    }

    /** Link undangan; parameter `cjc` berisi kode kelas. */
    public function inviteLink(): string
    {
        return url('/join').'?cjc='.$this->code;
    }

    /**
     * @param  string|null  $role  teacher | student. Jika null dipakai pivot
     *                             (saat diambil lewat $user->courses()).
     *
     * Kode & link undangan hanya dikirim ke pengajar.
     */
    public function toApi(?string $role = null): array
    {
        $role ??= $this->pivot?->role;
        $isTeacher = $role === 'teacher';

        $data = [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description ?? '',
            'section' => $this->section ?? '',
            'room' => $this->room ?? '',
            'subject' => $this->subject ?? '',
            'level' => $this->level ?? '',
            'teacher' => $this->teacher?->name ?? '',
            'role' => $role,
            'post_policy' => $this->post_policy,
            'notify_mode' => $this->notify_mode,
        ];

        if ($isTeacher) {
            $data['code'] = $this->code;
            $data['invite_link'] = $this->inviteLink();
            $data['invite_enabled'] = $this->invite_enabled;
        }

        return $data;
    }
}
