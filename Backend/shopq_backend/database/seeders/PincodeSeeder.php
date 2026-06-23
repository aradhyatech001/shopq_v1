<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PincodeSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('pincodes')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');
        DB::table('pincodes')->insert([
            ['code' => '110001', 'area_name' => 'Connaught Place',    'city' => 'New Delhi',  'state' => 'Delhi',         'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '110002', 'area_name' => 'Darya Ganj',         'city' => 'New Delhi',  'state' => 'Delhi',         'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '110003', 'area_name' => 'Lodi Road',          'city' => 'New Delhi',  'state' => 'Delhi',         'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '110011', 'area_name' => 'Karol Bagh',         'city' => 'New Delhi',  'state' => 'Delhi',         'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '110015', 'area_name' => 'Rajouri Garden',     'city' => 'New Delhi',  'state' => 'Delhi',         'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '110020', 'area_name' => 'Saket',              'city' => 'New Delhi',  'state' => 'Delhi',         'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '400001', 'area_name' => 'Fort',               'city' => 'Mumbai',     'state' => 'Maharashtra',   'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '400050', 'area_name' => 'Bandra West',        'city' => 'Mumbai',     'state' => 'Maharashtra',   'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '400069', 'area_name' => 'Andheri East',       'city' => 'Mumbai',     'state' => 'Maharashtra',   'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '560001', 'area_name' => 'MG Road',            'city' => 'Bengaluru',  'state' => 'Karnataka',     'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '560034', 'area_name' => 'Jayanagar',          'city' => 'Bengaluru',  'state' => 'Karnataka',     'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '600001', 'area_name' => 'George Town',        'city' => 'Chennai',    'state' => 'Tamil Nadu',    'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '700001', 'area_name' => 'BBD Bagh',           'city' => 'Kolkata',    'state' => 'West Bengal',   'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '380001', 'area_name' => 'Relief Road',        'city' => 'Ahmedabad',  'state' => 'Gujarat',       'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['code' => '411001', 'area_name' => 'Shivajinagar',       'city' => 'Pune',       'state' => 'Maharashtra',   'is_active' => 1, 'created_at' => now(), 'updated_at' => now()],
        ]);
    }
}
