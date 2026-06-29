<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * One-time backfill: copy existing single `fcm_token` values from the
 * users / vendors / delivery_boy tables into the new `device_tokens` table,
 * so no device loses notifications during the transition.
 */
return new class extends Migration
{
    public function up(): void
    {
        $sources = [
            'users'        => 'App\\Models\\User',
            'vendors'      => 'App\\Models\\Vendor',
            'delivery_boy' => 'App\\Models\\DeliveryBoy',
        ];

        foreach ($sources as $table => $morphClass) {
            if (!Schema::hasTable($table) || !Schema::hasColumn($table, 'fcm_token')) {
                continue;
            }

            DB::table($table)
                ->whereNotNull('fcm_token')
                ->where('fcm_token', '!=', '')
                ->orderBy('id')
                ->chunk(500, function ($rows) use ($morphClass) {
                    foreach ($rows as $row) {
                        DB::table('device_tokens')->updateOrInsert(
                            ['token' => $row->fcm_token],
                            [
                                'tokenable_type' => $morphClass,
                                'tokenable_id'   => $row->id,
                                'is_valid'       => 1,
                                'last_seen_at'   => now(),
                                'updated_at'     => now(),
                                'created_at'     => now(),
                            ]
                        );
                    }
                });
        }
    }

    public function down(): void
    {
        // Non-destructive backfill — nothing to reverse.
    }
};
