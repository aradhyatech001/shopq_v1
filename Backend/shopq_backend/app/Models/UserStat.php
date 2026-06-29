<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Denormalized customer stats for fast segmentation. Keyed by user_id.
 */
class UserStat extends Model
{
    protected $table = 'user_stats';
    protected $primaryKey = 'user_id';
    public $incrementing = false;

    protected $guarded = [];

    protected $casts = [
        'registered_at'  => 'datetime',
        'last_order_at'  => 'datetime',
        'last_active_at' => 'datetime',
        'has_pending'    => 'boolean',
        'has_cancelled'  => 'boolean',
        'has_completed'  => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
