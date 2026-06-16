<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('home_sections', function (Blueprint $table) {
            // A banner section can now reference one OR many existing banners
            // (created in Banner Management) instead of holding its own image.
            if (!Schema::hasColumn('home_sections', 'banner_ids')) {
                $table->json('banner_ids')->nullable()->after('banner_image');
            }
        });
    }

    public function down(): void
    {
        Schema::table('home_sections', function (Blueprint $table) {
            if (Schema::hasColumn('home_sections', 'banner_ids')) {
                $table->dropColumn('banner_ids');
            }
        });
    }
};
