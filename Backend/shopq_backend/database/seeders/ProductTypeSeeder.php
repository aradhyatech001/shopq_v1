<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProductTypeSeeder extends Seeder
{
    public function run(): void
    {
        // Product types power the "Product-Type Row" sections (admin Section
        // Builder) and the legacy by-type product feeds. Idempotent by name.
        $types = [
            'Best Selling',
            'Daily Deals',
            'Everyday Essentials',
            'Handpicked You 💝',
            'Hot Deals',
            'Buy 1 Get 1',
            '50% Off',
            'Fresh Arrivals',
        ];

        foreach ($types as $i => $name) {
            DB::table('product_types')->updateOrInsert(
                ['name' => $name],
                ['position' => $i + 1, 'created_at' => now(), 'updated_at' => now()]
            );
        }
    }
}
