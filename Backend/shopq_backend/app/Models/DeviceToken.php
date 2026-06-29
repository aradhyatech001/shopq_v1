<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;

/**
 * A single device's FCM registration token, owned by a User / Vendor /
 * DeliveryBoy (polymorphic). One account may have many of these.
 */
class DeviceToken extends Model
{
    protected $fillable = [
        'tokenable_type',
        'tokenable_id',
        'token',
        'platform',
        'app_version',
        'language',
        'is_valid',
        'last_seen_at',
    ];

    protected $casts = [
        'is_valid'     => 'boolean',
        'last_seen_at' => 'datetime',
    ];

    public function tokenable(): MorphTo
    {
        return $this->morphTo();
    }
}
