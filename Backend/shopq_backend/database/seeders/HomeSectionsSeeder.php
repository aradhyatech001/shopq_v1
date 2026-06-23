<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\HomeTab;

class HomeSectionsSeeder extends Seeder
{
    /// Resolves a home_tab id by name (seeded by HomeTabSeeder).
    private function tabId(string $name): ?int
    {
        return HomeTab::where('name', $name)->value('id');
    }

    public function run(): void
    {
        $all   = $this->tabId('All');
        $fresh = $this->tabId('Fresh');
        $deals = $this->tabId('Daily Deals');

        // Each tab's storefront, top to bottom. Sections are tab-scoped via
        // home_tab_id; product rows inherit the tab's category.
        $layout = [];

        if ($all) {
            $layout = array_merge($layout, [
                ['home_tab_id' => $all, 'title' => 'Shop by Category', 'section_type' => 'category_grid', 'product_limit' => 8,  'position' => 1],
                ['home_tab_id' => $all, 'title' => 'Best Selling',     'section_type' => 'product_type', 'product_type' => 'Best Selling', 'product_limit' => 10, 'position' => 2],
                ['home_tab_id' => $all, 'title' => 'Daily Deals',      'section_type' => 'product_type', 'product_type' => 'Daily Deals', 'product_limit' => 10, 'position' => 3],
                ['home_tab_id' => $all, 'title' => 'Brands You Love',  'section_type' => 'brand_grid',   'product_limit' => 12, 'position' => 4],
                ['home_tab_id' => $all, 'title' => 'Hot Deals',        'section_type' => 'product_type', 'product_type' => 'Hot Deals', 'product_limit' => 10, 'position' => 5],
                ['home_tab_id' => $all, 'title' => 'Shops Near You',   'section_type' => 'shop_grid',    'product_limit' => 10, 'position' => 6],
            ]);
        }
        if ($fresh) {
            $layout = array_merge($layout, [
                ['home_tab_id' => $fresh, 'title' => 'Fresh Categories', 'section_type' => 'category_grid', 'product_limit' => 8,  'position' => 1],
                ['home_tab_id' => $fresh, 'title' => 'Best of Fresh',    'section_type' => 'products',      'product_limit' => 10, 'position' => 2],
            ]);
        }
        if ($deals) {
            $layout = array_merge($layout, [
                ['home_tab_id' => $deals, 'title' => 'Daily Deals', 'section_type' => 'product_type', 'product_type' => 'Daily Deals', 'product_limit' => 10, 'position' => 1],
                ['home_tab_id' => $deals, 'title' => 'Hot Deals',   'section_type' => 'product_type', 'product_type' => 'Hot Deals', 'product_limit' => 10, 'position' => 2],
            ]);
        }

        // Remove legacy non-tab-scoped sections (pre tab-scoping model) and
        // refresh the seeded tabs' sections (don't wipe admin-built ones on
        // other tabs).
        DB::table('home_sections')->whereNull('home_tab_id')->delete();
        $tabIds = array_values(array_filter([$all, $fresh, $deals]));
        if (!empty($tabIds)) {
            DB::table('home_sections')->whereIn('home_tab_id', $tabIds)->delete();
        }

        foreach ($layout as $s) {
            DB::table('home_sections')->insert(array_merge([
                'emoji' => null, 'banner_image' => null, 'product_type' => null,
                'main_category_id' => null, 'subcategory_id' => null, 'brand_id' => null,
                'link_category_id' => null, 'is_active' => 1,
                'created_at' => now(), 'updated_at' => now(),
            ], $s));
        }
    }
}
