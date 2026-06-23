<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('products')) {
            Schema::table('products', function (Blueprint $table) {
                if (!Schema::hasColumn('products', 'image_url')) {
                    $table->string('image_url')->nullable()->after('vendor_id');
                }
                if (!Schema::hasColumn('products', 'icon_url')) {
                    $table->string('icon_url')->nullable()->after('image_url');
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('products')) {
            Schema::table('products', function (Blueprint $table) {
                if (Schema::hasColumn('products', 'icon_url')) {
                    $table->dropColumn('icon_url');
                }
                if (Schema::hasColumn('products', 'image_url')) {
                    $table->dropColumn('image_url');
                }
            });
        }
    }
};
