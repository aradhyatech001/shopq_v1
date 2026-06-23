<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (!$this->indexExists('orders', 'orders_user_id_index')) {
                $table->index('user_id');
            }
            if (!$this->indexExists('orders', 'orders_status_index')) {
                $table->index('status');
            }
        });

        Schema::table('cart_items', function (Blueprint $table) {
            if (!$this->indexExists('cart_items', 'cart_items_user_id_index')) {
                $table->index('user_id');
            }
        });

        Schema::table('wishlist', function (Blueprint $table) {
            if (!$this->indexExists('wishlist', 'wishlist_user_id_index')) {
                $table->index('user_id');
            }
        });

        Schema::table('order_items', function (Blueprint $table) {
            if (!$this->indexExists('order_items', 'order_items_order_id_index')) {
                $table->index('order_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('orders',      fn(Blueprint $t) => $t->dropIndex(['user_id']));
        Schema::table('orders',      fn(Blueprint $t) => $t->dropIndex(['status']));
        Schema::table('cart_items',  fn(Blueprint $t) => $t->dropIndex(['user_id']));
        Schema::table('wishlist',    fn(Blueprint $t) => $t->dropIndex(['user_id']));
        Schema::table('order_items', fn(Blueprint $t) => $t->dropIndex(['order_id']));
    }

    private function indexExists(string $table, string $index): bool
    {
        return collect(\Illuminate\Support\Facades\DB::select("SHOW INDEX FROM `{$table}`"))
            ->contains('Key_name', $index);
    }
};
