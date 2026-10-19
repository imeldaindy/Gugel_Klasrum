<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    protected $guarded = [];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'author' => $this->user?->name ?? '',
            'content' => $this->content,
            'created_at' => $this->created_at?->format('Y-m-d\TH:i:s'),
        ];
    }
}
