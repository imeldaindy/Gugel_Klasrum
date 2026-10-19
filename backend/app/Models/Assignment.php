<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Assignment extends Model
{
    protected $guarded = [];

    public const TYPES = ['assignment', 'quiz', 'question', 'material'];

    protected function casts(): array
    {
        return [
            'deadline' => 'datetime',
            'assign_all' => 'boolean',
            'choices' => 'array',
        ];
    }

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function topic()
    {
        return $this->belongsTo(Topic::class);
    }

    public function submissions()
    {
        return $this->hasMany(Submission::class);
    }

    public function recipients()
    {
        return $this->belongsToMany(User::class, 'assignment_recipients');
    }

    public function attachments()
    {
        return $this->hasMany(AssignmentAttachment::class);
    }

    public function questions()
    {
        return $this->hasMany(QuizQuestion::class)->orderBy('position');
    }

    /** Pengajar kelas melihat semua; siswa hanya yang ditujukan kepadanya. */
    public function scopeVisibleTo($query, int $userId)
    {
        $query->where(function ($q) use ($userId) {
            $q->where('assign_all', true)
                ->orWhereHas('recipients', fn ($r) => $r->where('users.id', $userId))
                ->orWhereHas('course', fn ($c) => $c->where('teacher_id', $userId));
        });
    }

    /** done | missing | assigned */
    public function statusFor(int $userId): string
    {
        if ($this->type === 'material') {
            return 'assigned';
        }
        $sub = $this->submissions()->where('user_id', $userId)->first();
        if ($sub && $sub->status === 'done') {
            return 'done';
        }
        if ($this->deadline && $this->deadline->isPast()) {
            return 'missing';
        }

        return 'assigned';
    }

    public function toApi(int $userId): array
    {
        $isTeacher = $this->course?->teacher_id === $userId;

        $out = [
            'id' => $this->id,
            'course_id' => $this->course_id,
            'type' => $this->type,
            'title' => $this->title,
            'description' => $this->description ?? '',
            'points' => $this->points,
            'deadline' => $this->deadline?->format('Y-m-d\TH:i:s'),
            'status' => $this->statusFor($userId),
            'topic_id' => $this->topic_id,
            'topic' => $this->topic?->name,
            'assign_all' => $this->assign_all,
            'question_type' => $this->question_type,
            'choices' => $this->choices ?? [],
            'attachments' => $this->attachments->map(fn ($a) => [
                'type' => $a->type, 'name' => $a->name, 'url' => $a->url,
            ])->values(),
            'questions' => $this->type === 'quiz'
                ? $this->questions->map(function ($q) use ($isTeacher) {
                    $row = [
                        'id' => $q->id,
                        'text' => $q->text,
                        'options' => $q->options,
                        'points' => $q->points,
                    ];
                    // kunci jawaban hanya untuk pengajar
                    if ($isTeacher) {
                        $row['correct_index'] = $q->correct_index;
                    }

                    return $row;
                })->values()
                : [],
        ];

        if ($isTeacher) {
            $out['turned_in'] = $this->submissions()->where('status', 'done')->count();
            $out['total_students'] = $this->assign_all
                ? $this->course->students()->count()
                : $this->recipients()->count();
        } else {
            $sub = $this->submissions()->where('user_id', $userId)->first();
            $out['my_answer'] = $sub?->answer;
            $out['my_answers'] = $sub?->answers;
            $out['my_score'] = $sub?->score;
        }

        return $out;
    }
}
