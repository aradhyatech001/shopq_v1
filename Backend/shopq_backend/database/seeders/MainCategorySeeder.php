<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use App\Models\MainCategory;

class MainCategorySeeder extends Seeder
{
    private function storageImageFiles(string $folder): array
    {
        return collect(Storage::disk('public')->files($folder))
            ->filter(fn ($file) => preg_match('/\.(png|jpe?g|webp)$/i', $file))
            ->values()
            ->all();
    }

    public function run(): void
    {
        // ── Main Categories ───────────────────────────────────
        $mainCategories = [
            ['name' => 'Atta, Rice, Oil & Dals',  'position' => 1],
            ['name' => 'Breakfast & Sauces',       'position' => 2],
            ['name' => 'Dairy, Bread & Eggs',      'position' => 3],
            ['name' => 'Electronics & Appliances', 'position' => 4],
            ['name' => 'Fruits & Vegetables',      'position' => 5],
            ['name' => 'Ice Creams & More',        'position' => 6],
            ['name' => 'Kitchen & Dining',         'position' => 7],
            ['name' => 'Masala & Dry Fruits',      'position' => 8],
            ['name' => 'Frozen Food',              'position' => 9],
            ['name' => 'Sweet Cravings',           'position' => 10],
            ['name' => 'Tea, Coffee & More',       'position' => 11],
            ['name' => 'Packaged Food',            'position' => 12],
        ];

        $categoryImages     = $this->storageImageFiles('categories');
        $subcategoryImages = $this->storageImageFiles('subcategories');

        foreach ($mainCategories as $index => $cat) {
            $image = $categoryImages[$index % max(1, count($categoryImages))] ?? null;

            MainCategory::updateOrCreate(
                ['name' => $cat['name']],
                ['position' => $cat['position'], 'is_active' => 1, 'image' => $image, 'icon_url' => $image]
            );
        }

        // ── Subcategories map: main category name => [subcategory names] ──
        $subcategoryMap = [
            'Atta, Rice, Oil & Dals' => [
                'Atta & Flour',
                'Rice',
                'Cooking Oil',
                'Dals & Pulses',
                'Ghee',
                'Suji, Maida & Besan',
            ],
            'Breakfast & Sauces' => [
                'Cereals & Muesli',
                'Ketchup & Sauces',
                'Peanut Butter & Jam',
                'Honey & Spreads',
                'Oats & Porridge',
                'Energy & Health Bars',
            ],
            'Dairy, Bread & Eggs' => [
                'Milk',
                'Butter & Cream',
                'Paneer & Tofu',
                'Curd & Yogurt',
                'Bread & Buns',
                'Eggs',
                'Cheese',
                'Dairy Whitener',
            ],
            'Electronics & Appliances' => [
                'Bulbs & Lighting',
                'Kitchen Appliances',
                'Mixer & Grinder',
                'Smartwatches',
                'Speakers & Audio',
                'Fans & Coolers',
            ],
            'Fruits & Vegetables' => [
                'Fresh Fruits',
                'Fresh Vegetables',
                'Leafy Greens',
                'Exotic Fruits',
                'Organic Produce',
            ],
            'Ice Creams & More' => [
                'Ice Creams',
                'Kulfi',
                'Ice Cream Bars',
                'Frozen Desserts',
            ],
            'Kitchen & Dining' => [
                'Cookware',
                'Storage Containers',
                'Dinner Sets',
                'Kitchen Tools',
                'Bakeware',
            ],
            'Masala & Dry Fruits' => [
                'Whole Spices',
                'Blended Masala',
                'Salt & Sugar',
                'Almonds & Cashews',
                'Raisins & Dates',
                'Seeds & Superfoods',
            ],
            'Frozen Food' => [
                'Frozen Vegetables',
                'Frozen Snacks',
                'Frozen Parathas',
                'Frozen Meat & Seafood',
            ],
            'Sweet Cravings' => [
                'Chocolates',
                'Cookies & Biscuits',
                'Cakes & Pastries',
                'Mithai & Sweets',
                'Candies & Gummies',
            ],
            'Tea, Coffee & More' => [
                'Tea',
                'Coffee',
                'Green Tea',
                'Health Drinks',
                'Juices & Shakes',
            ],
            'Packaged Food' => [
                'Instant Noodles',
                'Ready to Cook',
                'Chips & Namkeen',
                'Canned & Tinned',
                'Pasta & Vermicelli',
                'Soups & Broths',
            ],
        ];

        // ── Insert Subcategories ───────────────────────────────
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('sub_category')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        foreach ($subcategoryMap as $parentName => $subs) {
            $parent = MainCategory::where('name', $parentName)->first();

            if (!$parent) {
                $this->command->warn("Parent category not found: $parentName — skipping");
                continue;
            }

            // Subcategories live ONLY in the sub_category table now.
            foreach ($subs as $position => $subName) {
                $subImage = $subcategoryImages[$position % max(1, count($subcategoryImages))] ?? null;

                DB::table('sub_category')->updateOrInsert(
                    ['main_category_id' => $parent->id, 'name' => $subName],
                    [
                        'image_url' => $subImage,
                        'icon_url'  => $subImage,
                        'position'  => $position + 1,
                        'is_active' => 1,
                        'created_at' => now(),
                    ]
                );
            }

            $this->command->info("✓ Subcategories seeded for: $parentName");
        }
    }
}
