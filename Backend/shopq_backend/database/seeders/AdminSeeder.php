<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('admin')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');
        DB::table('admin')->insert([
            ['email' => 'admin@shopq.com', 'password' => Hash::make('Admin@123'), 'created_at' => now(), 'updated_at' => now()],
        ]);
    }
}
