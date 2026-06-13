<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // ── order_items: add price column ─────────────────────
        // VendorProductController::orders() uses item->price to show order totals.
        if (!Schema::hasColumn('order_items', 'price')) {
            Schema::table('order_items', function (Blueprint $table) {
                $table->decimal('price', 10, 2)->default(0)->after('quantity');
            });
        }

        // ── products: add is_active column ────────────────────
        // VendorProductController::updateStock() toggles is_active.
        if (!Schema::hasColumn('products', 'is_active')) {
            Schema::table('products', function (Blueprint $table) {
                $table->boolean('is_active')->default(true)->after('types');
            });
            // All existing products active by default
            DB::table('products')->update(['is_active' => 1]);
        }

        // ── products: add sub_category_id for legacy SQL compatibility ──
        if (!Schema::hasColumn('products', 'sub_category_id')) {
            Schema::table('products', function (Blueprint $table) {
                $table->unsignedBigInteger('sub_category_id')->nullable()->after('brand_id');
            });
        }

        // ── products: add vendor_id foreign key constraint ────
        // Migration 2026_06_11_000006 adds the column but no FK constraint.
        // Add it here safely (skip if already present).
        try {
            Schema::table('products', function (Blueprint $table) {
                $table->foreign('vendor_id')->references('id')->on('vendors')->onDelete('set null');
            });
        } catch (\Exception $e) {
            // Constraint already exists — ignore
        }

        // ── orders: add vendor_id foreign key constraint ───────
        try {
            Schema::table('orders', function (Blueprint $table) {
                $table->foreign('vendor_id')->references('id')->on('vendors')->onDelete('set null');
            });
        } catch (\Exception $e) {
            // Constraint already exists — ignore
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('order_items', 'price')) {
            Schema::table('order_items', function (Blueprint $table) {
                $table->dropColumn('price');
            });
        }
        if (Schema::hasColumn('products', 'is_active')) {
            Schema::table('products', function (Blueprint $table) {
                $table->dropColumn('is_active');
            });
        }
    }
};
