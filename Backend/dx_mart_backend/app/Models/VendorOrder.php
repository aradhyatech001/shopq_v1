<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VendorOrder extends Model
{
    protected $table = 'vendor_orders';

    protected $fillable = [
        'parent_order_id', 'vendor_id', 'status', 'items_subtotal',
        'commission_rate', 'commission_amount', 'vendor_earning',
        'delivery_boy_id', 'tracking_number', 'courier_name', 'cancel_reason',
        'payout_id', 'confirmed_at', 'packed_at', 'assigned_at', 'picked_up_at',
        'out_for_delivery_at', 'delivered_at', 'cancelled_at',
    ];

    // Vendor-managed delivery flow. cancelled is reachable from any non-final state.
    // assigned → picked_up (rider) → out_for_delivery (rider) → delivered (rider).
    public const FLOW = ['pending', 'confirmed', 'packed', 'assigned', 'picked_up', 'out_for_delivery', 'delivered'];

    public function parent()
    {
        return $this->belongsTo(Order::class, 'parent_order_id');
    }

    public function vendor()
    {
        return $this->belongsTo(Vendor::class, 'vendor_id');
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class, 'vendor_order_id');
    }

    /// Whether `$to` is a legal next status from the current one.
    public function canTransitionTo(string $to): bool
    {
        $from = $this->status;
        if ($from === $to) return true;
        if ($to === 'cancelled') return $from !== 'delivered' && $from !== 'cancelled';
        if ($from === 'cancelled' || $from === 'delivered') return false;
        $fi = array_search($from, self::FLOW, true);
        $ti = array_search($to, self::FLOW, true);
        return $fi !== false && $ti !== false && $ti >= $fi; // forward only
    }
}
