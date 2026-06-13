<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DeliveryChargeSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('delivery_charge')->truncate();
        DB::table('delivery_charge')->insert([
            [
                'id' => 1,
                'amount' => 10,
            ],
        ]);
    }
}
