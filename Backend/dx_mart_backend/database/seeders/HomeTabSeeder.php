<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\MainCategory;

class HomeTabSeeder extends Seeder
{
    public function run(): void
    {
        // Tab types: all (full home), category (main category + subcategories),
        // none (themed/section-only). Idempotent by name; sections are seeded
        // separately by HomeSectionsSeeder.
        $fresh = MainCategory::whereNull('parent_id')
            ->where('name', 'like', '%Fruits%')->value('id');

        $tabs = [
            ['name' => 'All',         'icon' => 'all',     'type' => 'all',      'category_id' => null,   'bg_color' => '#6C63FF', 'position' => 0],
            ['name' => 'Fresh',       'icon' => 'apple',   'type' => 'category', 'category_id' => $fresh, 'bg_color' => '#2DB87B', 'position' => 1],
            ['name' => 'Daily Deals', 'icon' => 'deals',   'type' => 'none',     'category_id' => null,   'bg_color' => '#FF8C42', 'position' => 2],
        ];

        foreach ($tabs as $tab) {
            DB::table('home_tabs')->updateOrInsert(
                ['name' => $tab['name']],
                [
                    'icon'        => $tab['icon'],
                    'type'        => $tab['type'],
                    'category_id' => $tab['category_id'],
                    'bg_color'    => $tab['bg_color'],
                    'position'    => $tab['position'],
                    'is_active'   => 1,
                ]
            );
        }
    }
}
