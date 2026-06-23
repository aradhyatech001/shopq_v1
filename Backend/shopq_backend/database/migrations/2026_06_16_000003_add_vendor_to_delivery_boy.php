<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Hybrid delivery fleet: a delivery boy is either platform-owned (vendor_id NULL,
 * created by admin, assignable by any vendor) or vendor-owned (vendor_id set,
 * created and assignable only by that vendor).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('delivery_boy', function (Blueprint $table) {
            if (!Schema::hasColumn('delivery_boy', 'vendor_id')) {
                $table->unsignedBigInteger('vendor_id')->nullable()->after('id'); // NULL = platform pool
                $table->index('vendor_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('delivery_boy', function (Blueprint $table) {
            if (Schema::hasColumn('delivery_boy', 'vendor_id')) {
                $table->dropColumn('vendor_id');
            }
        });
    }
};
