<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    protected $guarded = [];

    protected function casts(): array
    {
        return ['is_assignment' => 'boolean'];
    }

    public function author()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'author_name' => $this->author?->name ?? '',
            'content' => $this->content,
            // tanpa "Z" supaya Flutter membacanya sebagai waktu lokal
            'created_at' => $this->created_at?->format('Y-m-d\TH:i:s'),
            'is_assignment' => $this->is_assignment,
        ];
    }
}
