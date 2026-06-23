<?php

namespace App\Services;

/**
 * Freeze-once settlement engine.
 *
 * Splits a customer grand total across vendor orders so that:
 *   - only whole-rupee integers are used (no decimal settlement),
 *   - the per-vendor collect amounts ALWAYS sum back to the grand total,
 *   - each financial component (coupon / delivery / handling) is allocated by
 *     each vendor's contribution to the order value.
 *
 * The allocation uses the Largest-Remainder Method (Hamilton's method): give
 * every vendor the floor of its ideal share, then hand out the leftover rupees
 * one at a time to the vendors with the largest fractional remainders. This is
 * the standard apportionment that keeps integer parts summing EXACTLY to the
 * pool — naive per-vendor rounding does not.
 *
 * Pure functions only: nothing here reads or writes the database. Callers pass
 * frozen inputs and persist the returned numbers at order-creation time.
 */
class SettlementService
{
    /**
     * Allocate an integer $pool across keys, weighted by $weights, returning an
     * integer share per key whose sum is EXACTLY $pool (when $pool >= 0).
     *
     * @param  int                 $pool     whole-rupee amount to distribute (can be 0)
     * @param  array<int|string,float> $weights  key => weight (e.g. vendor_id => subtotal)
     * @return array<int|string,int>  key => integer share
     */
    public static function allocate(int $pool, array $weights): array
    {
        $keys = array_keys($weights);
        if (empty($keys)) return [];

        // Degenerate: nothing to weight by → spread as evenly as possible.
        $totalWeight = array_sum($weights);
        if ($totalWeight <= 0) {
            $shares = array_fill_keys($keys, intdiv($pool, count($keys)));
            $rem = $pool - array_sum($shares);
            foreach ($keys as $k) { if ($rem <= 0) break; $shares[$k]++; $rem--; }
            return $shares;
        }

        // Ideal (fractional) share + floor for each key.
        $shares     = [];
        $remainders = [];
        foreach ($weights as $k => $w) {
            $ideal        = $pool * ($w / $totalWeight);
            $floor        = (int) floor($ideal);
            $shares[$k]   = $floor;
            $remainders[$k] = $ideal - $floor;
        }

        // Distribute the leftover rupees to the largest remainders first.
        $leftover = $pool - array_sum($shares);
        if ($leftover > 0) {
            // Sort keys by remainder desc; tie-break by larger weight, then key
            // order, so the result is deterministic.
            uksort($remainders, function ($a, $b) use ($remainders, $weights) {
                if ($remainders[$a] !== $remainders[$b]) {
                    return $remainders[$b] <=> $remainders[$a];
                }
                if (($weights[$b] ?? 0) !== ($weights[$a] ?? 0)) {
                    return ($weights[$b] ?? 0) <=> ($weights[$a] ?? 0);
                }
                return $a <=> $b;
            });
            foreach (array_keys($remainders) as $k) {
                if ($leftover <= 0) break;
                $shares[$k]++;
                $leftover--;
            }
        }

        return $shares;
    }

    /**
     * Compute the frozen settlement for an order from its vendor subtotals and
     * the order-level pools. All money in/out is whole-rupee integers.
     *
     * @param  array<int,float> $vendorSubtotals  vendor_id => raw selling subtotal (decimals ok)
     * @param  float $couponDiscount  coupon-only discount in ₹ (excludes MRP savings)
     * @param  float $deliveryCharge
     * @param  float $handlingCharge
     * @return array{
     *   grand_total:int,
     *   goods_total:int,
     *   coupon_discount:int,
     *   delivery_charge:int,
     *   handling_charge:int,
     *   vendors: array<int,array{goods_subtotal:int,coupon_share:int,delivery_share:int,handling_share:int,collect_amount:int}>
     * }
     */
    public static function freeze(array $vendorSubtotals, float $couponDiscount, float $deliveryCharge, float $handlingCharge): array
    {
        $couponInt   = max(0, (int) round($couponDiscount));
        $deliveryInt = max(0, (int) round($deliveryCharge));
        $handlingInt = max(0, (int) round($handlingCharge));

        // Goods total as a single integer, then split into per-vendor integer
        // subtotals that sum to it (so rounding never leaks a rupee).
        $goodsTotal     = (int) round(array_sum($vendorSubtotals));
        $goodsSubtotals = self::allocate($goodsTotal, $vendorSubtotals);

        // Allocate each pool by the same value weights.
        $couponShares   = self::allocate($couponInt, $vendorSubtotals);
        $deliveryShares = self::allocate($deliveryInt, $vendorSubtotals);
        $handlingShares = self::allocate($handlingInt, $vendorSubtotals);

        $vendors = [];
        foreach (array_keys($vendorSubtotals) as $vid) {
            $goods    = $goodsSubtotals[$vid] ?? 0;
            $coupon   = $couponShares[$vid] ?? 0;
            $delivery = $deliveryShares[$vid] ?? 0;
            $handling = $handlingShares[$vid] ?? 0;
            $vendors[$vid] = [
                'goods_subtotal' => $goods,
                'coupon_share'   => $coupon,
                'delivery_share' => $delivery,
                'handling_share' => $handling,
                // The one authoritative figure.
                'collect_amount' => $goods - $coupon + $delivery + $handling,
            ];
        }

        // Grand total is, by construction, the sum of vendor collect amounts.
        $grandTotal = $goodsTotal - $couponInt + $deliveryInt + $handlingInt;

        return [
            'grand_total'     => $grandTotal,
            'goods_total'     => $goodsTotal,
            'coupon_discount' => $couponInt,
            'delivery_charge' => $deliveryInt,
            'handling_charge' => $handlingInt,
            'vendors'         => $vendors,
        ];
    }
}
