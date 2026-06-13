<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('banner', function (Blueprint $table) {
            if (!Schema::hasColumn('banner', 'is_active')) {
                $table->tinyInteger('is_active')->default(1)->after('banner_image');
            }
        });
    }

    public function down(): void {
        Schema::table('banner', function (Blueprint $table) {
            if (Schema::hasColumn('banner', 'is_active')) {
                $table->dropColumn('is_active');
            }
        });
    }
};
