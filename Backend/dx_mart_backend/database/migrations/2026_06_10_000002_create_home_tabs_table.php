<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('home_tabs', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->string('icon', 100)->default('shopping_bag');
            // type: 'all' = show all products, 'categories' = show category grid,
            //       'category' = show single category products, 'deals' = all products grouped by type
            $table->enum('type', ['all', 'category', 'categories', 'deals'])->default('category');
            $table->unsignedBigInteger('category_id')->nullable();
            $table->string('bg_color', 20)->default('#6C63FF');
            $table->string('banner_image')->nullable();
            $table->integer('position')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // Default tabs
        DB::table('home_tabs')->insert([
            [
                'name'       => 'All',
                'icon'       => 'all',
                'type'       => 'all',
                'category_id'=> null,
                'bg_color'   => '#6C63FF',
                'position'   => 0,
                'is_active'  => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name'       => 'Categories',
                'icon'       => 'grid',
                'type'       => 'categories',
                'category_id'=> null,
                'bg_color'   => '#FF6584',
                'position'   => 1,
                'is_active'  => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('home_tabs');
    }
};
