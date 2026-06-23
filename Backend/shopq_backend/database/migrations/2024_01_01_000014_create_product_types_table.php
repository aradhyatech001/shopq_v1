<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('product_types', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->integer('position')->default(0);
            $table->timestamps();
        });

        // Seed default types
        DB::table('product_types')->insert([
            ['name' => 'Handpicked You 💝',  'position' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Daily Deals',       'position' => 2, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Everyday Essentials', 'position' => 3, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Best Selling',      'position' => 4, 'created_at' => now(), 'updated_at' => now()],
            ['name' => 'Hot Deals',         'position' => 5, 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('product_types');
    }
};
