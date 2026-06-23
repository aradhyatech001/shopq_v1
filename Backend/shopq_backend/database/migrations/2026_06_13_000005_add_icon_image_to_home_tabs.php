<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('home_tabs', function (Blueprint $table) {
            if (!Schema::hasColumn('home_tabs', 'icon_image')) {
                $table->string('icon_image')->nullable()->after('icon');
            }
        });
    }

    public function down(): void
    {
        Schema::table('home_tabs', function (Blueprint $table) {
            if (Schema::hasColumn('home_tabs', 'icon_image')) {
                $table->dropColumn('icon_image');
            }
        });
    }
};
