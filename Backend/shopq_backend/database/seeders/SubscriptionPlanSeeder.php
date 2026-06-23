<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SubscriptionPlanSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('subscription_plans')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');
        DB::table('subscription_plans')->insert([
            [
                'name'          => 'Basic Monthly',
                'duration_type' => 'monthly',
                'duration_days' => 30,
                'price'         => 299.00,
                'features'      => json_encode(['List up to 50 products', 'Select up to 3 pincodes', 'Basic order management', 'Email support']),
                'max_products'  => 50,
                'is_active'     => 1,
                'position'      => 1,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
            [
                'name'          => 'Basic Yearly',
                'duration_type' => 'yearly',
                'duration_days' => 365,
                'price'         => 2999.00,
                'features'      => json_encode(['List up to 50 products', 'Select up to 3 pincodes', 'Basic order management', 'Email support', '2 months free']),
                'max_products'  => 50,
                'is_active'     => 1,
                'position'      => 2,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
            [
                'name'          => 'Standard Monthly',
                'duration_type' => 'monthly',
                'duration_days' => 30,
                'price'         => 599.00,
                'features'      => json_encode(['List up to 200 products', 'Select up to 10 pincodes', 'Priority order management', 'Chat support', 'Analytics dashboard']),
                'max_products'  => 200,
                'is_active'     => 1,
                'position'      => 3,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
            [
                'name'          => 'Standard Yearly',
                'duration_type' => 'yearly',
                'duration_days' => 365,
                'price'         => 5999.00,
                'features'      => json_encode(['List up to 200 products', 'Select up to 10 pincodes', 'Priority order management', 'Chat support', 'Analytics dashboard', '2 months free']),
                'max_products'  => 200,
                'is_active'     => 1,
                'position'      => 4,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
            [
                'name'          => 'Premium Monthly',
                'duration_type' => 'monthly',
                'duration_days' => 30,
                'price'         => 999.00,
                'features'      => json_encode(['Unlimited products', 'All pincodes', 'Dedicated account manager', '24/7 phone support', 'Advanced analytics', 'Featured listings']),
                'max_products'  => 0,
                'is_active'     => 1,
                'position'      => 5,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
            [
                'name'          => 'Premium Yearly',
                'duration_type' => 'yearly',
                'duration_days' => 365,
                'price'         => 9999.00,
                'features'      => json_encode(['Unlimited products', 'All pincodes', 'Dedicated account manager', '24/7 phone support', 'Advanced analytics', 'Featured listings', '2 months free']),
                'max_products'  => 0,
                'is_active'     => 1,
                'position'      => 6,
                'created_at'    => now(),
                'updated_at'    => now(),
            ],
        ]);
    }
}
