<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('home_sections', function (Blueprint $table) {
            if (!Schema::hasColumn('home_sections', 'subcategory_id')) {
                $table->unsignedBigInteger('subcategory_id')->nullable()->after('main_category_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('home_sections', function (Blueprint $table) {
            if (Schema::hasColumn('home_sections', 'subcategory_id')) {
                $table->dropColumn('subcategory_id');
            }
        });
    }
};
