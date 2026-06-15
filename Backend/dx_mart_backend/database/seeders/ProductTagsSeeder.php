<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ProductTagsSeeder extends Seeder
{
    public function run(): void
    {
        // product_tags was removed during de-duplication (superseded by
        // product_types). Guard so this seeder is a safe no-op.
        if (!Schema::hasTable('product_tags')) {
            return;
        }
        DB::table('product_tags')->truncate();
        // Product tags seeder - currently empty, add data as needed
        // Example structure:
        // DB::table('product_tags')->insert([
        //     [
        //         'product_id' => 1,
        //         'tag' => 'bestseller',
        //     ],
        //     [
        //         'product_id' => 1,
        //         'tag' => 'new',
        //     ],
        // ]);
    }
}
