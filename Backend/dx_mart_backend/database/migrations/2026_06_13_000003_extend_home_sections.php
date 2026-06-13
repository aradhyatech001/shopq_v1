<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('home_sections', function (Blueprint $table) {
            if (!Schema::hasColumn('home_sections', 'home_tab_id')) {
                $table->unsignedBigInteger('home_tab_id')->nullable()->after('id');
            }
            if (!Schema::hasColumn('home_sections', 'brand_id')) {
                $table->unsignedBigInteger('brand_id')->nullable()->after('main_category_id');
            }
            if (!Schema::hasColumn('home_sections', 'banner_image')) {
                $table->string('banner_image')->nullable()->after('emoji');
            }
            if (!Schema::hasColumn('home_sections', 'link_category_id')) {
                $table->unsignedBigInteger('link_category_id')->nullable()->after('brand_id');
            }
            if (!Schema::hasColumn('home_sections', 'updated_at')) {
                $table->timestamp('updated_at')->nullable();
            }
        });

        // section_type was an ENUM limited to a few values — widen it so new
        // section types (category_grid, products, …) are accepted.
        try {
            DB::statement("ALTER TABLE home_sections MODIFY section_type VARCHAR(40) NOT NULL DEFAULT 'product_type'");
        } catch (\Throwable $e) {
            // non-MySQL or already widened — ignore
        }
    }

    public function down(): void
    {
        Schema::table('home_sections', function (Blueprint $table) {
            foreach (['home_tab_id', 'brand_id', 'banner_image', 'link_category_id', 'updated_at'] as $col) {
                if (Schema::hasColumn('home_sections', $col)) {
                    $table->dropColumn($col);
                }
            }
        });
    }
};
