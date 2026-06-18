<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            // ── Core data (required by everything else) ───────────
            AdminSeeder::class,
            AppSettingsSeeder::class,        // admin-controlled theme/config
            MainCategorySeeder::class,       // main_category + sub_category tables
            ProductTypeSeeder::class,        // product_types (used by sections)
            DeliveryBoySeeder::class,
            DeliveryChargeSeeder::class,

            // ── Home / marketing ──────────────────────────────────
            HomeTabSeeder::class,            // tabs (must precede sections)
            HomeSectionsSeeder::class,       // per-tab storefront layout
            FlashDealsSeeder::class,
            ProductTagsSeeder::class,

            // ── Multivendor ───────────────────────────────────────
            PincodeSeeder::class,
            SubscriptionPlanSeeder::class,
            VendorSeeder::class,         // depends on pincodes + plans

            // ── Dummy test data ───────────────────────────────────
            UserSeeder::class,
            ProductSeeder::class,        // depends on categories + vendors
            // OrderSeeder::class,          // depends on users + products
            WishlistSeeder::class,

            // ── Fill every remaining table (banner, coupon, settings,
            //    help, product info/highlights, flash deal, order
            //    assignment, district/city, otp, cart) ──────────────
            RemainingDataSeeder::class,  // depends on products/orders/users/boys

            // ── Legacy (guarded) ─────────────────────────────────
            VendorTokensSeeder::class,
        ]);
    }
}
