-- ============================================================
-- DxMart Subcategory Seeds
-- Run in phpMyAdmin on digixcod_dxmart database
-- Step 1: Add parent_id to main_category (if not exists)
-- Step 2: Insert subcategories linked to main categories
-- ============================================================

-- STEP 1: Add parent_id column
ALTER TABLE `main_category`
  ADD COLUMN IF NOT EXISTS `parent_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `description` VARCHAR(255) NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `is_active` TINYINT(1) NOT NULL DEFAULT 1;

-- ============================================================
-- STEP 2: Insert subcategories
-- parent_id auto-linked by matching main category name
-- ============================================================

-- ── Fruits & Vegetables ──────────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Fresh Fruits',         (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Fruit%' AND parent_id IS NULL LIMIT 1) t), 1),
('Fresh Vegetables',     (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Vegetable%' AND parent_id IS NULL LIMIT 1) t), 1),
('Exotic Fruits & Veggies', (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Fruit%' AND parent_id IS NULL LIMIT 1) t), 1),
('Herbs & Seasonings',  (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Fruit%' AND parent_id IS NULL LIMIT 1) t), 1),
('Flowers & Leaves',    (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Fruit%' AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Dairy, Bread & Eggs ──────────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Milk',                (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Dairy%' AND parent_id IS NULL LIMIT 1) t), 1),
('Butter & Cream',      (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Dairy%' AND parent_id IS NULL LIMIT 1) t), 1),
('Paneer & Tofu',       (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Dairy%' AND parent_id IS NULL LIMIT 1) t), 1),
('Curd & Yogurt',       (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Dairy%' AND parent_id IS NULL LIMIT 1) t), 1),
('Eggs',                (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Dairy%' AND parent_id IS NULL LIMIT 1) t), 1),
('Bread & Pav',         (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Dairy%' AND parent_id IS NULL LIMIT 1) t), 1),
('Cheese',              (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Dairy%' AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Atta, Rice, Oil & Dals ───────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Atta & Flours',       (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Atta%' AND parent_id IS NULL LIMIT 1) t), 1),
('Rice & Rice Products',(SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Rice%' AND parent_id IS NULL LIMIT 1) t), 1),
('Dals & Pulses',       (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Dal%' AND parent_id IS NULL LIMIT 1) t), 1),
('Edible Oils',         (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Oil%' AND parent_id IS NULL LIMIT 1) t), 1),
('Ghee',                (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Oil%' AND parent_id IS NULL LIMIT 1) t), 1),
('Sugar, Salt & Jaggery',(SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Atta%' AND parent_id IS NULL LIMIT 1) t), 1),
('Poha, Daliya & Oats', (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Atta%' AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Snacks & Munchies ────────────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Chips & Crisps',      (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Snack%' AND parent_id IS NULL LIMIT 1) t), 1),
('Namkeen & Mixtures',  (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Snack%' AND parent_id IS NULL LIMIT 1) t), 1),
('Cookies & Biscuits',  (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Snack%' AND parent_id IS NULL LIMIT 1) t), 1),
('Chocolates & Candies',(SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Snack%' AND parent_id IS NULL LIMIT 1) t), 1),
('Dry Fruits & Nuts',   (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Snack%' AND parent_id IS NULL LIMIT 1) t), 1),
('Popcorn & Puffs',     (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Snack%' AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Cold Drinks & Beverages ──────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Soft Drinks',         (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Drink%' OR name LIKE '%Beverage%' OR name LIKE '%Juice%') AND parent_id IS NULL LIMIT 1) t), 1),
('Fruit Juices',        (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Drink%' OR name LIKE '%Beverage%' OR name LIKE '%Juice%') AND parent_id IS NULL LIMIT 1) t), 1),
('Energy & Sports Drinks',(SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Drink%' OR name LIKE '%Beverage%' OR name LIKE '%Juice%') AND parent_id IS NULL LIMIT 1) t), 1),
('Water & Soda',        (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Drink%' OR name LIKE '%Beverage%' OR name LIKE '%Juice%') AND parent_id IS NULL LIMIT 1) t), 1),
('Nimbu Pani & Sherbets',(SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Drink%' OR name LIKE '%Beverage%' OR name LIKE '%Juice%') AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Tea, Coffee & Health Drinks ──────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Tea',                 (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Tea%' OR name LIKE '%Coffee%') AND parent_id IS NULL LIMIT 1) t), 1),
('Coffee',              (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Tea%' OR name LIKE '%Coffee%') AND parent_id IS NULL LIMIT 1) t), 1),
('Health & Energy Drinks',(SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Tea%' OR name LIKE '%Coffee%') AND parent_id IS NULL LIMIT 1) t), 1),
('Milk Flavours',       (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Tea%' OR name LIKE '%Coffee%') AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Masala & Spices ──────────────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Whole Spices',        (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Masala%' OR name LIKE '%Spice%') AND parent_id IS NULL LIMIT 1) t), 1),
('Powdered Spices',     (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Masala%' OR name LIKE '%Spice%') AND parent_id IS NULL LIMIT 1) t), 1),
('Cooking Pastes',      (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Masala%' OR name LIKE '%Spice%') AND parent_id IS NULL LIMIT 1) t), 1),
('Sauces & Ketchup',    (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Masala%' OR name LIKE '%Spice%') AND parent_id IS NULL LIMIT 1) t), 1),
('Pickles & Chutney',   (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Masala%' OR name LIKE '%Spice%') AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Personal Care ────────────────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Hair Care',           (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Personal%' AND parent_id IS NULL LIMIT 1) t), 1),
('Skin Care',           (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Personal%' AND parent_id IS NULL LIMIT 1) t), 1),
('Oral Care',           (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Personal%' AND parent_id IS NULL LIMIT 1) t), 1),
('Bath & Body',         (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Personal%' AND parent_id IS NULL LIMIT 1) t), 1),
('Feminine Hygiene',    (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Personal%' AND parent_id IS NULL LIMIT 1) t), 1),
('Deodorants & Perfumes',(SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Personal%' AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Household Items ──────────────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Detergents & Cleaners',(SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Household%' OR name LIKE '%Home%') AND parent_id IS NULL LIMIT 1) t), 1),
('Fresheners & Repellents',(SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Household%' OR name LIKE '%Home%') AND parent_id IS NULL LIMIT 1) t), 1),
('Garbage Bags & Tissues',(SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Household%' OR name LIKE '%Home%') AND parent_id IS NULL LIMIT 1) t), 1),
('Mops, Brushes & Scrubs',(SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Household%' OR name LIKE '%Home%') AND parent_id IS NULL LIMIT 1) t), 1),
('Kitchen Accessories', (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Household%' OR name LIKE '%Home%') AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Baby Care ────────────────────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Baby Food',           (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Baby%' AND parent_id IS NULL LIMIT 1) t), 1),
('Baby Hygiene',        (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Baby%' AND parent_id IS NULL LIMIT 1) t), 1),
('Baby Accessories',    (SELECT id FROM (SELECT id FROM main_category WHERE name LIKE '%Baby%' AND parent_id IS NULL LIMIT 1) t), 1);

-- ── Chicken, Meat & Fish ─────────────────────────────────────
INSERT INTO `main_category` (`name`, `parent_id`, `is_active`) VALUES
('Chicken',             (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Chicken%' OR name LIKE '%Meat%' OR name LIKE '%Fish%') AND parent_id IS NULL LIMIT 1) t), 1),
('Mutton & Lamb',       (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Chicken%' OR name LIKE '%Meat%' OR name LIKE '%Fish%') AND parent_id IS NULL LIMIT 1) t), 1),
('Fish & Seafood',      (SELECT id FROM (SELECT id FROM main_category WHERE (name LIKE '%Chicken%' OR name LIKE '%Meat%' OR name LIKE '%Fish%') AND parent_id IS NULL LIMIT 1) t), 1);

-- ============================================================
-- Verify: Check subcategories inserted with parent_id
-- SELECT id, name, parent_id FROM main_category WHERE parent_id IS NOT NULL ORDER BY parent_id;
-- ============================================================
