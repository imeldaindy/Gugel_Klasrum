<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Submission extends Model
{
    protected $guarded = [];

    protected function casts(): array
    {
        return ['submitted_at' => 'datetime', 'answers' => 'array'];
    }

    public function attachments()
    {
        return $this->hasMany(SubmissionAttachment::class);
    }
}
