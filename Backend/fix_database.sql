-- ============================================================
-- DxMart Database Fix Script
-- Run this once in phpMyAdmin on database: digixcod_dxmart
-- Safe to run multiple times (uses IF NOT EXISTS / IF EXISTS guards)
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- 1. main_category — add parent_id and position columns
--    (code uses parent_id for subcategories, position for ordering)
-- ------------------------------------------------------------

ALTER TABLE `main_category`
    ADD COLUMN IF NOT EXISTS `parent_id` INT(11) NULL DEFAULT NULL AFTER `id`,
    ADD COLUMN IF NOT EXISTS `position` INT(11) NOT NULL DEFAULT 0 AFTER `is_active`;

-- Set default positions for existing top-level categories (so ordering works)
UPDATE `main_category` SET `position` = `id` WHERE `parent_id` IS NULL AND `position` = 0;

-- ------------------------------------------------------------
-- 2. products — add subcategory_id and brand_id columns
--    (code uses subcategory_id pointing to main_category.id)
--    (old sub_category_id kept as-is for backward compat)
-- ------------------------------------------------------------

ALTER TABLE `products`
    ADD COLUMN IF NOT EXISTS `subcategory_id` INT(11) NULL DEFAULT NULL AFTER `main_category_id`,
    ADD COLUMN IF NOT EXISTS `brand_id` INT(11) NULL DEFAULT NULL AFTER `subcategory_id`;

-- ------------------------------------------------------------
-- 3. personal_access_tokens — required for Laravel Sanctum login
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
    `id`             BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `tokenable_type` VARCHAR(255)        NOT NULL,
    `tokenable_id`   BIGINT(20) UNSIGNED NOT NULL,
    `name`           VARCHAR(255)        NOT NULL,
    `token`          VARCHAR(64)         NOT NULL,
    `abilities`      TEXT                NULL,
    `last_used_at`   TIMESTAMP           NULL DEFAULT NULL,
    `expires_at`     TIMESTAMP           NULL DEFAULT NULL,
    `created_at`     TIMESTAMP           NULL DEFAULT NULL,
    `updated_at`     TIMESTAMP           NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
    KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`, `tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 4. product_types — add position column for manual ordering
-- ------------------------------------------------------------

ALTER TABLE `product_types`
    ADD COLUMN IF NOT EXISTS `position` INT NOT NULL DEFAULT 0 AFTER `name`;

UPDATE `product_types` SET `position` = `id` WHERE `position` = 0;

-- ------------------------------------------------------------
-- 5. users — add phone column (some old screens send phone)
-- ------------------------------------------------------------

ALTER TABLE `users`
    ADD COLUMN IF NOT EXISTS `phone` VARCHAR(15) NULL DEFAULT NULL AFTER `email`;

-- ------------------------------------------------------------
-- Done
-- ------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'fix_database.sql applied successfully!' AS result;
