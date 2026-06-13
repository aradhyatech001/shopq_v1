<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

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
                'password' => '$2y$10$dFbrnzcNGGET80HVeG3vb.pB8n5KaynhXSIT/KkarAvnS5Yvu/jTm',
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
                'password' => '$2y$10$jJ1R9az46bmCPCu9VEwk1uLaU/Uu3nXqOW2KOTa3tb9eu5HVEuAw.',
                'date_time' => '29-10-2025 06:54 PM',
                'status' => 'inactive',
            ],
        ]);
    }
}
