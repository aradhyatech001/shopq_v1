<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * An admin notification campaign.
 */
class NotificationCampaign extends Model
{
    protected $guarded = [];

    protected $casts = [
        'data'         => 'array',
        'criteria'     => 'array',
        'scheduled_at' => 'datetime',
        'next_run_at'  => 'datetime',
        'expiry_at'    => 'datetime',
    ];

    public const STATUS_DRAFT     = 'draft';
    public const STATUS_SCHEDULED = 'scheduled';
    public const STATUS_SENDING   = 'sending';
    public const STATUS_SENT      = 'sent';
    public const STATUS_CANCELLED = 'cancelled';
    public const STATUS_FAILED    = 'failed';
}
