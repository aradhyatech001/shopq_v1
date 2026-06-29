<?php

namespace App\Services;

use Illuminate\Database\Query\Builder;
use Illuminate\Support\Facades\DB;

/**
 * Translates a campaign's audience criteria into an efficient query of
 * recipient ids. Customers are segmented off the denormalized `user_stats`
 * table; vendors / delivery default to "all" (optionally city-filtered later).
 *
 * Criteria shape (all optional):
 * {
 *   "geo": {"city": [...], "state": [...], "pincode": [...], "area": [...]},
 *   "behavior": {"has_pending": true, "has_cancelled": true, "has_completed": true,
 *                "no_orders": true, "min_orders": 1,
 *                "inactive_days": 30, "new_within_days": 7},
 *   "language": ["hi", "en"]
 * }
 */
class AudienceResolver
{
    /** Query selecting recipient ids as `rid`, for the given audience. */
    public function recipientQuery(string $audience, array $criteria): Builder
    {
        $ids = $criteria['user_ids'] ?? null;

        return match ($audience) {
            'vendors'  => DB::table('vendors')->select('id as rid')
                ->when(!empty($ids), fn($q) => $q->whereIn('id', (array) $ids)),
            'delivery' => DB::table('delivery_boy')->select('id as rid')
                ->when(!empty($ids), fn($q) => $q->whereIn('id', (array) $ids)),
            default    => $this->customerQuery($criteria),
        };
    }

    public function count(string $audience, array $criteria): int
    {
        return $this->recipientQuery($audience, $criteria)->count();
    }

    /**
     * Topics to broadcast to for a topic-mode campaign.
     * - explicit pincodes  → one topic per pincode (pincode_<code>)
     * - everything else    → the whole-audience topic (all_<audience>)
     *
     * @return string[]
     */
    public function topicsFor(string $audience, array $criteria): array
    {
        $pincodes = $criteria['geo']['pincode'] ?? null;
        if (!empty($pincodes)) {
            return array_values(array_map(fn($p) => "pincode_{$p}", (array) $pincodes));
        }
        return ["all_{$audience}"];
    }

    private function customerQuery(array $criteria): Builder
    {
        $q = DB::table('user_stats')->select('user_id as rid');

        // Explicit user ids (single / multi-user send) short-circuit segmentation.
        if (!empty($criteria['user_ids'])) {
            $q->whereIn('user_id', (array) $criteria['user_ids']);
        }

        $geo = $criteria['geo'] ?? [];
        if (!empty($geo['city']))    $q->whereIn('city', (array) $geo['city']);
        if (!empty($geo['state']))   $q->whereIn('state', (array) $geo['state']);
        if (!empty($geo['pincode'])) $q->whereIn('pincode_code', (array) $geo['pincode']);
        if (!empty($geo['area']))    $q->whereIn('area_name', (array) $geo['area']);

        $b = $criteria['behavior'] ?? [];
        if (!empty($b['has_pending']))   $q->where('has_pending', true);
        if (!empty($b['has_cancelled'])) $q->where('has_cancelled', true);
        if (!empty($b['has_completed'])) $q->where('has_completed', true);
        if (!empty($b['no_orders']))     $q->where('total_orders', 0);
        if (isset($b['min_orders']))     $q->where('total_orders', '>=', (int) $b['min_orders']);

        if (isset($b['inactive_days'])) {
            $cut = now()->subDays((int) $b['inactive_days']);
            $q->where(function ($w) use ($cut) {
                $w->whereNull('last_order_at')->orWhere('last_order_at', '<', $cut);
            });
        }
        if (isset($b['new_within_days'])) {
            $q->where('registered_at', '>=', now()->subDays((int) $b['new_within_days']));
        }

        if (!empty($criteria['language'])) {
            $q->whereIn('language', (array) $criteria['language']);
        }

        return $q;
    }
}
