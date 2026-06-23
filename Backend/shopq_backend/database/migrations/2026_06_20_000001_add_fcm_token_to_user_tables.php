<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        foreach (['users', 'vendors', 'delivery_boy'] as $tbl) {
            if (!Schema::hasColumn($tbl, 'fcm_token')) {
                Schema::table($tbl, fn(Blueprint $t) => $t->string('fcm_token')->nullable());
            }
        }
    }

    public function down(): void
    {
        foreach (['users', 'vendors', 'delivery_boy'] as $tbl) {
            if (Schema::hasColumn($tbl, 'fcm_token')) {
                Schema::table($tbl, fn(Blueprint $t) => $t->dropColumn('fcm_token'));
            }
        }
    }
};
