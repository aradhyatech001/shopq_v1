<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

/**
 * One complete, self-contained seed: a single linked row in every table,
 * in correct parent → child order. Re-runnable (truncates first).
 *
 *   php artisan db:seed --class=CompleteSeeder
 */
class CompleteSeeder extends Seeder
{
    public function run(): void
    {
        $now = now();

        // ── Wipe (children first not needed — FK checks off) ──
        $tables = [
            'order_assignment','order_items','orders','cart_items','wishlist',
            'flash_deals','product_highlights','product_info','product_images',
            'product_variants','products','home_sections','home_tabs','banner',
            'coupon','vendor_subscriptions','vendor_pincodes','vendors',
            'delivery_address','delivery_boy','users','sub_category','main_category',
            'subscription_plans','product_types','pincodes','city','district',
            'app_settings','admin','otp_table','deliver_time','delivery_charge',
            'free_delivey','handling_charge','minimum_order_amout',
            'help_call','help_email','help_whatsapp',
        ];
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        foreach ($tables as $t) {
            try { DB::table($t)->truncate(); } catch (\Throwable $e) {}
        }
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        // ── 1. Admin ──
        DB::table('admin')->insert([
            'email' => 'admin@dxmart.com', 'password' => Hash::make('admin123'),
            'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 2. App settings (theme/config) ──
        $settings = [
            'primary_color' => '#F5BF14', 'secondary_color' => '#FFC63A',
            'app_name' => 'DxMart', 'delivery_time_text' => '24 Min',
            'free_delivery_text' => '₹0 delivery fee', 'search_hint' => 'Search for "Milk"',
            'assurance_1' => 'Lowest Prices', 'assurance_2' => 'Quality Checked', 'assurance_3' => 'Easy Returns',
        ];
        foreach ($settings as $k => $v) {
            DB::table('app_settings')->insert(['key' => $k, 'value' => $v, 'created_at' => $now, 'updated_at' => $now]);
        }

        // ── 3. Location: district → city, pincode ──
        $districtId = DB::table('district')->insertGetId([
            'district_name' => 'Patna', 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('city')->insert([
            'district_id' => $districtId, 'city_name' => 'Patna City', 'created_at' => $now, 'updated_at' => $now,
        ]);
        $pincodeId = DB::table('pincodes')->insertGetId([
            'code' => '800001', 'area_name' => 'Connaught Place', 'city' => 'Patna',
            'state' => 'Bihar', 'is_active' => 1, 'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 4. Catalog: main_category → sub_category, product_types ──
        $categoryId = DB::table('main_category')->insertGetId([
            'name' => 'Fruits & Vegetables', 'image' => null, 'icon_url' => null,
            'color_code' => '#2DB87B', 'tab_bg_color' => '#F5F5F5', 'is_tab' => 1,
            'tab_position' => 1, 'description' => 'Fresh produce', 'is_active' => 1,
            'position' => 1, 'created_at' => $now, 'updated_at' => $now,
        ]);
        $subId = DB::table('sub_category')->insertGetId([
            'main_category_id' => $categoryId, 'name' => 'Fresh Vegetables',
            'image_url' => null, 'icon_url' => null, 'position' => 1, 'is_active' => 1, 'created_at' => $now,
        ]);
        $productTypeId = DB::table('product_types')->insertGetId([
            'name' => 'Best Selling', 'position' => 1, 'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 5. Subscription plan ──
        $planId = DB::table('subscription_plans')->insertGetId([
            'name' => 'Basic Monthly', 'duration_type' => 'monthly', 'duration_days' => 30,
            'price' => 499.00, 'features' => json_encode(['Up to 50 products', 'Standard support']),
            'max_products' => 50, 'is_active' => 1, 'position' => 1, 'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 6. Vendor → vendor_pincode, vendor_subscription ──
        $vendorId = DB::table('vendors')->insertGetId([
            'name' => 'Ravi Kumar', 'email' => 'ravi@vendor.com', 'phone' => '9000000001',
            'password' => Hash::make('pass1234'), 'shop_name' => 'Ravi Fresh Mart',
            'shop_description' => 'Fresh fruits & vegetables', 'logo' => null,
            'status' => 'approved', 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('vendor_pincodes')->insert([
            'vendor_id' => $vendorId, 'pincode_id' => $pincodeId, 'pincode' => '800001',
            'area_name' => 'Connaught Place', 'is_active' => 1, 'created_at' => $now,
        ]);
        DB::table('vendor_subscriptions')->insert([
            'vendor_id' => $vendorId, 'plan_id' => $planId,
            'start_date' => $now->toDateString(), 'end_date' => $now->copy()->addDays(30)->toDateString(),
            'status' => 'active', 'payment_reference' => 'SEED-TXN-001', 'payment_mode' => 'manual',
            'amount_paid' => 499.00, 'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 7. User → delivery_address ──
        $userId = DB::table('users')->insertGetId([
            'name' => 'Test User', 'email' => 'user@dxmart.com', 'status' => 'active',
            'pincode_id' => $pincodeId, 'email_verified_at' => $now,
            'password' => Hash::make('pass1234'), 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('delivery_address')->insert([
            'pincode' => '800001', 'user_id' => $userId, 'name' => 'Test User', 'phone' => '9000000002',
            'full_address' => '12 Main Street, Patna', 'pin_code' => '800001', 'landmark' => 'Near Park',
            'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 8. Delivery boy ──
        $deliveryBoyId = DB::table('delivery_boy')->insertGetId([
            'name' => 'Suresh', 'email' => 'suresh@delivery.com', 'mobile' => '9000000003',
            'pin_code' => '800001', 'address' => 'Patna', 'password' => Hash::make('pass1234'),
            'date_time' => $now, 'status' => 'active',
        ]);

        // ── 9. Product → variant, image, info, highlight ──
        $productId = DB::table('products')->insertGetId([
            'vendor_id' => $vendorId, 'name' => 'Tomato (Country)', 'description' => 'Farm-fresh country tomatoes.',
            'main_category_id' => $categoryId, 'subcategory_id' => $subId, 'brand_id' => null,
            'types' => 'Best Selling', 'is_active' => 1, 'image_url' => null, 'icon_url' => null,
            'created_at' => $now, 'updated_at' => $now,
        ]);
        $variantId = DB::table('product_variants')->insertGetId([
            'product_id' => $productId, 'name' => '1 kg', 'price' => 55.00, 'selling_price' => 45.00,
            'wholesale_price' => 36.00, 'stock' => 100, 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('product_images')->insert([
            'product_id' => $productId, 'image_url' => 'products/tomato.png', 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('product_info')->insert([
            'product_id' => $productId, 'attribute' => 'Shelf Life', 'value' => '5 days', 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('product_highlights')->insert([
            'product_id' => $productId, 'attribute' => 'Origin', 'value' => 'Local Farm', 'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 10. Cart + wishlist (user ↔ product) ──
        DB::table('cart_items')->insert([
            'user_id' => $userId, 'product_id' => $productId, 'variant_id' => $variantId,
            'quantity' => 2, 'image_url' => 'products/tomato.png', 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('wishlist')->insert([
            'user_id' => $userId, 'product_id' => $productId, 'created_at' => $now,
        ]);

        // ── 11. Coupon ──
        DB::table('coupon')->insert([
            'title' => 'Welcome Offer', 'description' => 'Flat 10% off', 'code_name' => 'WELCOME10',
            'discount' => 10.00, 'expri_date' => $now->copy()->addYear()->format('d-m-Y'),
            'status' => 'Public', 'min_amount' => 100.00, 'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 12. Banner ──
        DB::table('banner')->insert([
            'category_id' => $categoryId, 'banner_image' => 'banner/welcome.png',
            'is_active' => 1, 'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 13. Home tab → home section ──
        $tabId = DB::table('home_tabs')->insertGetId([
            'name' => 'All', 'icon' => 'all', 'icon_image' => null, 'type' => 'all',
            'category_id' => null, 'bg_color' => '#6C63FF', 'banner_image' => null,
            'position' => 0, 'is_active' => 1, 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('home_sections')->insert([
            'home_tab_id' => $tabId, 'title' => 'Best Selling', 'emoji' => null, 'banner_image' => null,
            'section_type' => 'product_type', 'product_type' => 'Best Selling', 'main_category_id' => null,
            'subcategory_id' => null, 'brand_id' => null, 'link_category_id' => null,
            'product_limit' => 10, 'position' => 1, 'is_active' => 1, 'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 14. Flash deal (product ↔ variant) ──
        DB::table('flash_deals')->insert([
            'product_id' => $productId, 'variant_id' => $variantId, 'title' => 'Flash: Tomato 1kg',
            'deal_price' => 39.00, 'start_time' => $now, 'end_time' => $now->copy()->addDays(2),
            'is_active' => 1, 'created_at' => $now,
        ]);

        // ── 15. Order → order_items, order_assignment ──
        $orderId = DB::table('orders')->insertGetId([
            'user_id' => $userId, 'vendor_id' => $vendorId, 'total_amount' => 90.00, 'coupon_code' => 'WELCOME10',
            'discount_amount' => 9.00, 'delivery_charge' => 20.00, 'handling_charge' => 5.00, 'final_amount' => 106.00,
            'status' => 'pending', 'payment_method' => 'COD', 'order_datetime' => $now,
            'delivery_date' => $now->copy()->addDay()->toDateString(), 'delivery_time' => '10:00 AM - 12:00 PM',
            'location_id' => 1, 'gift' => '', 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('order_items')->insert([
            'order_id' => $orderId, 'product_id' => $productId, 'variant_id' => $variantId,
            'quantity' => 2, 'price' => 45.00, 'image_url' => 'products/tomato.png', 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('order_assignment')->insert([
            'order_id' => $orderId, 'delivery_boy_id' => $deliveryBoyId, 'date_time' => $now,
            'created_at' => $now, 'updated_at' => $now,
        ]);

        // ── 16. OTP + single-value settings + help ──
        DB::table('otp_table')->insert([
            'email' => 'user@dxmart.com', 'otp' => '123456',
            'expiry' => $now->copy()->addMinutes(10)->timestamp, 'created_at' => $now, 'updated_at' => $now,
        ]);
        DB::table('deliver_time')->insert(['time' => '24 Min', 'created_at' => $now, 'updated_at' => $now]);
        DB::table('delivery_charge')->insert(['amount' => 20.00, 'created_at' => $now, 'updated_at' => $now]);
        DB::table('free_delivey')->insert(['amount' => 499.00, 'created_at' => $now, 'updated_at' => $now]);
        DB::table('handling_charge')->insert(['amount' => 5.00, 'created_at' => $now, 'updated_at' => $now]);
        DB::table('minimum_order_amout')->insert(['amount' => 99.00, 'created_at' => $now, 'updated_at' => $now]);
        DB::table('help_call')->insert(['call_help' => '+91-9000000000', 'created_at' => $now, 'updated_at' => $now]);
        DB::table('help_email')->insert(['email' => 'support@dxmart.com', 'created_at' => $now, 'updated_at' => $now]);
        DB::table('help_whatsapp')->insert(['whatsapp_no' => '+91-9000000000', 'created_at' => $now, 'updated_at' => $now]);

        $this->command->info('✓ CompleteSeeder: one linked row seeded in every table.');
    }
}
