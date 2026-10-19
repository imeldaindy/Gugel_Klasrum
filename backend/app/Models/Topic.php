<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Topic extends Model
{
    protected $guarded = [];

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function toApi(): array
    {
        return ['id' => $this->id, 'name' => $this->name];
    }
}
