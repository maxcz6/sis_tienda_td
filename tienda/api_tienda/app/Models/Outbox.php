<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Outbox extends Model
{
    protected $table = 'outbox';

    protected $fillable = [
        'method', 'url', 'payload', 'headers', 'attempts', 'last_error', 'status', 'last_attempt_at'
    ];

    protected $casts = [
        'payload' => 'array',
        'headers' => 'array',
        'last_attempt_at' => 'datetime',
    ];
}
