<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;

/**
 * A single in-app notification (inbox item) for a User / Vendor / DeliveryBoy.
 */
class AppNotification extends Model
{
    protected $table = 'app_notifications';

    protected $fillable = [
        'notifiable_type',
        'notifiable_id',
        'campaign_id',
        'type',
        'title',
        'body',
        'image',
        'data',
        'read_at',
        'clicked_at',
        'archived_at',
    ];

    protected $casts = [
        'data'        => 'array',
        'read_at'     => 'datetime',
        'clicked_at'  => 'datetime',
        'archived_at' => 'datetime',
    ];

    public function notifiable(): MorphTo
    {
        return $this->morphTo();
    }

    public function scopeUnread($query)
    {
        return $query->whereNull('read_at');
    }

    public function scopeActive($query)
    {
        return $query->whereNull('archived_at');
    }
}
