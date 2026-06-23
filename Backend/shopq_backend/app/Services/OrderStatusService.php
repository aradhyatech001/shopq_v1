<?php

namespace App\Services;

use App\Models\Order;
use App\Models\User;
use App\Models\VendorOrder;
use App\Models\OrderStatusHistory;

/// Single source of truth for order status. Every vendor/admin/system mutation
/// of a sub-order goes through here so the parent's derived_status stays correct.
class OrderStatusService
{
    /// Apply a status to one vendor sub-order (guarded), stamp the timestamp,
    /// log history, then recompute the parent. Returns [ok, message].
    public function setVendorOrderStatus(
        VendorOrder $vo,
        string $to,
        string $actorType = 'system',
        ?int $actorId = null,
        ?string $note = null
    ): array {
        $to = strtolower(trim($to));
        if (!in_array($to, [...VendorOrder::FLOW, 'cancelled'], true)) {
            return [false, 'Invalid status'];
        }
        if (!$vo->canTransitionTo($to)) {
            return [false, "Cannot move from {$vo->status} to {$to}"];
        }

        $from = $vo->status;
        $vo->status = $to;

        // Stamp the matching timestamp column.
        $stamp = [
            'confirmed'        => 'confirmed_at',
            'packed'           => 'packed_at',
            'assigned'         => 'assigned_at',
            'picked_up'        => 'picked_up_at',
            'out_for_delivery' => 'out_for_delivery_at',
            'delivered'        => 'delivered_at',
            'cancelled'        => 'cancelled_at',
        ][$to] ?? null;
        if ($stamp) $vo->{$stamp} = now();

        // Stamp the final earning on delivery using the FROZEN settlement
        // figures (goods_subtotal - coupon_share = net chargeable goods value).
        // Previously used items_subtotal which ignored the coupon share and
        // overstated vendor_earning on every coupon order.
        if ($to === 'delivered') {
            $rate    = (float) $vo->commission_rate;
            $netGoods = max(0, (int) $vo->goods_subtotal - (int) $vo->coupon_share);
            $vo->commission_amount = (int) round($netGoods * $rate / 100);
            $vo->vendor_earning    = $netGoods - $vo->commission_amount;
        }
        $vo->save();

        OrderStatusHistory::create([
            'parent_order_id' => $vo->parent_order_id,
            'vendor_order_id' => $vo->id,
            'actor_type'      => $actorType,
            'actor_id'        => $actorId,
            'from_status'     => $from,
            'to_status'       => $to,
            'note'            => $note,
            'created_at'      => now(),
        ]);

        $this->recompute($vo->parent_order_id);

        // Notify the customer via FCM (best-effort — failure doesn't abort the request).
        $parent = Order::find($vo->parent_order_id);
        if ($parent && $parent->user_id) {
            $user = User::find($parent->user_id);
            if ($user && $user->fcm_token) {
                $label = ucwords(str_replace('_', ' ', $to));
                app(FcmService::class)->send(
                    $user->fcm_token,
                    'Order Update',
                    "Your order #{$parent->id} is now: {$label}.",
                    ['order_id' => (string) $parent->id, 'status' => $to]
                );
            }
        }

        return [true, 'Status updated'];
    }

    /// Recompute and persist the parent order's derived status from its subs.
    public function recompute(int $parentOrderId): string
    {
        $statuses = VendorOrder::where('parent_order_id', $parentOrderId)
            ->pluck('status')->map(fn($s) => strtolower($s))->all();

        $derived = $this->derive($statuses);

        Order::where('id', $parentOrderId)->update([
            'derived_status' => $derived,
            'status'         => $derived, // keep legacy column in sync for old screens
        ]);
        return $derived;
    }

    /// Pure status-derivation rule (see design table).
    public function derive(array $statuses): string
    {
        if (empty($statuses)) return 'pending';

        $total     = count($statuses);
        $count     = fn($s) => count(array_filter($statuses, fn($x) => $x === $s));
        $delivered = $count('delivered');
        $cancelled = $count('cancelled');
        $shipped   = $count('out_for_delivery') + $count('picked_up');
        $pending   = $count('pending');

        if ($cancelled === $total) return 'cancelled';
        if ($delivered === $total) return 'delivered';
        if ($pending === $total) return 'pending';

        // active = not cancelled
        $active = $total - $cancelled;
        if ($delivered > 0 && ($delivered + $cancelled) === $total) return 'delivered';
        if ($delivered > 0) return 'partially_delivered';
        if ($shipped > 0 && ($shipped + $cancelled) === $total) return 'out_for_delivery';
        if ($shipped > 0) return 'partially_shipped';
        if ($cancelled > 0 && $active > 0) return 'partially_cancelled';
        return 'processing';
    }
}
