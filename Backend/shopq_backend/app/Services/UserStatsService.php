<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserStat;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Builds / refreshes the denormalized `user_stats` table from users, pincodes
 * and orders. Run nightly (and after big data changes) so campaign audiences
 * resolve from a single indexed table instead of scanning orders live.
 */
class UserStatsService
{
    public function rebuild(): int
    {
        $now = now();

        // 1) Geo + registration for every user (chunked upsert).
        User::query()
            ->leftJoin('pincodes', 'users.pincode_id', '=', 'pincodes.id')
            ->orderBy('users.id')
            ->select(
                'users.id',
                'users.pincode_id',
                'users.created_at',
                'pincodes.code as pincode_code',
                'pincodes.area_name',
                'pincodes.city',
                'pincodes.state',
            )
            ->chunk(1000, function ($rows) use ($now) {
                $payload = [];
                foreach ($rows as $u) {
                    $payload[] = [
                        'user_id'        => $u->id,
                        'pincode_id'     => $u->pincode_id,
                        'pincode_code'   => $u->pincode_code,
                        'area_name'      => $u->area_name,
                        'city'           => $u->city,
                        'state'          => $u->state,
                        'registered_at'  => $u->created_at,
                        'last_active_at' => $u->created_at,
                        'created_at'     => $now,
                        'updated_at'     => $now,
                    ];
                }
                if ($payload) {
                    UserStat::upsert($payload, ['user_id'], [
                        'pincode_id', 'pincode_code', 'area_name',
                        'city', 'state', 'registered_at', 'updated_at',
                    ]);
                }
            });

        // 2) Order behavior aggregates.
        $statusExpr = Schema::hasColumn('orders', 'derived_status')
            ? "COALESCE(NULLIF(derived_status, ''), status)"
            : 'status';

        DB::table('orders')
            ->whereNotNull('user_id')
            ->groupBy('user_id')
            ->orderBy('user_id')
            ->selectRaw("user_id,
                COUNT(*) AS total,
                MAX(created_at) AS last_order_at,
                MAX(($statusExpr) = 'cancelled') AS cancelled_cnt,
                MAX(($statusExpr) = 'delivered') AS completed_cnt,
                MAX(($statusExpr) NOT IN ('delivered','cancelled','returned','refunded')) AS pending_cnt")
            ->chunk(1000, function ($rows) {
                foreach ($rows as $a) {
                    UserStat::where('user_id', $a->user_id)->update([
                        'total_orders'   => $a->total,
                        'last_order_at'  => $a->last_order_at,
                        'last_active_at' => $a->last_order_at,
                        'has_cancelled'  => (bool) $a->cancelled_cnt,
                        'has_completed'  => (bool) $a->completed_cnt,
                        'has_pending'    => (bool) $a->pending_cnt,
                    ]);
                }
            });

        // 3) Latest language seen from any of the user's devices.
        DB::table('device_tokens')
            ->where('tokenable_type', User::class)
            ->whereNotNull('language')
            ->orderBy('tokenable_id')
            ->select('tokenable_id', DB::raw('MAX(language) as language'))
            ->groupBy('tokenable_id')
            ->chunk(1000, function ($rows) {
                foreach ($rows as $r) {
                    UserStat::where('user_id', $r->tokenable_id)
                        ->update(['language' => $r->language]);
                }
            });

        return UserStat::count();
    }
}
