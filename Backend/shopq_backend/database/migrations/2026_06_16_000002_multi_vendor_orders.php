<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

/**
 * Multi-vendor marketplace order model + vendor-managed delivery flow.
 *
 * Keeps `orders` as the parent (one customer payment) and introduces
 * `vendor_orders` (one sub-order per vendor) carrying their own status,
 * commission, payout, delivery boy and tracking. order_items are tagged to a
 * vendor_order. Existing orders are backfilled into one vendor_order each.
 */
return new class extends Migration
{
    public function up(): void
    {
        // ── orders (parent): payment + derived status ──────────────
        Schema::table('orders', function (Blueprint $table) {
            if (!Schema::hasColumn('orders', 'payment_status')) {
                $table->string('payment_status', 20)->default('pending')->after('payment_method');
            }
            if (!Schema::hasColumn('orders', 'derived_status')) {
                $table->string('derived_status', 30)->default('pending')->after('status');
            }
        });

        // ── vendor_orders (NEW): per-vendor sub-order ──────────────
        if (!Schema::hasTable('vendor_orders')) {
            Schema::create('vendor_orders', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('parent_order_id');
                $table->unsignedBigInteger('vendor_id');
                // pending|confirmed|packed|assigned|out_for_delivery|delivered|cancelled
                $table->string('status', 20)->default('pending');
                $table->decimal('items_subtotal', 10, 2)->default(0);
                $table->decimal('commission_rate', 5, 2)->default(0);
                $table->decimal('commission_amount', 10, 2)->default(0);
                $table->decimal('vendor_earning', 10, 2)->default(0);
                // Vendor-managed delivery
                $table->unsignedBigInteger('delivery_boy_id')->nullable();
                $table->string('tracking_number', 100)->nullable();
                $table->string('courier_name', 100)->nullable();
                $table->string('cancel_reason', 255)->nullable();
                $table->unsignedBigInteger('payout_id')->nullable();
                $table->timestamp('confirmed_at')->nullable();
                $table->timestamp('packed_at')->nullable();
                $table->timestamp('assigned_at')->nullable();
                $table->timestamp('picked_up_at')->nullable();
                $table->timestamp('out_for_delivery_at')->nullable();
                $table->timestamp('delivered_at')->nullable();
                $table->timestamp('cancelled_at')->nullable();
                $table->timestamps();

                $table->unique(['parent_order_id', 'vendor_id']);
                $table->index(['vendor_id', 'status']);
                $table->foreign('parent_order_id')->references('id')->on('orders')->onDelete('cascade');
            });
        }

        // ── order_items: link to a sub-order + denormalized vendor ──
        Schema::table('order_items', function (Blueprint $table) {
            if (!Schema::hasColumn('order_items', 'vendor_order_id')) {
                $table->unsignedBigInteger('vendor_order_id')->nullable()->after('order_id');
                $table->index('vendor_order_id');
            }
            if (!Schema::hasColumn('order_items', 'vendor_id')) {
                $table->unsignedBigInteger('vendor_id')->nullable()->after('product_id');
            }
        });

        // ── vendor_payouts (NEW) ───────────────────────────────────
        if (!Schema::hasTable('vendor_payouts')) {
            Schema::create('vendor_payouts', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('vendor_id');
                $table->decimal('amount', 10, 2)->default(0);
                $table->string('status', 20)->default('pending'); // pending|processing|paid|failed
                $table->date('period_start')->nullable();
                $table->date('period_end')->nullable();
                $table->string('reference', 100)->nullable();
                $table->timestamp('paid_at')->nullable();
                $table->timestamps();
                $table->index(['vendor_id', 'status']);
            });
        }

        // ── order_status_history (NEW): audit + tracking timeline ──
        if (!Schema::hasTable('order_status_history')) {
            Schema::create('order_status_history', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('parent_order_id');
                $table->unsignedBigInteger('vendor_order_id')->nullable();
                $table->string('actor_type', 20)->default('system'); // vendor|admin|system|customer
                $table->unsignedBigInteger('actor_id')->nullable();
                $table->string('from_status', 20)->nullable();
                $table->string('to_status', 20)->nullable();
                $table->string('note', 255)->nullable();
                $table->timestamp('created_at')->nullable();
                $table->index('parent_order_id');
                $table->index('vendor_order_id');
            });
        }

        // ── refunds (NEW): partial refunds per sub-order ───────────
        if (!Schema::hasTable('refunds')) {
            Schema::create('refunds', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('parent_order_id');
                $table->unsignedBigInteger('vendor_order_id')->nullable();
                $table->decimal('amount', 10, 2)->default(0);
                $table->string('reason', 255)->nullable();
                $table->string('status', 20)->default('requested'); // requested|approved|processed|rejected
                $table->timestamp('processed_at')->nullable();
                $table->timestamps();
                $table->index('parent_order_id');
            });
        }

        // ── vendors: commission + payout target ────────────────────
        Schema::table('vendors', function (Blueprint $table) {
            if (!Schema::hasColumn('vendors', 'commission_rate')) {
                $table->decimal('commission_rate', 5, 2)->nullable()->after('status');
            }
            if (!Schema::hasColumn('vendors', 'payout_account')) {
                $table->string('payout_account', 150)->nullable()->after('commission_rate');
            }
        });

        // ── Backfill existing orders → one vendor_order per vendor ──
        $this->backfill();
    }

    private function backfill(): void
    {
        // Only run once: skip if vendor_orders already populated.
        if (DB::table('vendor_orders')->count() > 0) return;

        $orders = DB::table('orders')->get();
        foreach ($orders as $order) {
            // Group this order's items by their product's vendor.
            $rows = DB::select("
                SELECT oi.id AS item_id, oi.quantity, oi.price, p.vendor_id
                FROM order_items oi
                JOIN products p ON p.id = oi.product_id
                WHERE oi.order_id = ?
            ", [$order->id]);

            $byVendor = [];
            foreach ($rows as $r) {
                $vid = $r->vendor_id ?: 0; // 0 = platform/no-vendor bucket
                $byVendor[$vid] ??= ['subtotal' => 0, 'item_ids' => []];
                $byVendor[$vid]['subtotal'] += (float) $r->price * (int) $r->quantity;
                $byVendor[$vid]['item_ids'][] = $r->item_id;
            }

            foreach ($byVendor as $vid => $info) {
                if ($vid == 0) {
                    // No vendor — just stamp items, no sub-order.
                    DB::table('order_items')->whereIn('id', $info['item_ids'])
                        ->update(['vendor_id' => null]);
                    continue;
                }
                $voId = DB::table('vendor_orders')->insertGetId([
                    'parent_order_id'  => $order->id,
                    'vendor_id'        => $vid,
                    'status'           => $order->status ?: 'pending',
                    'items_subtotal'   => $info['subtotal'],
                    'commission_rate'  => 0,
                    'commission_amount'=> 0,
                    'vendor_earning'   => $info['subtotal'],
                    'created_at'       => now(),
                    'updated_at'       => now(),
                ]);
                DB::table('order_items')->whereIn('id', $info['item_ids'])->update([
                    'vendor_order_id' => $voId,
                    'vendor_id'       => $vid,
                ]);
            }

            // Seed the parent's derived status from its single stored status.
            DB::table('orders')->where('id', $order->id)
                ->update(['derived_status' => $order->status ?: 'pending']);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('refunds');
        Schema::dropIfExists('order_status_history');
        Schema::dropIfExists('vendor_payouts');

        Schema::table('order_items', function (Blueprint $table) {
            foreach (['vendor_order_id', 'vendor_id'] as $c) {
                if (Schema::hasColumn('order_items', $c)) $table->dropColumn($c);
            }
        });
        Schema::dropIfExists('vendor_orders');

        Schema::table('orders', function (Blueprint $table) {
            foreach (['payment_status', 'derived_status'] as $c) {
                if (Schema::hasColumn('orders', $c)) $table->dropColumn($c);
            }
        });
        Schema::table('vendors', function (Blueprint $table) {
            foreach (['commission_rate', 'payout_account'] as $c) {
                if (Schema::hasColumn('vendors', $c)) $table->dropColumn($c);
            }
        });
    }
};
