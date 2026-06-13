<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add user's selected pincode
        if (!Schema::hasColumn('users', 'pincode_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->unsignedBigInteger('pincode_id')->nullable()->after('status');
            });
        }

        // Add pincode to delivery_address (singular — matches actual table name)
        if (Schema::hasTable('delivery_address') && !Schema::hasColumn('delivery_address', 'pincode')) {
            Schema::table('delivery_address', function (Blueprint $table) {
                $table->string('pincode', 10)->nullable()->after('id');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('users', 'pincode_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('pincode_id');
            });
        }

        if (Schema::hasTable('delivery_address') && Schema::hasColumn('delivery_address', 'pincode')) {
            Schema::table('delivery_address', function (Blueprint $table) {
                $table->dropColumn('pincode');
            });
        }
    }
};
