<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Drop the unused `pincode` column from delivery_address.
        // The original migration (2024_01_01_000007) created `pin_code`.
        // A later migration (2026_06_11_000007) added a duplicate `pincode` column
        // that was never wired to the model ($fillable uses `pin_code`) or any controller.
        if (Schema::hasColumn('delivery_address', 'pincode')) {
            Schema::table('delivery_address', function (Blueprint $table) {
                $table->dropColumn('pincode');
            });
        }

        // Backfill NULL timestamps on every table whose migration called $table->timestamps()
        // but whose Eloquent model had `public $timestamps = false`, leaving rows with NULLs.
        $now = now()->toDateTimeString();

        $tables = [
            'admin',
            'banner',
            'cart_items',
            'cities',
            'coupon',
            'deliver_time',
            'delivery_address',
            'delivery_boy',
            'delivery_charge',
            'districts',
            'free_delivery',
            'handling_charge',
            'help_call',
            'help_email',
            'help_whatsapp',
            'home_tabs',
            'main_category',
            'minimum_order_amount',
            'order_assignment',
            'order_items',
            'orders',
            'otp_table',
            'pincodes',
            'product_highlights',
            'product_images',
            'product_info',
            'product_types',
            'product_variants',
            'products',
            'subscription_plans',
            'users',
            'vendor_subscriptions',
            'vendors',
        ];

        foreach ($tables as $tbl) {
            if (!Schema::hasTable($tbl)) {
                continue;
            }
            if (Schema::hasColumn($tbl, 'created_at')) {
                DB::table($tbl)->whereNull('created_at')->update(['created_at' => $now]);
            }
            if (Schema::hasColumn($tbl, 'updated_at')) {
                DB::table($tbl)->whereNull('updated_at')->update(['updated_at' => $now]);
            }
        }
    }

    public function down(): void
    {
        if (!Schema::hasColumn('delivery_address', 'pincode')) {
            Schema::table('delivery_address', function (Blueprint $table) {
                $table->string('pincode', 10)->nullable()->after('id');
            });
        }
    }
};
