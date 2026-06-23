<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class WishlistSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('wishlist')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        $now = now();
        $users = DB::table('users')->pluck('id')->toArray();
        $products = DB::table('products')->pluck('id')->toArray();

        if (empty($users) || empty($products)) {
            return;
        }

        DB::table('wishlist')->insert([
            ['user_id' => $users[0], 'product_id' => $products[0], 'created_at' => $now],
            ['user_id' => $users[0], 'product_id' => $products[1] ?? $products[0], 'created_at' => $now],
            ['user_id' => $users[1] ?? $users[0], 'product_id' => $products[2] ?? $products[0], 'created_at' => $now],
        ]);
    }
}
