<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Freeze-once settlement model.
 *
 * Stores the immutable financial snapshot generated at checkout so that no app
 * (customer / vendor / delivery / admin) ever recomputes money. The customer
 * grand total is split across vendor_orders with a largest-remainder allocation
 * (see App\Services\SettlementService) such that the per-vendor collect amounts
 * always sum back to the frozen grand total — using whole-rupee integers only.
 *
 *   orders         → frozen coupon snapshot (immune to later coupon changes)
 *   vendor_orders  → frozen per-vendor shares + collect amount + COD collected
 */
return new class extends Migration
{
    public function up(): void
    {
        // ── Parent order: frozen coupon snapshot ───────────────────
        Schema::table('orders', function (Blueprint $table) {
            // coupon_code already exists. Snapshot the rest so the order is
            // reproducible even if the coupon is deleted/disabled/changed.
            if (!Schema::hasColumn('orders', 'coupon_title')) {
                $table->string('coupon_title', 150)->nullable()->after('coupon_code');
            }
            if (!Schema::hasColumn('orders', 'coupon_type')) {
                $table->string('coupon_type', 20)->nullable()->after('coupon_title'); // percent|flat
            }
            if (!Schema::hasColumn('orders', 'coupon_value')) {
                $table->decimal('coupon_value', 10, 2)->default(0)->after('coupon_type'); // % or ₹ as configured
            }
            if (!Schema::hasColumn('orders', 'coupon_discount')) {
                // Coupon-only discount in ₹ (separate from discount_amount, which
                // also includes MRP→selling savings). Frozen, whole rupees.
                $table->integer('coupon_discount')->default(0)->after('coupon_value');
            }
            if (!Schema::hasColumn('orders', 'settlement_frozen')) {
                $table->boolean('settlement_frozen')->default(false)->after('coupon_discount');
            }
        });

        // ── Vendor sub-order: frozen settlement shares ─────────────
        Schema::table('vendor_orders', function (Blueprint $table) {
            // Whole-rupee frozen values. items_subtotal (decimal) is kept as the
            // raw goods subtotal; goods_subtotal is its rounded integer form used
            // for settlement so everything reconciles in integers.
            if (!Schema::hasColumn('vendor_orders', 'goods_subtotal')) {
                $table->integer('goods_subtotal')->default(0)->after('items_subtotal');
            }
            if (!Schema::hasColumn('vendor_orders', 'coupon_share')) {
                $table->integer('coupon_share')->default(0)->after('goods_subtotal');
            }
            if (!Schema::hasColumn('vendor_orders', 'delivery_share')) {
                $table->integer('delivery_share')->default(0)->after('coupon_share');
            }
            if (!Schema::hasColumn('vendor_orders', 'handling_share')) {
                $table->integer('handling_share')->default(0)->after('delivery_share');
            }
            // The single authoritative number: what must be collected for this
            // vendor order = goods_subtotal - coupon_share + delivery + handling.
            if (!Schema::hasColumn('vendor_orders', 'collect_amount')) {
                $table->integer('collect_amount')->default(0)->after('handling_share');
            }
            // Per-vendor payment + COD collection tracking.
            if (!Schema::hasColumn('vendor_orders', 'payment_status')) {
                $table->string('payment_status', 20)->default('pending')->after('collect_amount'); // pending|paid|collected|failed
            }
            if (!Schema::hasColumn('vendor_orders', 'cod_collected_amount')) {
                $table->integer('cod_collected_amount')->nullable()->after('payment_status');
            }
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            foreach (['coupon_title', 'coupon_type', 'coupon_value', 'coupon_discount', 'settlement_frozen'] as $c) {
                if (Schema::hasColumn('orders', $c)) $table->dropColumn($c);
            }
        });
        Schema::table('vendor_orders', function (Blueprint $table) {
            foreach (['goods_subtotal', 'coupon_share', 'delivery_share', 'handling_share', 'collect_amount', 'payment_status', 'cod_collected_amount'] as $c) {
                if (Schema::hasColumn('vendor_orders', $c)) $table->dropColumn($c);
            }
        });
    }
};
