<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Adds `ordered_at` DATETIME column to orders so dashboard queries can use
 * an indexed column rather than STR_TO_DATE(order_datetime, ...) on a VARCHAR.
 * Backfills existing rows by parsing the stored "dd-MM-yyyy hh:mm a" format.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (!Schema::hasColumn('orders', 'ordered_at')) {
                $table->dateTime('ordered_at')->nullable()->after('order_datetime');
            }
        });

        // Backfill from the varchar column. Rows that can't be parsed stay null
        // and will be set correctly on the next order insert via OrderController.
        DB::statement("
            UPDATE orders
            SET ordered_at = STR_TO_DATE(order_datetime, '%d-%m-%Y %h:%i %p')
            WHERE ordered_at IS NULL AND order_datetime IS NOT NULL AND order_datetime != ''
        ");
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn('ordered_at');
        });
    }
};
