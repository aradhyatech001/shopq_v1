<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AppSettingsSeeder extends Seeder
{
    public function run(): void
    {
        // Admin-controlled user-app theme & texts (Appearance screen).
        // Only inserts keys that don't already exist, so admin edits are
        // never overwritten on re-seed.
        $defaults = [
            'primary_color'      => '#009c08',
            'secondary_color'    => '#46ff55',
            'app_name'           => 'ShopQ',
            'delivery_time_text' => '24 Min',
            'free_delivery_text' => '₹0 delivery fee',
            'search_hint'        => 'Search for "Milk"',
            'assurance_1'        => 'Lowest Prices',
            'assurance_2'        => 'Quality Checked',
            'assurance_3'        => 'Easy Returns',
        ];

        foreach ($defaults as $key => $value) {
            $exists = DB::table('app_settings')->where('key', $key)->exists();
            if (!$exists) {
                DB::table('app_settings')->insert([
                    'key' => $key, 'value' => $value,
                    'created_at' => now(), 'updated_at' => now(),
                ]);
            }
        }
    }
}
