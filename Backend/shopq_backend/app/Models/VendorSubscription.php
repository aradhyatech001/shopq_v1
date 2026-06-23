<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class VendorSubscription extends Model
{
    protected $table    = 'vendor_subscriptions';
    protected $fillable = [
        'vendor_id', 'plan_id', 'start_date', 'end_date',
        'status', 'payment_reference', 'payment_mode', 'amount_paid',
    ];

    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    public function plan()
    {
        return $this->belongsTo(SubscriptionPlan::class, 'plan_id');
    }

    public function isActive(): bool
    {
        return $this->status === 'active'
            && Carbon::parse($this->end_date)->isFuture();
    }

    public function daysRemaining(): int
    {
        if (!$this->isActive()) return 0;
        return (int) Carbon::now()->diffInDays(Carbon::parse($this->end_date));
    }
}
