-- ============================================================
-- home_tabs table
-- Run in phpMyAdmin against digixcod_dxmart
-- ============================================================

CREATE TABLE IF NOT EXISTS `home_tabs` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(100)    NOT NULL,
  `icon`        VARCHAR(100)    NOT NULL DEFAULT 'shopping_bag',
  `type`        ENUM('all','category','categories','deals') NOT NULL DEFAULT 'category',
  `category_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `bg_color`    VARCHAR(20)     NOT NULL DEFAULT '#6C63FF',
  `position`    INT             NOT NULL DEFAULT 0,
  `is_active`   TINYINT(1)      NOT NULL DEFAULT 1,
  `banner_image` VARCHAR(255)     NULL DEFAULT NULL,
  `created_at`  TIMESTAMP        NULL DEFAULT NULL,
  `updated_at`  TIMESTAMP        NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Default tabs (All + Categories + 3 common types)
-- ============================================================
INSERT IGNORE INTO `home_tabs` (`name`, `icon`, `type`, `category_id`, `bg_color`, `position`, `is_active`) VALUES
  ('All',        'all',        'all',        NULL, '#6C63FF', 0, 1),
  ('Categories', 'grid',       'categories', NULL, '#FF6584', 1, 1);
