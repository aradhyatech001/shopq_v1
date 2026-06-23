<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('app_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->text('value')->nullable();
            $table->timestamps();
        });

        // Defaults match the current hardcoded user-app theme so nothing changes
        // visually until an admin edits them.
        $defaults = [
            'primary_color'      => '#F5BF14',
            'secondary_color'    => '#FFC63A',
            'app_name'           => 'ShopQ',
            'delivery_time_text' => '24 Min',
            'free_delivery_text' => '₹0 delivery fee',
            'search_hint'        => 'Search for "Milk"',
            'assurance_1'        => 'Lowest Prices',
            'assurance_2'        => 'Quality Checked',
            'assurance_3'        => 'Easy Returns',
        ];
        $now = now();
        foreach ($defaults as $k => $v) {
            DB::table('app_settings')->insert([
                'key' => $k, 'value' => $v, 'created_at' => $now, 'updated_at' => $now,
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('app_settings');
    }
};
