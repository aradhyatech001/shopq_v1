<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Fills every remaining table with at least one representative, FK-correct row
 * (settings, help, banner, coupon, product info/highlights, flash deal, order
 * assignment, legacy district/city, OTP, cart). Idempotent: each block only
 * inserts when its table is empty.
 */
class RemainingDataSeeder extends Seeder
{
    public function run(): void
    {
        $now = now();

        // ── Settings (one row each) ───────────────────────────
        $this->seedIfEmpty('free_delivey',        ['amount' => 499.00, 'created_at' => $now, 'updated_at' => $now]);
        $this->seedIfEmpty('handling_charge',     ['amount' => 9.00,   'created_at' => $now, 'updated_at' => $now]);
        $this->seedIfEmpty('minimum_order_amout', ['amount' => 99.00,  'created_at' => $now, 'updated_at' => $now]);
        $this->seedIfEmpty('deliver_time',        ['time' => '24 Min', 'created_at' => $now, 'updated_at' => $now]);

        // ── Help (one row each) ───────────────────────────────
        $this->seedIfEmpty('help_call',     ['call_help'   => '+91 90000 00000',   'created_at' => $now, 'updated_at' => $now]);
        $this->seedIfEmpty('help_email',    ['email'       => 'support@shopq.com', 'created_at' => $now, 'updated_at' => $now]);
        $this->seedIfEmpty('help_whatsapp', ['whatsapp_no' => '+91 90000 00000',   'created_at' => $now, 'updated_at' => $now]);

        // ── Banner (child of main_category) ───────────────────
        if (DB::table('banner')->count() === 0) {
            $cat = DB::table('main_category')->orderBy('id')->first();
            DB::table('banner')->insert([
                'category_id'  => $cat->id ?? null,
                'banner_image' => $cat->image ?? 'banners/placeholder.png', // NOT NULL
                'is_active'    => 1,
                'created_at'   => $now, 'updated_at' => $now,
            ]);
        }

        // ── Coupon ────────────────────────────────────────────
        $this->seedIfEmpty('coupon', [
            'title'       => 'Welcome Offer',
            'description' => 'Flat 10% off on your first order',
            'code_name'   => 'WELCOME10',
            'discount'    => 10.00,
            'expri_date'  => '31-12-2026',
            'status'      => 'Public',
            'min_amount'  => 199.00,
            'created_at'  => $now, 'updated_at' => $now,
        ]);

        // ── Product info + highlights (child of first product) ─
        $productId = DB::table('products')->min('id');
        $variant   = $productId ? DB::table('product_variants')->where('product_id', $productId)->first() : null;

        if ($productId && DB::table('product_info')->count() === 0) {
            DB::table('product_info')->insert([
                ['product_id' => $productId, 'attribute' => 'Brand',      'value' => 'ShopQ',   'created_at' => $now, 'updated_at' => $now],
                ['product_id' => $productId, 'attribute' => 'Shelf Life', 'value' => '7 days',  'created_at' => $now, 'updated_at' => $now],
            ]);
        }
        if ($productId && DB::table('product_highlights')->count() === 0) {
            DB::table('product_highlights')->insert([
                ['product_id' => $productId, 'attribute' => 'Storage', 'value' => 'Keep refrigerated', 'created_at' => $now, 'updated_at' => $now],
            ]);
        }

        // ── Flash deal (child of product + variant) ───────────
        if ($productId && DB::table('flash_deals')->count() === 0) {
            DB::table('flash_deals')->insert([
                'product_id' => $productId,
                'variant_id' => $variant->id ?? null,
                'title'      => 'Flash Sale',
                'deal_price' => $variant->selling_price ?? 0,
                'start_time' => $now,
                'end_time'   => (clone $now)->addDays(7),
                'is_active'  => 1,
                'created_at' => $now,
            ]);
        }

        // ── Order assignment (child of order + delivery_boy) ──
        if (DB::table('order_assignment')->count() === 0) {
            $orderId = DB::table('orders')->min('id');
            $boyId   = DB::table('delivery_boy')->min('id');
            if ($orderId && $boyId) {
                DB::table('order_assignment')->insert([
                    'order_id'        => $orderId,
                    'delivery_boy_id' => $boyId,
                    'date_time'       => $now,
                    'created_at'      => $now, 'updated_at' => $now,
                ]);
            }
        }

        // ── Legacy district + city (city is child of district) ─
        if (DB::table('district')->count() === 0) {
            $districtId = DB::table('district')->insertGetId([
                'district_name' => 'New Delhi', 'created_at' => $now, 'updated_at' => $now,
            ]);
            DB::table('city')->insert([
                'district_id' => $districtId, 'city_name' => 'Connaught Place',
                'created_at' => $now, 'updated_at' => $now,
            ]);
        }

        // ── OTP (transient sample) ────────────────────────────
        $this->seedIfEmpty('otp_table', [
            'email' => 'demo@shopq.com', 'otp' => '123456',
            'expiry' => (clone $now)->addMinutes(10)->timestamp, // bigint epoch
            'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── Cart item (child of user + product) ───────────────
        if ($productId && DB::table('cart_items')->count() === 0) {
            $userId = DB::table('users')->min('id');
            if ($userId) {
                DB::table('cart_items')->insert([
                    'user_id'    => $userId,
                    'product_id' => $productId,
                    'variant_id' => $variant->id ?? null,
                    'quantity'   => 1,
                    'image_url'  => null,
                    'created_at' => $now, 'updated_at' => $now,
                ]);
            }
        }
    }

    private function seedIfEmpty(string $table, array $row): void
    {
        if (DB::table($table)->count() === 0) {
            DB::table($table)->insert($row);
        }
    }
}
