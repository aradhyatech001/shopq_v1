<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use App\Services\SettlementService;

/**
 * One-time backfill: freeze settlement values on orders placed BEFORE the
 * freeze-once model existed, so the vendor / delivery / admin apps show the
 * correct collect amounts for historical orders (e.g. Order #8) instead of 0.
 *
 * Recomputes from the data already on each order using the same allocation the
 * checkout now uses. Only touches orders whose vendor_orders are still unfrozen.
 */
return new class extends Migration
{
    public function up(): void
    {
        $orders = DB::table('orders')->get();

        foreach ($orders as $order) {
            $vendorOrders = DB::table('vendor_orders')
                ->where('parent_order_id', $order->id)->get();
            if ($vendorOrders->isEmpty()) continue;

            // Skip if already frozen (any sub-order carries a non-zero collect).
            if ($vendorOrders->contains(fn($vo) => (int) $vo->collect_amount > 0)) continue;

            // Per vendor_order selling subtotal + order-wide MRP subtotal.
            $vendorSubtotals = [];   // vendor_order_id => selling subtotal
            $sellingTotal    = 0.0;
            $mrpTotal        = 0.0;
            foreach ($vendorOrders as $vo) {
                $rows = DB::select("
                    SELECT oi.quantity,
                           COALESCE(pv.selling_price, pv.price, oi.price, 0) AS selling,
                           COALESCE(pv.price, pv.selling_price, oi.price, 0) AS mrp
                    FROM order_items oi
                    LEFT JOIN product_variants pv ON oi.variant_id = pv.id
                    WHERE oi.vendor_order_id = ?
                ", [$vo->id]);
                $sub = 0.0;
                foreach ($rows as $r) {
                    $qty = (int) $r->quantity;
                    $sub      += (float) $r->selling * $qty;
                    $mrpTotal += (float) $r->mrp * $qty;
                }
                $sellingTotal += $sub;
                $vendorSubtotals[$vo->id] = $sub;
            }

            $mrpSavings     = max(0, $mrpTotal - $sellingTotal);
            $couponDiscount = max(0, (float) $order->discount_amount - $mrpSavings);
            $delivery       = (float) $order->delivery_charge;
            $handling       = (float) $order->handling_charge;

            $settlement = SettlementService::freeze($vendorSubtotals, $couponDiscount, $delivery, $handling);

            // Persist per vendor_order shares.
            foreach ($vendorOrders as $vo) {
                $s = $settlement['vendors'][$vo->id] ?? null;
                if (!$s) continue;
                $netGoods   = $s['goods_subtotal'] - $s['coupon_share'];
                $rate       = (float) ($vo->commission_rate ?? 0);
                $commission = (int) round($netGoods * $rate / 100);
                DB::table('vendor_orders')->where('id', $vo->id)->update([
                    'goods_subtotal'    => $s['goods_subtotal'],
                    'coupon_share'      => $s['coupon_share'],
                    'delivery_share'    => $s['delivery_share'],
                    'handling_share'    => $s['handling_share'],
                    'collect_amount'    => $s['collect_amount'],
                    'commission_amount' => $commission,
                    'vendor_earning'    => $netGoods - $commission,
                ]);
            }

            // Freeze the coupon snapshot on the parent (best-effort lookup).
            $couponTitle = null; $couponType = null; $couponValue = 0;
            if (!empty($order->coupon_code)) {
                $c = DB::table('coupon')->where('code_name', $order->coupon_code)->first();
                if ($c) { $couponTitle = $c->title; $couponType = 'percent'; $couponValue = (float) $c->discount; }
            }

            DB::table('orders')->where('id', $order->id)->update([
                'coupon_title'      => $couponTitle,
                'coupon_type'       => $couponType,
                'coupon_value'      => $couponValue,
                'coupon_discount'   => $settlement['coupon_discount'],
                'settlement_frozen' => true,
            ]);
        }
    }

    public function down(): void
    {
        // Data backfill — nothing to reverse.
    }
};
