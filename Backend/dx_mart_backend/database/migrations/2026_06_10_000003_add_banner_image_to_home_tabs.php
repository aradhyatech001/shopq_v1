<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// banner_image is already included in 2026_06_10_000002 create migration.
// This migration is kept for existing databases that ran the old stub migration.
return new class extends Migration
{
    public function up(): void
    {
        // Only add if column does not already exist (safe for fresh installs)
        if (Schema::hasTable('home_tabs') && !Schema::hasColumn('home_tabs', 'banner_image')) {
            Schema::table('home_tabs', function (Blueprint $table) {
                $table->string('banner_image')->nullable()->after('bg_color');
            });
        }

        // Also ensure all required columns exist for databases that ran the old stub migration
        if (Schema::hasTable('home_tabs') && !Schema::hasColumn('home_tabs', 'name')) {
            Schema::table('home_tabs', function (Blueprint $table) {
                $table->string('name', 100)->default('Tab')->after('id');
                $table->string('icon', 100)->default('shopping_bag')->after('name');
                $table->string('type', 20)->default('category')->after('icon');
                $table->unsignedBigInteger('category_id')->nullable()->after('type');
                $table->integer('position')->default(0)->after('bg_color');
                $table->boolean('is_active')->default(true)->after('position');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('home_tabs', 'banner_image')) {
            Schema::table('home_tabs', function (Blueprint $table) {
                $table->dropColumn('banner_image');
            });
        }
    }
};
