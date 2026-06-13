-- Run this in phpMyAdmin on digixcod_dxmart database
ALTER TABLE `banner` ADD COLUMN `is_active` TINYINT(1) NOT NULL DEFAULT 1;

-- Set all existing banners as active
UPDATE `banner` SET `is_active` = 1;
