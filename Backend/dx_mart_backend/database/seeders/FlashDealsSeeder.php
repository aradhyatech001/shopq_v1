<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class FlashDealsSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('flash_deals')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');
        // Flash deals seeder - currently empty, add data as needed
        // Example structure:
        // DB::table('flash_deals')->insert([
        //     [
        //         'product_id' => 1,
        //         'variant_id' => 1,
        //         'title' => 'Flash Sale',
        //         'deal_price' => 99.99,
        //         'start_time' => now(),
        //         'end_time' => now()->addHours(24),
        //         'is_active' => true,
        //     ],
        // ]);
    }
}
