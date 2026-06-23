-- ============================================================
-- product_types table
-- Run this SQL in your MySQL database (digixcod_dxmart)
-- ============================================================

CREATE TABLE IF NOT EXISTS `product_types` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(255)    NOT NULL,
  `position`   INT UNSIGNED    NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_types_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Default product types (only insert if table is empty)
-- ============================================================

INSERT IGNORE INTO `product_types` (`name`, `position`) VALUES
  ('Everyday Essentials', 1),
  ('Best Selling',        2),
  ('Hot Deals',           3);

-- ============================================================
-- If you already have the table without the position column,
-- run these ALTER statements instead:
-- ============================================================

-- ALTER TABLE `product_types` ADD COLUMN `position` INT UNSIGNED NOT NULL DEFAULT 0 AFTER `name`;
-- UPDATE `product_types` SET `position` = `id`;   -- seed positions from existing ids
