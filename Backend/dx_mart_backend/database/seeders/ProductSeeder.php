<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ProductSeeder extends Seeder
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
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('product_images')->truncate();
        DB::table('product_highlights')->truncate();
        DB::table('product_info')->truncate();
        DB::table('product_variants')->truncate();
        DB::table('products')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        $now = now();

        $productImages = $this->storageImageFiles('products');
        $productIndex  = 0;

        // Get category IDs by name (subcategories live in sub_category now)
        $cats = DB::table('main_category')->pluck('id', 'name');
        $subs = DB::table('sub_category')->pluck('id', 'name');

        // Get vendor IDs
        $vendors = DB::table('vendors')->pluck('id', 'email');
        $ravi    = $vendors['ravi@vendor.com']   ?? null;
        $meena   = $vendors['meena@vendor.com']  ?? null;
        $deepak  = $vendors['deepak@vendor.com'] ?? null;

        // Fallbacks in case category names don't match exactly
        $catFruitsVeg   = $cats['Fruits & Vegetables']    ?? null;
        $catDairy       = $cats['Dairy, Bread & Eggs']    ?? null;
        $catAtta        = $cats['Atta, Rice, Oil & Dals'] ?? null;
        $catMasala      = $cats['Masala & Dry Fruits']    ?? null;
        $catPackaged    = $cats['Packaged Food']           ?? null;
        $catElec        = $cats['Electronics & Appliances'] ?? null;
        $catBreakfast   = $cats['Breakfast & Sauces']     ?? null;
        $catSweet       = $cats['Sweet Cravings']          ?? null;
        $catTea         = $cats['Tea, Coffee & More']      ?? null;

        $subFresh    = $subs['Fresh Fruits']      ?? null;
        $subVeggies  = $subs['Fresh Vegetables']  ?? null;
        $subMilk     = $subs['Milk']              ?? null;
        $subBread    = $subs['Bread & Buns']      ?? null;
        $subPaneer   = $subs['Paneer & Tofu']     ?? null;
        $subRice     = $subs['Rice']              ?? null;
        $subOil      = $subs['Cooking Oil']       ?? null;
        $subDal      = $subs['Dals & Pulses']     ?? null;
        $subMasala   = $subs['Blended Masala']    ?? null;
        $subNoodle   = $subs['Instant Noodles']   ?? null;
        $subKitchen  = $subs['Kitchen Appliances'] ?? null;
        $subCookware = $subs['Cookware']           ?? null;
        $subTea      = $subs['Tea']               ?? null;
        $subChoc     = $subs['Chocolates']        ?? null;
        $subBiscuit  = $subs['Cookies & Biscuits'] ?? null;

        $products = [
            // ── Fruits & Vegetables (Ravi) ───────────────────────
            [
                'p' => ['name' => 'Alphonso Mangoes', 'description' => 'Premium Alphonso mangoes from Ratnagiri. Sweet, pulpy and aromatic. 1 dozen box.', 'main_category_id' => $catFruitsVeg, 'subcategory_id' => $subFresh, 'types' => 'fresh,best_selling', 'is_active' => 1, 'vendor_id' => $ravi],
                'v' => [
                    ['name' => '1 Dozen (12 pcs)', 'price' => 450, 'selling_price' => 399, 'stock' => 50],
                    ['name' => '2 Dozen (24 pcs)', 'price' => 850, 'selling_price' => 749, 'stock' => 30],
                ],
            ],
            [
                'p' => ['name' => 'Banana (Robusta)', 'description' => 'Fresh robusta bananas. Rich in potassium and natural sugars. Best for breakfast.', 'main_category_id' => $catFruitsVeg, 'subcategory_id' => $subFresh, 'types' => 'fresh,everyday_essentials', 'is_active' => 1, 'vendor_id' => $ravi],
                'v' => [
                    ['name' => '6 pcs', 'price' => 40,  'selling_price' => 35,  'stock' => 100],
                    ['name' => '12 pcs', 'price' => 75, 'selling_price' => 65,  'stock' => 80],
                ],
            ],
            [
                'p' => ['name' => 'Tomato (Country)', 'description' => 'Farm-fresh country tomatoes. Ideal for curries, salads and chutneys.', 'main_category_id' => $catFruitsVeg, 'subcategory_id' => $subVeggies, 'types' => 'fresh,everyday_essentials', 'is_active' => 1, 'vendor_id' => $ravi],
                'v' => [
                    ['name' => '500g', 'price' => 30,  'selling_price' => 25, 'stock' => 200],
                    ['name' => '1 kg',  'price' => 55,  'selling_price' => 45, 'stock' => 150],
                ],
            ],
            [
                'p' => ['name' => 'Potato (White)', 'description' => 'Fresh white potatoes. Great for sabzi, fries and curries.', 'main_category_id' => $catFruitsVeg, 'subcategory_id' => $subVeggies, 'types' => 'fresh,everyday_essentials', 'is_active' => 1, 'vendor_id' => $ravi],
                'v' => [
                    ['name' => '1 kg',  'price' => 35, 'selling_price' => 28, 'stock' => 200],
                    ['name' => '3 kg',  'price' => 99, 'selling_price' => 79, 'stock' => 100],
                    ['name' => '5 kg',  'price' => 155, 'selling_price' => 125, 'stock' => 60],
                ],
            ],
            [
                'p' => ['name' => 'Onion (Red)', 'description' => 'Red onions sourced from Nashik. Strong flavour, perfect for Indian cooking.', 'main_category_id' => $catFruitsVeg, 'subcategory_id' => $subVeggies, 'types' => 'fresh,everyday_essentials', 'is_active' => 1, 'vendor_id' => $ravi],
                'v' => [
                    ['name' => '1 kg',  'price' => 40, 'selling_price' => 32, 'stock' => 180],
                    ['name' => '3 kg',  'price' => 110, 'selling_price' => 90, 'stock' => 80],
                ],
            ],
            // ── Dairy (Ravi) ─────────────────────────────────────
            [
                'p' => ['name' => 'Full Cream Milk', 'description' => 'Fresh full-cream toned milk. Rich in calcium and protein. Pasteurised and hygienically packed.', 'main_category_id' => $catDairy, 'subcategory_id' => $subMilk, 'types' => 'everyday_essentials', 'is_active' => 1, 'vendor_id' => $ravi],
                'v' => [
                    ['name' => '500ml', 'price' => 28, 'selling_price' => 26, 'stock' => 150],
                    ['name' => '1 litre', 'price' => 54, 'selling_price' => 50, 'stock' => 200],
                ],
            ],
            [
                'p' => ['name' => 'Whole Wheat Bread', 'description' => 'Soft whole wheat bread. No artificial colours. Best with butter or jam.', 'main_category_id' => $catDairy, 'subcategory_id' => $subBread, 'types' => 'everyday_essentials', 'is_active' => 1, 'vendor_id' => $ravi],
                'v' => [
                    ['name' => '400g (18 slices)', 'price' => 45, 'selling_price' => 40, 'stock' => 100],
                ],
            ],
            [
                'p' => ['name' => 'Fresh Paneer', 'description' => 'Soft, fresh cottage cheese made from full cream milk. Perfect for paneer dishes.', 'main_category_id' => $catDairy, 'subcategory_id' => $subPaneer, 'types' => 'fresh,best_selling', 'is_active' => 1, 'vendor_id' => $ravi],
                'v' => [
                    ['name' => '200g', 'price' => 80,  'selling_price' => 72, 'stock' => 80],
                    ['name' => '500g', 'price' => 190, 'selling_price' => 170, 'stock' => 50],
                ],
            ],
            // ── Atta, Rice, Oil & Dals (Meena) ──────────────────
            [
                'p' => ['name' => 'Basmati Rice (Long Grain)', 'description' => 'Premium aged long-grain basmati rice. Perfect for biryanis, pulao and special occasions.', 'main_category_id' => $catAtta, 'subcategory_id' => $subRice, 'types' => 'best_selling', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '1 kg',  'price' => 150, 'selling_price' => 129, 'stock' => 100],
                    ['name' => '5 kg',  'price' => 700, 'selling_price' => 599, 'stock' => 50],
                    ['name' => '10 kg', 'price' => 1350, 'selling_price' => 1149, 'stock' => 25],
                ],
            ],
            [
                'p' => ['name' => 'Sunflower Cooking Oil', 'description' => 'Refined sunflower oil. Light and healthy for everyday Indian cooking.', 'main_category_id' => $catAtta, 'subcategory_id' => $subOil, 'types' => 'everyday_essentials', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '1 litre', 'price' => 160, 'selling_price' => 145, 'stock' => 80],
                    ['name' => '5 litres', 'price' => 775, 'selling_price' => 699, 'stock' => 40],
                ],
            ],
            [
                'p' => ['name' => 'Toor Dal (Arhar)', 'description' => 'Unpolished split pigeon peas. Protein-rich, easy to cook. Ideal for dal tadka.', 'main_category_id' => $catAtta, 'subcategory_id' => $subDal, 'types' => 'everyday_essentials', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '500g', 'price' => 75,  'selling_price' => 65,  'stock' => 100],
                    ['name' => '1 kg',  'price' => 145, 'selling_price' => 125, 'stock' => 80],
                    ['name' => '5 kg',  'price' => 690, 'selling_price' => 599, 'stock' => 30],
                ],
            ],
            // ── Masala & Dry Fruits (Meena) ──────────────────────
            [
                'p' => ['name' => 'Garam Masala', 'description' => 'Aromatic blend of whole spices ground fresh. Adds rich flavour to curries and biryanis.', 'main_category_id' => $catMasala, 'subcategory_id' => $subMasala, 'types' => 'best_selling', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '100g', 'price' => 65, 'selling_price' => 55, 'stock' => 120],
                    ['name' => '250g', 'price' => 150, 'selling_price' => 125, 'stock' => 60],
                ],
            ],
            [
                'p' => ['name' => 'Turmeric Powder (Haldi)', 'description' => 'Pure ground turmeric with high curcumin content. Bright colour and strong aroma.', 'main_category_id' => $catMasala, 'subcategory_id' => $subMasala, 'types' => 'everyday_essentials', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '100g', 'price' => 40, 'selling_price' => 34, 'stock' => 150],
                    ['name' => '200g', 'price' => 75, 'selling_price' => 62, 'stock' => 80],
                ],
            ],
            // ── Packaged Food (Meena) ────────────────────────────
            [
                'p' => ['name' => 'Maggi 2-Minute Noodles', 'description' => 'India\'s favourite instant noodles. Ready in 2 minutes. Original masala flavour.', 'main_category_id' => $catPackaged, 'subcategory_id' => $subNoodle, 'types' => 'best_selling,daily_deals', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '70g (single)',   'price' => 14, 'selling_price' => 13, 'stock' => 300],
                    ['name' => '4-pack (280g)',  'price' => 56, 'selling_price' => 50, 'stock' => 150],
                    ['name' => '12-pack (840g)', 'price' => 165, 'selling_price' => 148, 'stock' => 80],
                ],
            ],
            // ── Electronics (Deepak) ─────────────────────────────
            [
                'p' => ['name' => 'Mixer Grinder 750W', 'description' => 'Powerful 750W mixer grinder with 3 stainless steel jars. Ideal for wet and dry grinding.', 'main_category_id' => $catElec, 'subcategory_id' => $subKitchen, 'types' => 'best_selling', 'is_active' => 1, 'vendor_id' => $deepak],
                'v' => [
                    ['name' => 'White (750W)',  'price' => 3500, 'selling_price' => 2799, 'stock' => 20],
                    ['name' => 'Black (750W)',  'price' => 3500, 'selling_price' => 2799, 'stock' => 15],
                ],
            ],
            [
                'p' => ['name' => 'Non-stick Kadai Set', 'description' => 'Premium 3-piece non-stick kadai set. PFOA-free coating. Induction compatible.', 'main_category_id' => $catElec, 'subcategory_id' => $subCookware, 'types' => 'hot_deals,daily_deals', 'is_active' => 1, 'vendor_id' => $deepak],
                'v' => [
                    ['name' => '24cm + 28cm + 32cm', 'price' => 2199, 'selling_price' => 1599, 'stock' => 25],
                ],
            ],
            // ── Tea & Coffee (Meena) ─────────────────────────────
            [
                'p' => ['name' => 'Darjeeling Green Tea', 'description' => 'First-flush Darjeeling green tea. Light, floral and refreshing. Rich in antioxidants.', 'main_category_id' => $catTea, 'subcategory_id' => $subTea, 'types' => 'handpicked', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '25 tea bags', 'price' => 120, 'selling_price' => 99,  'stock' => 80],
                    ['name' => '50 tea bags', 'price' => 230, 'selling_price' => 189, 'stock' => 50],
                ],
            ],
            // ── Sweet Cravings (Meena) ───────────────────────────
            [
                'p' => ['name' => 'Dairy Milk Silk Chocolate', 'description' => 'Smooth, creamy Cadbury Dairy Milk Silk bar. The perfect gifting chocolate.', 'main_category_id' => $catSweet, 'subcategory_id' => $subChoc, 'types' => 'best_selling,hot_deals', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '58g',  'price' => 80,  'selling_price' => 75,  'stock' => 150],
                    ['name' => '145g', 'price' => 190, 'selling_price' => 175, 'stock' => 80],
                ],
            ],
            [
                'p' => ['name' => 'Britannia Good Day Cashew Cookies', 'description' => 'Buttery cookies loaded with premium cashew pieces. A great snack for tea time.', 'main_category_id' => $catSweet, 'subcategory_id' => $subBiscuit, 'types' => 'everyday_essentials', 'is_active' => 1, 'vendor_id' => $meena],
                'v' => [
                    ['name' => '75g',  'price' => 25, 'selling_price' => 22, 'stock' => 200],
                    ['name' => '240g', 'price' => 75, 'selling_price' => 68, 'stock' => 120],
                ],
            ],
        ];

        // Maps the legacy snake_case type tokens to the product_types table's
        // display names, so product-type sections (which match by display name)
        // actually resolve products.
        $typeMap = [
            'best_selling'        => 'Best Selling',
            'everyday_essentials' => 'Everyday Essentials',
            'hot_deals'           => 'Hot Deals',
            'handpicked'          => 'Handpicked You 💝',
            'fresh'               => 'Fresh Arrivals',
            'daily_deals'         => 'Daily Deals',
        ];
        $normalizeTypes = function (?string $types) use ($typeMap): string {
            if (!$types) return '';
            $names = [];
            foreach (explode(',', $types) as $t) {
                $t = trim($t);
                if ($t === '') continue;
                $names[] = $typeMap[$t] ?? $t;
            }
            return implode(', ', array_unique($names));
        };

        foreach ($products as $entry) {
            $pd = $entry['p'];
            if (isset($pd['types'])) $pd['types'] = $normalizeTypes($pd['types']);
            $productImage = $productImages[$productIndex % max(1, count($productImages))] ?? null;
            $pd['image_url'] = $productImage;
            $pd['icon_url'] = $productImage;
            $pd['created_at'] = $now;
            $pd['updated_at'] = $now;
            $productId = DB::table('products')->insertGetId($pd);

            if ($productImage) {
                DB::table('product_images')->insert([
                    'product_id' => $productId,
                    'image_url' => $productImage,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }

            foreach ($entry['v'] as $variant) {
                DB::table('product_variants')->insert(array_merge($variant, [
                    'product_id' => $productId,
                    'wholesale_price' => $variant['selling_price'] * 0.8,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]));
            }

            $productIndex++;
        }
    }
}
