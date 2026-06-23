<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('users')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');
        DB::table('users')->insert([
            [
                'name'       => 'Rahul Sharma',
                'email'      => 'rahul@example.com',
                'password'   => Hash::make('Test@1234'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name'       => 'Priya Verma',
                'email'      => 'priya@example.com',
                'password'   => Hash::make('Test@1234'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name'       => 'Amit Kumar',
                'email'      => 'amit@example.com',
                'password'   => Hash::make('Test@1234'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name'       => 'Sneha Patel',
                'email'      => 'sneha@example.com',
                'password'   => Hash::make('Test@1234'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name'       => 'Vikas Singh',
                'email'      => 'vikas@example.com',
                'password'   => Hash::make('Test@1234'),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
