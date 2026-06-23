<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DeliveryBoySeeder extends Seeder
{
    public function run(): void
    {
        DB::table('delivery_boy')->truncate();
        DB::table('delivery_boy')->insert([
            [
                'id' => 1,
                'name' => 'Rajesh Kumar',
                'email' => 'rajesh49011@gmail.com',
                'mobile' => '8102337432',
                'pin_code' => '825408',
                'address' => 'Vill - Paroriya, Post - Badgwan, Chatra Jharkhand ',
                'password' => Hash::make('Boy@1234'),
                'date_time' => '14-10-2025 08:24 AM',
                'status' => 'active',
            ],
            [
                'id' => 2,
                'name' => 'Pankaj Kumar',
                'email' => 'pankajkumar.hzb143@gmail.com',
                'mobile' => '6205511717',
                'pin_code' => '834002',
                'address' => 'Ranchi',
                'password' => Hash::make('Boy@1234'),
                'date_time' => '29-10-2025 06:54 PM',
                'status' => 'inactive',
            ],
        ]);
    }
}
