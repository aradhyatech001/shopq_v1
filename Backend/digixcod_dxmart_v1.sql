-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 16, 2026 at 01:35 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `digixcod_dxmart`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `email`, `password`, `created_at`, `updated_at`) VALUES
(1, 'admin@dxmart.com', '$2y$12$eSj/kQSdhSsUERfh3qlACeg5Otxw3ijDOkODy17RoxfH4IANRiPM2', '2026-06-15 05:29:16', '2026-06-15 05:29:16');

-- --------------------------------------------------------

--
-- Table structure for table `app_settings`
--

CREATE TABLE `app_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `key`, `value`, `created_at`, `updated_at`) VALUES
(1, 'primary_color', '#F5BF14', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(2, 'secondary_color', '#FFC63A', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(3, 'app_name', 'DxMart', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(4, 'delivery_time_text', '24 Min', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(5, 'free_delivery_text', '₹0 delivery fee', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(6, 'search_hint', 'Search for \"Milk\"', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(7, 'assurance_1', 'Lowest Prices', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(8, 'assurance_2', 'Quality Checked', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(9, 'assurance_3', 'Easy Returns', '2026-06-15 01:09:55', '2026-06-15 01:09:55'),
(10, 'payment_cod_enabled', '1', '2026-06-15 23:34:50', '2026-06-15 23:41:06'),
(11, 'payment_online_enabled', '0', '2026-06-15 23:34:50', '2026-06-15 23:41:06');

-- --------------------------------------------------------

--
-- Table structure for table `banner`
--

CREATE TABLE `banner` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `banner_image` varchar(255) NOT NULL,
  `is_active` tinyint(4) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `banner`
--

INSERT INTO `banner` (`id`, `category_id`, `banner_image`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'categories/cat_1781166858821.png', 1, '2026-06-15 01:10:03', '2026-06-15 01:10:03'),
(2, 2, 'banners/banner_image_1781514386377.png', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `variant_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cart_items`
--

INSERT INTO `cart_items` (`id`, `user_id`, `product_id`, `variant_id`, `quantity`, `image_url`, `created_at`, `updated_at`) VALUES
(21, 7, 8, 1, 1, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `city`
--

CREATE TABLE `city` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `district_id` bigint(20) UNSIGNED NOT NULL,
  `city_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `city`
--

INSERT INTO `city` (`id`, `district_id`, `city_name`, `created_at`, `updated_at`) VALUES
(1, 1, 'Connaught Place', '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `coupon`
--

CREATE TABLE `coupon` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `code_name` varchar(255) NOT NULL,
  `discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `expri_date` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `min_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `coupon`
--

INSERT INTO `coupon` (`id`, `title`, `description`, `code_name`, `discount`, `expri_date`, `status`, `min_amount`, `created_at`, `updated_at`) VALUES
(1, 'Welcome Offer', 'Flat 10% off on your first order', 'WELCOME10', 10.00, '31-12-2026', 'Public', 199.00, '2026-06-15 01:10:03', '2026-06-15 01:10:03'),
(2, 'FESTIVAL SALE', 'Special festival offer', 'FEST20', 20.00, '30-06-2026', 'Public', 200.00, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `delivery_address`
--

CREATE TABLE `delivery_address` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pincode` varchar(10) DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  `full_address` text NOT NULL,
  `pin_code` varchar(255) NOT NULL,
  `landmark` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `delivery_address`
--

INSERT INTO `delivery_address` (`id`, `pincode`, `user_id`, `name`, `phone`, `full_address`, `pin_code`, `landmark`, `created_at`, `updated_at`) VALUES
(1, NULL, 3, 'Amit Kumar', '9876543210', 'Flat 101, Green Park, New Delhi - 110016', '110001', 'Near main market', '2026-06-15 01:10:03', '2026-06-15 01:10:03'),
(2, NULL, 2, 'Priya Verma', '9123456780', 'B-204, Andheri West, Mumbai - 400058', '110001', 'Near main market', '2026-06-15 01:10:03', '2026-06-15 01:10:03'),
(3, NULL, 1, 'Rahul Sharma', '9988776655', 'No. 45, Indiranagar, Bengaluru - 560038', '110001', 'Near Main Market', '2026-06-15 01:10:03', '2026-06-15 01:10:03'),
(4, NULL, 3, 'Amit Kumar', '9876543210', 'Flat 101, Green Park, New Delhi - 110016', '110001', 'Near main market', '2026-06-15 01:10:03', '2026-06-15 01:10:03'),
(5, NULL, 4, 'Sneha Patel', '9001122334', '12/3 Ballygunge, Kolkata - 700019', '110001', 'Near main market', '2026-06-15 01:10:03', '2026-06-15 01:10:03'),
(6, NULL, 5, 'Vikas Singh', '9445566778', 'C-7, CG Road, Ahmedabad - 380006', '110001', 'Near main market', '2026-06-15 01:10:03', '2026-06-15 01:10:03'),
(7, NULL, 2, 'Priya Verma', '9123456780', 'B-204, Andheri West, Mumbai - 400058', '110001', 'Near main market', '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `delivery_boy`
--

CREATE TABLE `delivery_boy` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `vendor_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(80) NOT NULL,
  `email` varchar(80) NOT NULL,
  `mobile` varchar(12) NOT NULL,
  `pin_code` varchar(10) NOT NULL,
  `address` varchar(200) NOT NULL,
  `password` varchar(100) NOT NULL,
  `date_time` varchar(50) NOT NULL,
  `status` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `delivery_boy`
--

INSERT INTO `delivery_boy` (`id`, `vendor_id`, `name`, `email`, `mobile`, `pin_code`, `address`, `password`, `date_time`, `status`) VALUES
(1, NULL, 'Rajesh Kumar', 'rajesh49011@gmail.com', '8102337432', '825408', 'Vill - Paroriya, Post - Badgwan, Chatra Jharkhand ', '$2y$12$3XJ7DJjc0k/VUK.Mw5ldA.DhMsL277f9Ac/cIE4ofEp7lgMNRl0Da', '14-10-2025 08:24 AM', 'active'),
(2, NULL, 'Pankaj Kumar', 'pankajkumar.hzb143@gmail.com', '6205511717', '834002', 'Ranchi', '$2y$10$jJ1R9az46bmCPCu9VEwk1uLaU/Uu3nXqOW2KOTa3tb9eu5HVEuAw.', '29-10-2025 06:54 PM', 'active'),
(3, 1, 'Ram Kumar', 'ramkumar@gmail.com', '9868667788', '', '', '$2y$12$Chn8I1bvb8a7Ol4UGscOR.5sg79DUvG829bHqRY0qNV44ZZysdlCi', '16-06-2026 11:05 AM', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `delivery_charge`
--

CREATE TABLE `delivery_charge` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `delivery_charge`
--

INSERT INTO `delivery_charge` (`id`, `amount`, `created_at`, `updated_at`) VALUES
(1, 10.00, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `deliver_time`
--

CREATE TABLE `deliver_time` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `time` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `deliver_time`
--

INSERT INTO `deliver_time` (`id`, `time`, `created_at`, `updated_at`) VALUES
(1, '24 Min', '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `district`
--

CREATE TABLE `district` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `district_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `district`
--

INSERT INTO `district` (`id`, `district_name`, `created_at`, `updated_at`) VALUES
(1, 'New Delhi', '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `flash_deals`
--

CREATE TABLE `flash_deals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `variant_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `deal_price` decimal(10,2) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `flash_deals`
--

INSERT INTO `flash_deals` (`id`, `product_id`, `variant_id`, `title`, `deal_price`, `start_time`, `end_time`, `is_active`, `created_at`) VALUES
(1, 1, 1, 'Flash Sale', 399.00, '2026-06-15 06:40:03', '2026-06-22 06:40:03', 1, '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `free_delivey`
--

CREATE TABLE `free_delivey` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `free_delivey`
--

INSERT INTO `free_delivey` (`id`, `amount`, `created_at`, `updated_at`) VALUES
(1, 499.00, '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `handling_charge`
--

CREATE TABLE `handling_charge` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `handling_charge`
--

INSERT INTO `handling_charge` (`id`, `amount`, `created_at`, `updated_at`) VALUES
(1, 9.00, '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `help_call`
--

CREATE TABLE `help_call` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `call_help` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `help_call`
--

INSERT INTO `help_call` (`id`, `call_help`, `created_at`, `updated_at`) VALUES
(1, '+91 90000 00000', '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `help_email`
--

CREATE TABLE `help_email` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `help_email`
--

INSERT INTO `help_email` (`id`, `email`, `created_at`, `updated_at`) VALUES
(1, 'support@shopq.com', '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `help_whatsapp`
--

CREATE TABLE `help_whatsapp` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `whatsapp_no` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `help_whatsapp`
--

INSERT INTO `help_whatsapp` (`id`, `whatsapp_no`, `created_at`, `updated_at`) VALUES
(1, '+91 90000 00000', '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `home_sections`
--

CREATE TABLE `home_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `home_tab_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `emoji` varchar(10) DEFAULT NULL,
  `banner_image` varchar(255) DEFAULT NULL,
  `banner_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`banner_ids`)),
  `section_type` varchar(40) NOT NULL DEFAULT 'product_type',
  `product_type` varchar(100) DEFAULT NULL,
  `main_category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subcategory_id` bigint(20) UNSIGNED DEFAULT NULL,
  `brand_id` bigint(20) UNSIGNED DEFAULT NULL,
  `link_category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `product_limit` int(11) NOT NULL DEFAULT 10,
  `position` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `home_sections`
--

INSERT INTO `home_sections` (`id`, `home_tab_id`, `title`, `emoji`, `banner_image`, `banner_ids`, `section_type`, `product_type`, `main_category_id`, `subcategory_id`, `brand_id`, `link_category_id`, `product_limit`, `position`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Shop by Category', NULL, NULL, NULL, 'category_grid', NULL, NULL, NULL, NULL, NULL, 12, 2, 1, '2026-06-15 01:09:57', '2026-06-16 00:23:33'),
(2, 1, 'Best Selling', NULL, NULL, NULL, 'product_type', 'Best Selling', NULL, NULL, NULL, NULL, 10, 3, 1, '2026-06-15 01:09:57', '2026-06-16 00:23:33'),
(3, 1, 'Daily Deals', NULL, NULL, NULL, 'product_type', 'Daily Deals', NULL, NULL, NULL, NULL, 10, 6, 1, '2026-06-15 01:09:57', '2026-06-16 00:23:33'),
(4, 1, 'Brands You Love', NULL, NULL, NULL, 'brand_grid', NULL, NULL, NULL, NULL, NULL, 12, 7, 1, '2026-06-15 01:09:57', '2026-06-16 00:23:33'),
(5, 1, 'Hot Deals', NULL, NULL, NULL, 'product_type', 'Hot Deals', NULL, NULL, NULL, NULL, 10, 8, 1, '2026-06-15 01:09:57', '2026-06-16 00:23:33'),
(6, 1, 'Shops Near You', NULL, NULL, NULL, 'shop_grid', NULL, NULL, NULL, NULL, NULL, 10, 9, 1, '2026-06-15 01:09:57', '2026-06-16 00:23:33'),
(7, 3, 'Fresh Categories', NULL, NULL, NULL, 'category_grid', NULL, NULL, NULL, NULL, NULL, 8, 1, 1, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(8, 3, 'Best of Fresh', NULL, NULL, NULL, 'products', NULL, NULL, NULL, NULL, NULL, 10, 2, 1, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(9, 4, 'Daily Deals', NULL, NULL, NULL, 'product_type', 'Daily Deals', NULL, NULL, NULL, NULL, 10, 1, 1, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(10, 4, 'Hot Deals', NULL, NULL, NULL, 'product_type', 'Hot Deals', NULL, NULL, NULL, NULL, 10, 2, 1, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(11, 4, 'Buy 1 Get 1', NULL, NULL, NULL, 'product_type', 'Buy 1 Get 1', NULL, NULL, NULL, NULL, 10, 3, 1, '2026-06-15 03:22:05', '2026-06-15 03:22:05'),
(13, 1, 'Dairy, Bread & Eggs', NULL, NULL, NULL, 'category_grid', NULL, 3, NULL, NULL, NULL, 8, 4, 1, '2026-06-15 03:39:59', '2026-06-16 00:23:33'),
(17, 3, '', NULL, NULL, '[2,1]', 'banner', NULL, NULL, NULL, NULL, NULL, 10, 3, 1, '2026-06-16 00:19:32', '2026-06-16 00:19:32'),
(18, 1, '', NULL, NULL, '[2,1]', 'banner', NULL, NULL, NULL, NULL, NULL, 10, 1, 1, '2026-06-16 00:23:00', '2026-06-16 00:23:33'),
(19, 1, '', NULL, NULL, '[2]', 'banner', NULL, NULL, NULL, NULL, NULL, 10, 5, 1, '2026-06-16 00:23:23', '2026-06-16 00:23:33');

-- --------------------------------------------------------

--
-- Table structure for table `home_tabs`
--

CREATE TABLE `home_tabs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `icon` varchar(100) NOT NULL DEFAULT 'shopping_bag',
  `icon_image` varchar(255) DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'category',
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `bg_color` varchar(20) NOT NULL DEFAULT '#6C63FF',
  `banner_image` varchar(255) DEFAULT NULL,
  `position` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `home_tabs`
--

INSERT INTO `home_tabs` (`id`, `name`, `icon`, `icon_image`, `type`, `category_id`, `bg_color`, `banner_image`, `position`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'All', 'all', NULL, 'all', NULL, '#6C63FF', NULL, 0, 1, '2026-06-15 01:09:52', '2026-06-15 01:09:52'),
(2, 'Categories', 'grid', NULL, 'categories', NULL, '#FF6584', NULL, 1, 1, '2026-06-15 01:09:52', '2026-06-15 01:09:52'),
(3, 'Fresh', 'apple', NULL, 'category', 5, '#2DB87B', NULL, 1, 1, NULL, NULL),
(4, 'Deals', 'deals', NULL, 'none', NULL, '#FF8C42', NULL, 2, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `main_category`
--

CREATE TABLE `main_category` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `icon_url` varchar(500) DEFAULT NULL,
  `color_code` varchar(10) NOT NULL DEFAULT '#FFFFFF',
  `tab_banner_url` varchar(500) DEFAULT NULL,
  `tab_bg_color` varchar(10) NOT NULL DEFAULT '#F5F5F5',
  `is_tab` tinyint(1) NOT NULL DEFAULT 1,
  `tab_position` int(11) NOT NULL DEFAULT 0,
  `description` varchar(500) DEFAULT NULL,
  `is_active` tinyint(4) NOT NULL DEFAULT 1,
  `position` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `main_category`
--

INSERT INTO `main_category` (`id`, `name`, `image`, `icon_url`, `color_code`, `tab_banner_url`, `tab_bg_color`, `is_tab`, `tab_position`, `description`, `is_active`, `position`, `created_at`, `updated_at`) VALUES
(1, 'Atta, Rice, Oil & Dals', 'categories/cat_1781166858821.png', 'categories/cat_1781166858821.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 1, NULL, NULL),
(2, 'Breakfast & Sauces', 'categories/cat_1781167059680.png', 'categories/cat_1781167059680.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 2, NULL, NULL),
(3, 'Dairy, Bread & Eggs', 'categories/cat_1781167075020.png', 'categories/cat_1781167075020.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 3, NULL, NULL),
(4, 'Electronics & Appliances', 'categories/cat_1781167096944.png', 'categories/cat_1781167096944.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 4, NULL, NULL),
(5, 'Fruits & Vegetables', 'categories/cat_1781167109376.png', 'categories/cat_1781167109376.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 5, NULL, NULL),
(6, 'Ice Creams & More', 'categories/cat_1781167130681.png', 'categories/cat_1781167130681.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 6, NULL, NULL),
(7, 'Kitchen & Dining', 'categories/cat_1781167152666.png', 'categories/cat_1781167152666.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 7, NULL, NULL),
(8, 'Masala & Dry Fruits', 'categories/cat_1781167163939.png', 'categories/cat_1781167163939.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 8, NULL, NULL),
(9, 'Frozen Food', 'categories/cat_1781167176047.png', 'categories/cat_1781167176047.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 9, NULL, NULL),
(10, 'Sweet Cravings', 'categories/cat_1781167186281.png', 'categories/cat_1781167186281.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 10, NULL, NULL),
(11, 'Tea, Coffee & More', 'categories/cat_1781167196982.png', 'categories/cat_1781167196982.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 11, NULL, NULL),
(12, 'Packaged Food', 'categories/cat_1781167207109.png', 'categories/cat_1781167207109.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 12, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2024_01_01_000001_update_users_table', 1),
(5, '2024_01_01_000002_create_otp_table', 1),
(6, '2024_01_01_000003_create_admin_table', 1),
(7, '2024_01_01_000004_create_main_category_table', 1),
(8, '2024_01_01_000005_create_banner_table', 1),
(9, '2024_01_01_000006_create_coupon_table', 1),
(10, '2024_01_01_000007_create_delivery_address_table', 1),
(11, '2024_01_01_000008_create_settings_tables', 1),
(12, '2024_01_01_000009_create_help_tables', 1),
(13, '2024_01_01_000010_create_location_tables', 1),
(14, '2024_01_01_000011_create_products_table', 1),
(15, '2024_01_01_000012_create_cart_wishlist_tables', 1),
(16, '2024_01_01_000013_create_orders_tables', 1),
(17, '2024_01_01_000014_create_product_types_table', 1),
(18, '2024_01_01_000015_add_parent_id_to_main_category', 1),
(19, '2026_06_09_111551_create_personal_access_tokens_table', 1),
(20, '2026_06_10_000001_add_position_to_product_types_table', 1),
(21, '2026_06_10_000002_create_home_tabs_table', 1),
(22, '2026_06_10_000003_add_banner_image_to_home_tabs', 1),
(23, '2026_06_11_000001_add_image_columns_to_products', 1),
(24, '2026_06_11_000001_add_is_active_to_banner_table', 1),
(25, '2026_06_11_000001_create_vendors_table', 1),
(26, '2026_06_11_000002_create_subscription_plans_table', 1),
(27, '2026_06_11_000003_create_vendor_subscriptions_table', 1),
(28, '2026_06_11_000004_create_pincodes_table', 1),
(29, '2026_06_11_000005_create_vendor_pincodes_table', 1),
(30, '2026_06_11_000006_add_vendor_id_to_products', 1),
(31, '2026_06_11_000007_add_pincode_to_users', 1),
(32, '2026_06_12_000001_create_sql_missing_tables', 1),
(33, '2026_06_12_000002_fix_missing_columns', 1),
(34, '2026_06_13_000001_create_sessions_table', 1),
(35, '2026_06_13_000002_create_app_settings_table', 1),
(36, '2026_06_13_000003_extend_home_sections', 1),
(37, '2026_06_13_000004_add_subcategory_to_home_sections', 1),
(38, '2026_06_13_000005_add_icon_image_to_home_tabs', 1),
(39, '2026_06_13_000006_widen_home_tabs_type', 1),
(40, '2026_06_13_000007_consolidate_subcategories_and_dedupe', 1),
(41, '2026_06_16_000001_add_banner_ids_to_home_sections', 2),
(42, '2026_06_16_000002_multi_vendor_orders', 3),
(43, '2026_06_16_000003_add_vendor_to_delivery_boy', 4);

-- --------------------------------------------------------

--
-- Table structure for table `minimum_order_amout`
--

CREATE TABLE `minimum_order_amout` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `minimum_order_amout`
--

INSERT INTO `minimum_order_amout` (`id`, `amount`, `created_at`, `updated_at`) VALUES
(1, 99.00, '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `vendor_id` bigint(20) UNSIGNED DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `coupon_code` varchar(255) DEFAULT NULL,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `delivery_charge` decimal(10,2) NOT NULL DEFAULT 0.00,
  `handling_charge` decimal(10,2) NOT NULL DEFAULT 0.00,
  `final_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `derived_status` varchar(30) NOT NULL DEFAULT 'pending',
  `payment_method` varchar(255) NOT NULL DEFAULT 'COD',
  `payment_status` varchar(20) NOT NULL DEFAULT 'pending',
  `order_datetime` varchar(255) DEFAULT NULL,
  `delivery_date` varchar(255) DEFAULT NULL,
  `delivery_time` varchar(255) DEFAULT NULL,
  `location_id` bigint(20) UNSIGNED NOT NULL,
  `gift` varchar(255) NOT NULL DEFAULT 'noGift',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `vendor_id`, `total_amount`, `coupon_code`, `discount_amount`, `delivery_charge`, `handling_charge`, `final_amount`, `status`, `derived_status`, `payment_method`, `payment_status`, `order_datetime`, `delivery_date`, `delivery_time`, `location_id`, `gift`, `created_at`, `updated_at`) VALUES
(11, 1, NULL, 342.00, 'null', 24.00, 10.00, 9.00, 337.00, 'delivered', 'delivered', 'COD', 'pending', '15-06-2026 04:54 PM', '2026-06-15', '9 AM - 2 PM', 3, 'noGift', NULL, NULL),
(12, 1, NULL, 1287.00, 'null', 227.00, 0.00, 9.00, 1069.00, 'delivered', 'delivered', 'COD', 'pending', '16-06-2026 10:34 AM', '2026-06-16', '9 AM - 2 PM', 3, 'noGift', NULL, NULL),
(13, 1, NULL, 100.00, 'null', 12.00, 10.00, 9.00, 107.00, 'delivered', 'delivered', 'UPI', 'pending', '16-06-2026 10:44 AM', '2026-06-16', '9 AM - 2 PM', 3, 'noGift', NULL, NULL),
(14, 1, NULL, 150.00, 'null', 10.00, 10.00, 9.00, 159.00, 'cancelled', 'delivered', 'COD', 'pending', '16-06-2026 10:55 AM', '2026-06-16', '9 AM - 2 PM', 3, 'noGift', NULL, NULL),
(15, 1, NULL, 160.00, 'null', 13.00, 10.00, 9.00, 166.00, 'confirmed', 'delivered', 'COD', 'pending', '16-06-2026 03:43 PM', '2026-06-16', '9 AM - 2 PM', 3, 'noGift', NULL, NULL),
(16, 1, NULL, 160.00, 'null', 10.00, 10.00, 9.00, 169.00, 'pending', 'pending', 'COD', 'pending', '16-06-2026 04:42 PM', '2026-06-16', '9 AM - 2 PM', 3, 'noGift', NULL, NULL),
(17, 1, NULL, 190.00, 'null', 20.00, 10.00, 9.00, 189.00, 'delivered', 'delivered', 'COD', 'pending', '16-06-2026 04:43 PM', '2026-06-16', '9 AM - 2 PM', 3, 'noGift', NULL, NULL),
(18, 1, NULL, 160.00, 'null', 16.00, 10.00, 9.00, 163.00, 'delivered', 'delivered', 'COD', 'pending', '16-06-2026 04:46 PM', '2026-06-16', '9 AM - 2 PM', 3, 'noGift', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_assignment`
--

CREATE TABLE `order_assignment` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED NOT NULL,
  `date_time` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `vendor_order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `vendor_id` bigint(20) UNSIGNED DEFAULT NULL,
  `variant_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `vendor_order_id`, `product_id`, `vendor_id`, `variant_id`, `quantity`, `price`, `image_url`, `created_at`, `updated_at`) VALUES
(17, 11, 1, 14, 2, 29, 9, 13.00, 'http://192.168.1.5:8000/api/files/products/6874f7552d622_image.png', NULL, NULL),
(18, 11, 1, 18, 2, 37, 3, 75.00, 'http://192.168.1.5:8000/api/files/products/6a2fbed09a222_img.png', NULL, NULL),
(19, 12, 2, 14, 2, 29, 1, 13.00, 'http://192.168.1.5:8000/api/files/products/6874f7552d622_image.png', NULL, NULL),
(20, 12, 2, 12, 2, 26, 1, 125.00, 'http://192.168.1.5:8000/api/files/products/6874f5b7b7e2a_image.png', NULL, NULL),
(21, 12, 2, 9, 2, 19, 1, 1149.00, 'http://192.168.1.5:8000/api/files/products/6874f5b77a0ba_image.png', NULL, NULL),
(22, 13, 3, 14, 2, 30, 2, 50.00, 'http://192.168.1.4:8000/api/files/products/6874f7552d622_image.png', NULL, NULL),
(23, 14, 4, 18, 2, 37, 2, 75.00, 'http://192.168.1.4:8000/api/files/products/6a2fbed09a222_img.png', NULL, NULL),
(24, 15, 5, 8, 1, 15, 1, 72.00, 'http://192.168.1.4:8000/api/files/products/6874f5b765f83_image.png', NULL, NULL),
(25, 15, 6, 18, 2, 37, 1, 75.00, 'http://192.168.1.4:8000/api/files/products/6a2fbed09a222_img.png', NULL, NULL),
(26, 16, 7, 18, 2, 37, 2, 75.00, 'http://192.168.1.4:8000/api/files/products/6a2fbed09a222_img.png', NULL, NULL),
(27, 17, 8, 8, 1, 16, 1, 170.00, 'http://192.168.1.4:8000/api/files/products/6874f5b765f83_image.png', NULL, NULL),
(28, 18, 9, 8, 1, 15, 2, 72.00, 'http://192.168.1.4:8000/api/files/products/6874f5b765f83_image.png', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_status_history`
--

CREATE TABLE `order_status_history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_order_id` bigint(20) UNSIGNED NOT NULL,
  `vendor_order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `actor_type` varchar(20) NOT NULL DEFAULT 'system',
  `actor_id` bigint(20) UNSIGNED DEFAULT NULL,
  `from_status` varchar(20) DEFAULT NULL,
  `to_status` varchar(20) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_status_history`
--

INSERT INTO `order_status_history` (`id`, `parent_order_id`, `vendor_order_id`, `actor_type`, `actor_id`, `from_status`, `to_status`, `note`, `created_at`) VALUES
(1, 13, 3, 'vendor', 2, 'pending', 'confirmed', NULL, '2026-06-16 01:06:15'),
(2, 13, 3, 'vendor', 2, 'confirmed', 'out_for_delivery', NULL, '2026-06-16 01:06:28'),
(3, 13, 3, 'vendor', 2, 'out_for_delivery', 'delivered', NULL, '2026-06-16 01:06:47'),
(4, 14, 4, 'vendor', 2, 'out_for_delivery', 'delivered', NULL, '2026-06-16 01:14:44'),
(5, 12, 2, 'vendor', 2, 'packed', 'assigned', 'Assigned delivery boy #2', '2026-06-16 01:15:15'),
(6, 12, 2, 'vendor', 2, 'assigned', 'out_for_delivery', NULL, '2026-06-16 01:15:24'),
(7, 12, 2, 'vendor', 2, 'out_for_delivery', 'delivered', NULL, '2026-06-16 01:25:01'),
(8, 11, 1, 'vendor', 2, 'pending', 'confirmed', NULL, '2026-06-16 01:25:14'),
(9, 11, 1, 'vendor', 2, 'confirmed', 'packed', NULL, '2026-06-16 01:25:23'),
(10, 11, 1, 'vendor', 2, 'packed', 'assigned', 'Assigned delivery boy #1', '2026-06-16 01:27:11'),
(11, 11, 1, 'vendor', 2, 'assigned', 'out_for_delivery', NULL, '2026-06-16 01:27:25'),
(12, 11, 1, 'vendor', 2, 'out_for_delivery', 'out_for_delivery', NULL, '2026-06-16 01:27:28'),
(13, 11, 1, 'vendor', 2, 'out_for_delivery', 'delivered', NULL, '2026-06-16 01:27:33'),
(14, 15, NULL, 'customer', 1, NULL, 'pending', 'Order placed', '2026-06-16 04:43:38'),
(26, 16, NULL, 'customer', 1, NULL, 'pending', 'Order placed', '2026-06-16 05:42:37'),
(27, 17, NULL, 'customer', 1, NULL, 'pending', 'Order placed', '2026-06-16 05:43:11'),
(28, 17, 8, 'vendor', 1, 'pending', 'confirmed', NULL, '2026-06-16 05:43:21'),
(29, 17, 8, 'vendor', 1, 'confirmed', 'packed', NULL, '2026-06-16 05:43:25'),
(30, 17, 8, 'vendor', 1, 'packed', 'assigned', 'Assigned delivery boy #3', '2026-06-16 05:44:46'),
(31, 17, 8, 'vendor', 1, 'assigned', 'out_for_delivery', NULL, '2026-06-16 05:44:51'),
(32, 17, 8, 'delivery', 3, 'out_for_delivery', 'delivered', NULL, '2026-06-16 05:45:29'),
(33, 18, NULL, 'customer', 1, NULL, 'pending', 'Order placed', '2026-06-16 05:46:55'),
(34, 18, 9, 'vendor', 1, 'pending', 'confirmed', NULL, '2026-06-16 05:47:02'),
(35, 18, 9, 'vendor', 1, 'confirmed', 'packed', NULL, '2026-06-16 05:47:05'),
(36, 18, 9, 'vendor', 1, 'packed', 'assigned', 'Assigned delivery boy #3', '2026-06-16 05:47:12'),
(37, 18, 9, 'vendor', 1, 'assigned', 'out_for_delivery', NULL, '2026-06-16 05:47:45'),
(38, 18, 9, 'vendor', 1, 'out_for_delivery', 'delivered', NULL, '2026-06-16 05:48:09');

-- --------------------------------------------------------

--
-- Table structure for table `otp_table`
--

CREATE TABLE `otp_table` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `otp` varchar(255) NOT NULL,
  `expiry` bigint(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otp_table`
--

INSERT INTO `otp_table` (`id`, `email`, `otp`, `expiry`, `created_at`, `updated_at`) VALUES
(1, 'demo@shopq.com', '123456', 1781506203, '2026-06-15 01:10:03', '2026-06-15 01:10:03');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(6, 'App\\Models\\User', 1, 'auth_token', 'ac2199f2aa15043d3c55dae4f303e424b849fbb81cc6d91d60d816854f1dcef7', '[\"*\"]', '2026-06-16 05:47:18', NULL, '2026-06-15 05:38:23', '2026-06-16 05:47:18'),
(7, 'App\\Models\\User', 6, 'auth_token', '2b9322df8523fab55d2b9360a5e3c7304219cf524bbc2c7a5c1bb44a8f8dc766', '[\"*\"]', '2026-06-15 05:54:17', NULL, '2026-06-15 05:54:16', '2026-06-15 05:54:17'),
(8, 'App\\Models\\User', 7, 'auth_token', '7ccd0167b52a88a0a3b787f15b5df3c6083358ceea075bea35d1a7f27e7d2ece', '[\"*\"]', '2026-06-15 05:55:36', NULL, '2026-06-15 05:55:35', '2026-06-15 05:55:36'),
(11, 'App\\Models\\Vendor', 2, 'vendor-token', '8c38e774cd4e20fbd59619292891c050e1bcc83e673a3ea298b8f46c548390ca', '[\"*\"]', '2026-06-16 05:07:15', NULL, '2026-06-16 00:03:44', '2026-06-16 05:07:15'),
(12, 'App\\Models\\Admin', 1, 'admin-token', 'e7fa3170674705d4ece9e7549b469736f373813d9d52a72aa06c8b7b699ea15c', '[\"*\"]', '2026-06-16 05:42:09', NULL, '2026-06-16 04:36:07', '2026-06-16 05:42:09'),
(14, 'App\\Models\\Vendor', 1, 'vendor-token', '049eae15367ad82121311807661346a014e0d9e9ec575707494bd3a35f03042f', '[\"*\"]', '2026-06-16 05:49:03', NULL, '2026-06-16 05:09:48', '2026-06-16 05:49:03'),
(15, 'App\\Models\\DeliveryBoy', 3, 'delivery-token', '7cec2eae371d5b2d378b2a276e167e39c692dbc9023dc1a320e2c3db65ca0e25', '[\"*\"]', '2026-06-16 05:51:03', NULL, '2026-06-16 05:45:22', '2026-06-16 05:51:03');

-- --------------------------------------------------------

--
-- Table structure for table `pincodes`
--

CREATE TABLE `pincodes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(10) NOT NULL,
  `area_name` varchar(255) NOT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pincodes`
--

INSERT INTO `pincodes` (`id`, `code`, `area_name`, `city`, `state`, `is_active`, `created_at`, `updated_at`) VALUES
(1, '110001', 'Connaught Place', 'New Delhi', 'Delhi', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(2, '110002', 'Darya Ganj', 'New Delhi', 'Delhi', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(3, '110003', 'Lodi Road', 'New Delhi', 'Delhi', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(4, '110011', 'Karol Bagh', 'New Delhi', 'Delhi', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(5, '110015', 'Rajouri Garden', 'New Delhi', 'Delhi', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(6, '110020', 'Saket', 'New Delhi', 'Delhi', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(7, '400001', 'Fort', 'Mumbai', 'Maharashtra', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(8, '400050', 'Bandra West', 'Mumbai', 'Maharashtra', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(9, '400069', 'Andheri East', 'Mumbai', 'Maharashtra', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(10, '560001', 'MG Road', 'Bengaluru', 'Karnataka', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(11, '560034', 'Jayanagar', 'Bengaluru', 'Karnataka', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(12, '600001', 'George Town', 'Chennai', 'Tamil Nadu', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(13, '700001', 'BBD Bagh', 'Kolkata', 'West Bengal', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(14, '380001', 'Relief Road', 'Ahmedabad', 'Gujarat', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(15, '411001', 'Shivajinagar', 'Pune', 'Maharashtra', 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `vendor_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `main_category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subcategory_id` bigint(20) UNSIGNED DEFAULT NULL,
  `brand_id` bigint(20) UNSIGNED DEFAULT NULL,
  `types` varchar(100) NOT NULL DEFAULT 'normal',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `image_url` varchar(255) DEFAULT NULL,
  `icon_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `vendor_id`, `name`, `description`, `main_category_id`, `subcategory_id`, `brand_id`, `types`, `is_active`, `image_url`, `icon_url`, `created_at`, `updated_at`) VALUES
(1, 1, 'Alphonso Mangoes', 'Premium Alphonso mangoes from Ratnagiri. Sweet, pulpy and aromatic. 1 dozen box.', 5, 27, NULL, 'Fresh Arrivals, Best Selling', 1, 'products/68722a4216ede_image.png', 'products/68722a4216ede_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(2, 1, 'Banana (Robusta)', 'Fresh robusta bananas. Rich in potassium and natural sugars. Best for breakfast.', 5, 27, NULL, 'Fresh Arrivals, Everyday Essentials', 1, 'products/68722a4c3421e_image.png', 'products/68722a4c3421e_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(3, 1, 'Tomato (Country)', 'Farm-fresh country tomatoes. Ideal for curries, salads and chutneys.', 5, 28, NULL, 'Fresh Arrivals, Everyday Essentials', 1, 'products/68722a5a1a545_image.png', 'products/68722a5a1a545_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(4, 1, 'Potato (White)', 'Fresh white potatoes. Great for sabzi, fries and curries.', 5, 28, NULL, 'Fresh Arrivals, Everyday Essentials', 1, 'products/687233df47746_image.png', 'products/687233df47746_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(5, 1, 'Onion (Red)', 'Red onions sourced from Nashik. Strong flavour, perfect for Indian cooking.', 5, 28, NULL, 'Fresh Arrivals, Everyday Essentials', 1, 'products/68732823e176f_image.png', 'products/68732823e176f_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(6, 1, 'Full Cream Milk', 'Fresh full-cream toned milk. Rich in calcium and protein. Pasteurised and hygienically packed.', 3, 13, NULL, 'Everyday Essentials', 1, 'products/6873282405fa9_image.png', 'products/6873282405fa9_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(7, 1, 'Whole Wheat Bread', 'Soft whole wheat bread. No artificial colours. Best with butter or jam.', 3, 17, NULL, 'Everyday Essentials, Best Selling', 1, 'products/6874f5b7246a8_image.png', 'products/6874f5b7246a8_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(8, 1, 'Fresh Paneer', 'Soft, fresh cottage cheese made from full cream milk. Perfect for paneer dishes.', 3, 15, NULL, 'Fresh Arrivals, Best Selling', 1, 'products/6874f5b765f83_image.png', 'products/6874f5b765f83_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(9, 2, 'Basmati Rice (Long Grain)', 'Premium aged long-grain basmati rice. Perfect for biryanis, pulao and special occasions.', 1, 2, NULL, 'Best Selling', 1, 'products/6874f5b77a0ba_image.png', 'products/6874f5b77a0ba_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(10, 2, 'Sunflower Cooking Oil', 'Refined sunflower oil. Light and healthy for everyday Indian cooking.', 1, 3, NULL, 'Everyday Essentials', 1, 'products/6874f5b78cad1_image.png', 'products/6874f5b78cad1_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(11, 2, 'Toor Dal (Arhar)', 'Unpolished split pigeon peas. Protein-rich, easy to cook. Ideal for dal tadka.', 1, 4, NULL, 'Everyday Essentials', 1, 'products/6874f5b7a6aa9_image.png', 'products/6874f5b7a6aa9_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(12, 2, 'Garam Masala', 'Aromatic blend of whole spices ground fresh. Adds rich flavour to curries and biryanis.', 8, 42, NULL, 'Best Selling', 1, 'products/6874f5b7b7e2a_image.png', 'products/6874f5b7b7e2a_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(13, 2, 'Turmeric Powder (Haldi)', 'Pure ground turmeric with high curcumin content. Bright colour and strong aroma.', 8, 42, NULL, 'Everyday Essentials,Buy 1 Get 1', 1, 'products/6874f5b7d182a_image.png', 'products/6874f5b7d182a_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(14, 2, 'Maggi 2-Minute Noodles', 'India\'s favourite instant noodles. Ready in 2 minutes. Original masala flavour.', 12, 61, NULL, 'Best Selling, Daily Deals', 1, 'products/6874f7552d622_image.png', 'products/6874f7552d622_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(15, 3, 'Mixer Grinder 750W', 'Powerful 750W mixer grinder with 3 stainless steel jars. Ideal for wet and dry grinding.', 4, 22, NULL, 'Best Selling', 1, 'products/6874f7554f275_image.png', 'products/6874f7554f275_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(16, 3, 'Non-stick Kadai Set', 'Premium 3-piece non-stick kadai set. PFOA-free coating. Induction compatible.', 4, 36, NULL, 'Hot Deals, Daily Deals', 1, 'products/6874f7556a332_image.png', 'products/6874f7556a332_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(17, 2, 'Darjeeling Green Tea', 'First-flush Darjeeling green tea. Light, floral and refreshing. Rich in antioxidants.', 11, 56, NULL, 'Handpicked You 💝', 1, 'products/6874f75587b4f_image.png', 'products/6874f75587b4f_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(18, 2, 'Dairy Milk Silk Chocolate', 'Smooth, creamy Cadbury Dairy Milk Silk bar. The perfect gifting chocolate.', 10, 51, NULL, 'Best Selling,Hot Deals,50% Off,Everyday Essentials,Handpicked You 💝,Daily Deals,Buy 1 Get 1', 1, 'products/6874f755a412c_image.png', 'products/6874f755a412c_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(19, 2, 'Britannia Good Day Cashew Cookies', 'Buttery cookies loaded with premium cashew pieces. A great snack for tea time.', 10, 52, NULL, 'Everyday Essentials, Buy 1 Get 1', 1, 'products/6874f755c0db9_image.png', 'products/6874f755c0db9_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01');

-- --------------------------------------------------------

--
-- Table structure for table `product_highlights`
--

CREATE TABLE `product_highlights` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `attribute` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_highlights`
--

INSERT INTO `product_highlights` (`id`, `product_id`, `attribute`, `value`, `created_at`, `updated_at`) VALUES
(1, 1, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(2, 1, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(3, 1, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(4, 2, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(5, 2, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(6, 2, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(7, 3, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(8, 3, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(9, 3, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(10, 4, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(11, 4, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(12, 4, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(13, 5, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(14, 5, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(15, 5, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(16, 6, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(17, 6, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(18, 6, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(19, 7, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(20, 7, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(21, 7, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(22, 8, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(23, 8, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(24, 8, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(25, 9, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(26, 9, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(27, 9, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(28, 10, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(29, 10, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(30, 10, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(31, 11, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(32, 11, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(33, 11, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(34, 12, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(35, 12, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(36, 12, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(40, 14, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(41, 14, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(42, 14, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(43, 15, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(44, 15, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(45, 15, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(46, 16, 'Quality', 'Quality checked & hygienically packed', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(47, 16, 'Freshness', 'Sourced fresh daily', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(48, 16, 'Return', 'Easy returns within 24 hours', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(70, 18, 'Quality', 'Quality checked & hygienically packed', NULL, NULL),
(71, 18, 'Freshness', 'Sourced fresh daily', NULL, NULL),
(72, 18, 'Return', 'Easy returns within 24 hours', NULL, NULL),
(76, 17, 'Quality', 'Quality checked & hygienically packed', NULL, NULL),
(77, 17, 'Freshness', 'Sourced fresh daily', NULL, NULL),
(78, 17, 'Return', 'Easy returns within 24 hours', NULL, NULL),
(79, 13, 'Quality', 'Quality checked & hygienically packed', NULL, NULL),
(80, 13, 'Freshness', 'Sourced fresh daily', NULL, NULL),
(81, 13, 'Return', 'Easy returns within 24 hours', NULL, NULL),
(91, 19, 'Quality', 'Quality checked & hygienically packed', NULL, NULL),
(92, 19, 'Freshness', 'Sourced fresh daily', NULL, NULL),
(93, 19, 'Return', 'Easy returns within 24 hours', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `product_images`
--

CREATE TABLE `product_images` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `image_url` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image_url`, `created_at`, `updated_at`) VALUES
(1, 1, 'products/68722a4216ede_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(2, 2, 'products/68722a4c3421e_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(3, 3, 'products/68722a5a1a545_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(4, 4, 'products/687233df47746_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(5, 5, 'products/68732823e176f_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(6, 6, 'products/6873282405fa9_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(7, 7, 'products/6874f5b7246a8_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(8, 8, 'products/6874f5b765f83_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(9, 9, 'products/6874f5b77a0ba_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(10, 10, 'products/6874f5b78cad1_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(11, 11, 'products/6874f5b7a6aa9_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(12, 12, 'products/6874f5b7b7e2a_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(14, 14, 'products/6874f7552d622_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(15, 15, 'products/6874f7554f275_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(16, 16, 'products/6874f7556a332_image.png', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(20, 19, 'uploads/6a2fbe0975a87_img.png', NULL, NULL),
(21, 19, 'uploads/6a2fbe0a450fe_img.png', NULL, NULL),
(22, 19, 'uploads/6a2fbe0b17321_img.png', NULL, NULL),
(23, 19, 'uploads/6a2fbe0bd218e_img.png', NULL, NULL),
(24, 18, 'products/6a2fbed09a222_img.png', NULL, NULL),
(25, 18, 'products/6a2fbed1667d5_img.png', NULL, NULL),
(26, 17, 'products/6a2fbeff714dc_img.png', NULL, NULL),
(27, 17, 'products/6a2fbf00344fe_img.png', NULL, NULL),
(28, 13, 'products/6a2fbf533cf80_img.png', NULL, NULL),
(29, 13, 'products/6a2fbf54090ae_img.png', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `product_info`
--

CREATE TABLE `product_info` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `attribute` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_info`
--

INSERT INTO `product_info` (`id`, `product_id`, `attribute`, `value`, `created_at`, `updated_at`) VALUES
(1, 1, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(2, 1, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(3, 1, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(4, 1, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(5, 2, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(6, 2, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(7, 2, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(8, 2, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(9, 3, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(10, 3, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(11, 3, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(12, 3, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(13, 4, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(14, 4, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(15, 4, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(16, 4, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(17, 5, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(18, 5, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(19, 5, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(20, 5, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(21, 6, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(22, 6, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(23, 6, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(24, 6, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(25, 7, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(26, 7, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(27, 7, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(28, 7, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(29, 8, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(30, 8, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(31, 8, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(32, 8, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(33, 9, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(34, 9, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(35, 9, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(36, 9, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(37, 10, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(38, 10, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(39, 10, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(40, 10, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(41, 11, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(42, 11, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(43, 11, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(44, 11, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(45, 12, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(46, 12, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(47, 12, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(48, 12, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(53, 14, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(54, 14, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(55, 14, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(56, 14, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(57, 15, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(58, 15, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(59, 15, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(60, 15, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(61, 16, 'Country of Origin', 'India', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(62, 16, 'Shelf Life', '7 days from packaging', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(63, 16, 'Customer Care', 'support@shopq.com', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(64, 16, 'Seller', 'ShopQ Retail', '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(93, 18, 'Country of Origin', 'India', NULL, NULL),
(94, 18, 'Shelf Life', '7 days from packaging', NULL, NULL),
(95, 18, 'Customer Care', 'support@shopq.com', NULL, NULL),
(96, 18, 'Seller', 'ShopQ Retail', NULL, NULL),
(101, 17, 'Country of Origin', 'India', NULL, NULL),
(102, 17, 'Shelf Life', '7 days from packaging', NULL, NULL),
(103, 17, 'Customer Care', 'support@shopq.com', NULL, NULL),
(104, 17, 'Seller', 'ShopQ Retail', NULL, NULL),
(105, 13, 'Country of Origin', 'India', NULL, NULL),
(106, 13, 'Shelf Life', '7 days from packaging', NULL, NULL),
(107, 13, 'Customer Care', 'support@shopq.com', NULL, NULL),
(108, 13, 'Seller', 'ShopQ Retail', NULL, NULL),
(121, 19, 'Country of Origin', 'India', NULL, NULL),
(122, 19, 'Shelf Life', '7 days from packaging', NULL, NULL),
(123, 19, 'Customer Care', 'support@shopq.com', NULL, NULL),
(124, 19, 'Seller', 'ShopQ Retail', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `product_types`
--

CREATE TABLE `product_types` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `position` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_types`
--

INSERT INTO `product_types` (`id`, `name`, `position`, `created_at`, `updated_at`) VALUES
(1, 'Handpicked You 💝', 4, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(2, 'Daily Deals', 2, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(3, 'Everyday Essentials', 3, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(4, 'Best Selling', 1, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(5, 'Hot Deals', 5, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(6, 'Buy 1 Get 1', 6, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(7, '50% Off', 7, '2026-06-15 01:09:57', '2026-06-15 01:09:57'),
(8, 'Fresh Arrivals', 8, '2026-06-15 01:09:57', '2026-06-15 01:09:57');

-- --------------------------------------------------------

--
-- Table structure for table `product_variants`
--

CREATE TABLE `product_variants` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `selling_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `wholesale_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `stock` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_variants`
--

INSERT INTO `product_variants` (`id`, `product_id`, `name`, `price`, `selling_price`, `wholesale_price`, `stock`, `created_at`, `updated_at`) VALUES
(1, 1, '1 Dozen (12 pcs)', 450.00, 399.00, 319.20, 50, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(2, 1, '2 Dozen (24 pcs)', 850.00, 749.00, 599.20, 30, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(3, 2, '6 pcs', 40.00, 35.00, 28.00, 100, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(4, 2, '12 pcs', 75.00, 65.00, 52.00, 80, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(5, 3, '500g', 30.00, 25.00, 20.00, 200, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(6, 3, '1 kg', 55.00, 45.00, 36.00, 150, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(7, 4, '1 kg', 35.00, 28.00, 22.40, 200, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(8, 4, '3 kg', 99.00, 79.00, 63.20, 100, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(9, 4, '5 kg', 155.00, 125.00, 100.00, 60, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(10, 5, '1 kg', 40.00, 32.00, 25.60, 180, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(11, 5, '3 kg', 110.00, 90.00, 72.00, 80, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(12, 6, '500ml', 28.00, 26.00, 20.80, 150, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(13, 6, '1 litre', 54.00, 50.00, 40.00, 200, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(14, 7, '400g (18 slices)', 45.00, 40.00, 32.00, 100, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(15, 8, '200g', 80.00, 72.00, 57.60, 77, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(16, 8, '500g', 190.00, 170.00, 136.00, 49, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(17, 9, '1 kg', 150.00, 129.00, 103.20, 100, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(18, 9, '5 kg', 700.00, 599.00, 479.20, 50, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(19, 9, '10 kg', 1350.00, 1149.00, 919.20, 25, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(20, 10, '1 litre', 160.00, 145.00, 116.00, 80, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(21, 10, '5 litres', 775.00, 699.00, 559.20, 40, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(22, 11, '500g', 75.00, 65.00, 52.00, 100, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(23, 11, '1 kg', 145.00, 125.00, 100.00, 80, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(24, 11, '5 kg', 690.00, 599.00, 479.20, 30, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(25, 12, '100g', 65.00, 55.00, 44.00, 120, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(26, 12, '250g', 150.00, 125.00, 100.00, 60, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(27, 13, '100g', 40.00, 34.00, 27.20, 150, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(28, 13, '200g', 75.00, 62.00, 49.60, 80, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(29, 14, '70g (single)', 14.00, 13.00, 10.40, 291, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(30, 14, '4-pack (280g)', 56.00, 50.00, 40.00, 148, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(31, 14, '12-pack (840g)', 165.00, 148.00, 118.40, 80, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(32, 15, 'White (750W)', 3500.00, 2799.00, 2239.20, 20, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(33, 15, 'Black (750W)', 3500.00, 2799.00, 2239.20, 15, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(34, 16, '24cm + 28cm + 32cm', 2199.00, 1599.00, 1279.20, 25, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(35, 17, '25 tea bags', 120.00, 99.00, 79.20, 80, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(36, 17, '50 tea bags', 230.00, 189.00, 151.20, 50, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(37, 18, '58g', 80.00, 75.00, 60.00, 144, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(38, 18, '145g', 190.00, 175.00, 140.00, 80, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(39, 19, '75g', 25.00, 22.00, 17.60, 200, '2026-06-15 01:10:01', '2026-06-15 01:10:01'),
(40, 19, '240g', 75.00, 68.00, 54.40, 120, '2026-06-15 01:10:01', '2026-06-15 01:10:01');

-- --------------------------------------------------------

--
-- Table structure for table `refunds`
--

CREATE TABLE `refunds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_order_id` bigint(20) UNSIGNED NOT NULL,
  `vendor_order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `reason` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'requested',
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subscription_plans`
--

CREATE TABLE `subscription_plans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `duration_type` varchar(255) NOT NULL,
  `duration_days` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `features` text DEFAULT NULL,
  `max_products` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `position` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subscription_plans`
--

INSERT INTO `subscription_plans` (`id`, `name`, `duration_type`, `duration_days`, `price`, `features`, `max_products`, `is_active`, `position`, `created_at`, `updated_at`) VALUES
(1, 'Basic Monthly', 'monthly', 30, 299.00, '[\"List up to 50 products\",\"Select up to 3 pincodes\",\"Basic order management\",\"Email support\"]', 50, 1, 1, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(2, 'Basic Yearly', 'yearly', 365, 2999.00, '[\"List up to 50 products\",\"Select up to 3 pincodes\",\"Basic order management\",\"Email support\",\"2 months free\"]', 50, 1, 2, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(3, 'Standard Monthly', 'monthly', 30, 599.00, '[\"List up to 200 products\",\"Select up to 10 pincodes\",\"Priority order management\",\"Chat support\",\"Analytics dashboard\"]', 200, 1, 3, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(4, 'Standard Yearly', 'yearly', 365, 5999.00, '[\"List up to 200 products\",\"Select up to 10 pincodes\",\"Priority order management\",\"Chat support\",\"Analytics dashboard\",\"2 months free\"]', 200, 1, 4, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(5, 'Premium Monthly', 'monthly', 30, 999.00, '[\"Unlimited products\",\"All pincodes\",\"Dedicated account manager\",\"24\\/7 phone support\",\"Advanced analytics\",\"Featured listings\"]', 0, 1, 5, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(6, 'Premium Yearly', 'yearly', 365, 9999.00, '[\"Unlimited products\",\"All pincodes\",\"Dedicated account manager\",\"24\\/7 phone support\",\"Advanced analytics\",\"Featured listings\",\"2 months free\"]', 0, 1, 6, '2026-06-15 01:09:58', '2026-06-15 01:09:58');

-- --------------------------------------------------------

--
-- Table structure for table `sub_category`
--

CREATE TABLE `sub_category` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `main_category_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `icon_url` varchar(255) DEFAULT NULL,
  `position` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sub_category`
--

INSERT INTO `sub_category` (`id`, `main_category_id`, `name`, `image_url`, `icon_url`, `position`, `is_active`, `created_at`) VALUES
(1, 1, 'Atta & Flour', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(2, 1, 'Rice', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(3, 1, 'Cooking Oil', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(4, 1, 'Dals & Pulses', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(5, 1, 'Ghee', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(6, 1, 'Suji, Maida & Besan', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-15 01:09:57'),
(7, 2, 'Cereals & Muesli', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(8, 2, 'Ketchup & Sauces', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(9, 2, 'Peanut Butter & Jam', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(10, 2, 'Honey & Spreads', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(11, 2, 'Oats & Porridge', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(12, 2, 'Energy & Health Bars', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-15 01:09:57'),
(13, 3, 'Milk', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(14, 3, 'Butter & Cream', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(15, 3, 'Paneer & Tofu', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(16, 3, 'Curd & Yogurt', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(17, 3, 'Bread & Buns', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(18, 3, 'Eggs', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-15 01:09:57'),
(19, 3, 'Cheese', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 7, 1, '2026-06-15 01:09:57'),
(20, 3, 'Dairy Whitener', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 8, 1, '2026-06-15 01:09:57'),
(21, 4, 'Bulbs & Lighting', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(22, 4, 'Kitchen Appliances', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(23, 4, 'Mixer & Grinder', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(24, 4, 'Smartwatches', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(25, 4, 'Speakers & Audio', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(26, 4, 'Fans & Coolers', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-15 01:09:57'),
(27, 5, 'Fresh Fruits', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(28, 5, 'Fresh Vegetables', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(29, 5, 'Leafy Greens', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(30, 5, 'Exotic Fruits', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(31, 5, 'Organic Produce', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(32, 6, 'Ice Creams', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(33, 6, 'Kulfi', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(34, 6, 'Ice Cream Bars', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(35, 6, 'Frozen Desserts', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(36, 7, 'Cookware', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(37, 7, 'Storage Containers', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(38, 7, 'Dinner Sets', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(39, 7, 'Kitchen Tools', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(40, 7, 'Bakeware', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(41, 8, 'Whole Spices', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(42, 8, 'Blended Masala', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(43, 8, 'Salt & Sugar', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(44, 8, 'Almonds & Cashews', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(45, 8, 'Raisins & Dates', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(46, 8, 'Seeds & Superfoods', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-15 01:09:57'),
(47, 9, 'Frozen Vegetables', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(48, 9, 'Frozen Snacks', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(49, 9, 'Frozen Parathas', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(50, 9, 'Frozen Meat & Seafood', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(51, 10, 'Chocolates', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(52, 10, 'Cookies & Biscuits', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(53, 10, 'Cakes & Pastries', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(54, 10, 'Mithai & Sweets', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(55, 10, 'Candies & Gummies', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(56, 11, 'Tea', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(57, 11, 'Coffee', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(58, 11, 'Green Tea', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(59, 11, 'Health Drinks', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(60, 11, 'Juices & Shakes', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(61, 12, 'Instant Noodles', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-15 01:09:57'),
(62, 12, 'Ready to Cook', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-15 01:09:57'),
(63, 12, 'Chips & Namkeen', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-15 01:09:57'),
(64, 12, 'Canned & Tinned', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-15 01:09:57'),
(65, 12, 'Pasta & Vermicelli', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-15 01:09:57'),
(66, 12, 'Soups & Broths', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-15 01:09:57');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `pincode_id` bigint(20) UNSIGNED DEFAULT NULL,
  `date_time` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `status`, `pincode_id`, `date_time`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Rahul Sharma', 'rahul@example.com', 'active', NULL, NULL, NULL, '$2y$12$INTTalV5G20QYcLQVyGwoOUzigHxZbSsN.qfheDp6It2RR4kRYXFG', NULL, '2026-06-15 05:37:52', '2026-06-15 05:37:52'),
(2, 'Priya Verma', 'priya@example.com', 'active', NULL, NULL, NULL, '$2y$12$Gb/OESd1ZvBGw.vz0odp9.gqXABZ0YlJ8S2c2YwXwFqGk0yBAVAtW', NULL, '2026-06-15 05:37:53', '2026-06-15 05:37:53'),
(3, 'Amit Kumar', 'amit@example.com', 'active', NULL, NULL, NULL, '$2y$12$jE2Af9VLi/AlPq8IRsaPZ.1mBlgHepCiXxVC14eo7q/iq1fTLDoTW', NULL, '2026-06-15 05:37:53', '2026-06-15 05:37:53'),
(4, 'Sneha Patel', 'sneha@example.com', 'active', NULL, NULL, NULL, '$2y$12$YTop674bUYl3rzJ9UZlAde15SpuMtNM7AToLEWRXqo9325F7GqfpW', NULL, '2026-06-15 05:37:53', '2026-06-15 05:37:53'),
(5, 'Vikas Singh', 'vikas@example.com', 'active', NULL, NULL, NULL, '$2y$12$QtLVsHS3JCA5/fb.QmVuqOIr5udLh/ylAUNFBXQFmSC45Z8qYE32m', NULL, '2026-06-15 05:37:53', '2026-06-15 05:37:53'),
(6, 'OrdTest', 'ord7440@t.com', 'active', NULL, NULL, NULL, '$2y$12$I4AFOLYJJLkLEnq.H5nHfe6MNtQehcunlCzmpL7vAfTR.RISzo9hm', NULL, NULL, NULL),
(7, 'OrdT', 'o24609@t.com', 'active', NULL, NULL, NULL, '$2y$12$r/33LR0/VSuGetIgDwGlNu8qHywYAhAXuNMd3ZDx/l4VxZc.96B4O', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `vendors`
--

CREATE TABLE `vendors` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `shop_name` varchar(255) NOT NULL,
  `shop_description` text DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `commission_rate` decimal(5,2) DEFAULT NULL,
  `payout_account` varchar(150) DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vendors`
--

INSERT INTO `vendors` (`id`, `name`, `email`, `phone`, `password`, `shop_name`, `shop_description`, `logo`, `status`, `commission_rate`, `payout_account`, `rejection_reason`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Ravi Groceries', 'ravi@vendor.com', '9876543210', '$2y$12$ZGQJ5dieAbxFEYQIjL9N7ucyKEQjYS.01R.TCBtSVHWkMhyZHqrW6', 'Ravi Fresh Store', 'Fresh fruits, vegetables and dairy products delivered daily.', 'vendors/scaled_logo (4).png', 'approved', NULL, NULL, NULL, NULL, '2026-06-15 01:09:58', '2026-06-15 05:12:35'),
(2, 'Meena Supermart', 'meena@vendor.com', '9123456780', '$2y$12$0SZ0OKEVsWzSnszcVa6F0u8tA7f9uDHCvQbPKi1RYXeGOJnjkfBA2', 'Meena Super Mart', 'Your one-stop shop for packaged food, snacks and beverages.', 'vendors/scaled_logo (4).png', 'approved', NULL, NULL, NULL, NULL, '2026-06-15 01:09:58', '2026-06-15 05:20:45'),
(3, 'Deepak Electronics', 'deepak@vendor.com', '9988776655', '$2y$12$Ok5036/wL35k3dX9ZIWbEOWEZaG3U3pYMWLcjf.FHoLGpR/Xd6z5G', 'Deepak Electronics Hub', 'Kitchen appliances, gadgets and electronics at best prices.', 'vendors/scaled_logo (4).png', 'suspended', NULL, NULL, NULL, NULL, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(4, 'Sunita Dairy', 'sunita@vendor.com', '9001122334', '$2y$12$x94ZA6Dj5dnOIpTjnJTOm.aSBNFSamJEsh.LRNCHnlV7F39F2aGOW', 'Sunita Pure Dairy', 'Organic dairy products — milk, curd, paneer and ghee.', NULL, 'approved', NULL, NULL, NULL, NULL, '2026-06-15 01:09:58', '2026-06-15 05:23:40'),
(5, 'Prakash Spices', 'prakash@vendor.com', '9445566778', '$2y$12$fjcnmRSWi2fIHWaEO7EpUe10XVLysrdkGyjYVDJQ5haubtQworyqy', 'Prakash Masala King', 'Authentic Indian spices and masalas sourced directly from farms.', NULL, 'suspended', NULL, NULL, NULL, NULL, '2026-06-15 01:09:58', '2026-06-15 01:09:58');

-- --------------------------------------------------------

--
-- Table structure for table `vendor_orders`
--

CREATE TABLE `vendor_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_order_id` bigint(20) UNSIGNED NOT NULL,
  `vendor_id` bigint(20) UNSIGNED NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `items_subtotal` decimal(10,2) NOT NULL DEFAULT 0.00,
  `commission_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `commission_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `vendor_earning` decimal(10,2) NOT NULL DEFAULT 0.00,
  `delivery_boy_id` bigint(20) UNSIGNED DEFAULT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `courier_name` varchar(100) DEFAULT NULL,
  `cancel_reason` varchar(255) DEFAULT NULL,
  `payout_id` bigint(20) UNSIGNED DEFAULT NULL,
  `confirmed_at` timestamp NULL DEFAULT NULL,
  `packed_at` timestamp NULL DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `picked_up_at` timestamp NULL DEFAULT NULL,
  `out_for_delivery_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vendor_orders`
--

INSERT INTO `vendor_orders` (`id`, `parent_order_id`, `vendor_id`, `status`, `items_subtotal`, `commission_rate`, `commission_amount`, `vendor_earning`, `delivery_boy_id`, `tracking_number`, `courier_name`, `cancel_reason`, `payout_id`, `confirmed_at`, `packed_at`, `assigned_at`, `picked_up_at`, `out_for_delivery_at`, `delivered_at`, `cancelled_at`, `created_at`, `updated_at`) VALUES
(1, 11, 2, 'delivered', 342.00, 0.00, 0.00, 342.00, 1, NULL, NULL, NULL, NULL, '2026-06-16 01:25:14', '2026-06-16 01:25:23', '2026-06-16 01:27:11', NULL, '2026-06-16 01:27:28', '2026-06-16 01:27:33', NULL, '2026-06-16 00:59:45', '2026-06-16 01:27:33'),
(2, 12, 2, 'delivered', 1287.00, 0.00, 0.00, 1287.00, 2, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-16 01:15:15', NULL, '2026-06-16 01:15:24', '2026-06-16 01:25:01', NULL, '2026-06-16 00:59:45', '2026-06-16 01:25:01'),
(3, 13, 2, 'delivered', 100.00, 0.00, 0.00, 100.00, NULL, NULL, NULL, NULL, NULL, '2026-06-16 01:06:15', NULL, NULL, NULL, '2026-06-16 01:06:28', '2026-06-16 01:06:47', NULL, '2026-06-16 00:59:45', '2026-06-16 01:06:47'),
(4, 14, 2, 'delivered', 150.00, 0.00, 0.00, 150.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-16 01:14:44', NULL, '2026-06-16 00:59:45', '2026-06-16 01:14:44'),
(5, 15, 1, 'delivered', 72.00, 0.00, 0.00, 72.00, 1, NULL, NULL, NULL, NULL, '2026-06-16 05:24:04', '2026-06-16 05:24:08', '2026-06-16 05:24:14', NULL, '2026-06-16 05:24:19', '2026-06-16 05:24:23', NULL, '2026-06-16 04:43:38', '2026-06-16 05:24:23'),
(6, 15, 2, 'delivered', 75.00, 0.00, 0.00, 75.00, 1, NULL, NULL, NULL, NULL, '2026-06-16 04:47:24', '2026-06-16 04:47:32', '2026-06-16 04:47:43', '2026-06-16 04:48:16', '2026-06-16 04:48:30', '2026-06-16 04:48:44', NULL, '2026-06-16 04:43:38', '2026-06-16 04:48:44'),
(7, 16, 2, 'pending', 150.00, 0.00, 0.00, 150.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-16 05:42:37', '2026-06-16 05:42:37'),
(8, 17, 1, 'delivered', 170.00, 0.00, 0.00, 170.00, 3, NULL, NULL, NULL, NULL, '2026-06-16 05:43:21', '2026-06-16 05:43:25', '2026-06-16 05:44:46', NULL, '2026-06-16 05:44:51', '2026-06-16 05:45:29', NULL, '2026-06-16 05:43:11', '2026-06-16 05:45:29'),
(9, 18, 1, 'delivered', 144.00, 0.00, 0.00, 144.00, 3, NULL, NULL, NULL, NULL, '2026-06-16 05:47:02', '2026-06-16 05:47:05', '2026-06-16 05:47:12', NULL, '2026-06-16 05:47:45', '2026-06-16 05:48:09', NULL, '2026-06-16 05:46:55', '2026-06-16 05:48:09');

-- --------------------------------------------------------

--
-- Table structure for table `vendor_payouts`
--

CREATE TABLE `vendor_payouts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `vendor_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `period_start` date DEFAULT NULL,
  `period_end` date DEFAULT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vendor_pincodes`
--

CREATE TABLE `vendor_pincodes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `vendor_id` bigint(20) UNSIGNED NOT NULL,
  `pincode_id` bigint(20) UNSIGNED DEFAULT NULL,
  `pincode` varchar(10) NOT NULL,
  `area_name` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vendor_pincodes`
--

INSERT INTO `vendor_pincodes` (`id`, `vendor_id`, `pincode_id`, `pincode`, `area_name`, `is_active`, `created_at`) VALUES
(1, 1, 1, '110001', 'Connaught Place', 1, '2026-06-15 01:09:58'),
(2, 1, 2, '110002', 'Darya Ganj', 1, '2026-06-15 01:09:58'),
(3, 1, 4, '110011', 'Karol Bagh', 1, '2026-06-15 01:09:58'),
(4, 1, 6, '110020', 'Saket', 1, '2026-06-15 01:09:58'),
(8, 3, 10, '560001', 'MG Road', 1, '2026-06-15 01:09:58'),
(9, 3, 11, '560034', 'Jayanagar', 1, '2026-06-15 01:09:58'),
(10, 3, 15, '411001', 'Shivajinagar', 1, '2026-06-15 01:09:58'),
(11, 2, 1, '110001', 'Connaught Place', 1, '2026-06-16 10:30:13'),
(12, 2, 2, '110002', 'Darya Ganj', 1, '2026-06-16 10:30:13'),
(13, 2, 3, '110003', 'Lodi Road', 1, '2026-06-16 10:30:13');

-- --------------------------------------------------------

--
-- Table structure for table `vendor_subscriptions`
--

CREATE TABLE `vendor_subscriptions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `vendor_id` bigint(20) UNSIGNED NOT NULL,
  `plan_id` bigint(20) UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `payment_reference` varchar(255) DEFAULT NULL,
  `payment_mode` varchar(255) DEFAULT NULL,
  `amount_paid` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vendor_subscriptions`
--

INSERT INTO `vendor_subscriptions` (`id`, `vendor_id`, `plan_id`, `start_date`, `end_date`, `status`, `payment_reference`, `payment_mode`, `amount_paid`, `created_at`, `updated_at`) VALUES
(1, 1, 3, '2026-06-15', '2026-07-15', 'active', NULL, NULL, NULL, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(2, 2, 5, '2026-06-15', '2026-07-15', 'active', NULL, NULL, NULL, '2026-06-15 01:09:58', '2026-06-15 01:09:58'),
(3, 3, 1, '2026-06-15', '2026-07-15', 'active', NULL, NULL, NULL, '2026-06-15 01:09:58', '2026-06-15 01:09:58');

-- --------------------------------------------------------

--
-- Table structure for table `wishlist`
--

CREATE TABLE `wishlist` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wishlist`
--

INSERT INTO `wishlist` (`id`, `user_id`, `product_id`, `created_at`) VALUES
(1, 3, 9, '2026-06-15 01:10:03'),
(2, 3, 10, '2026-06-15 01:10:03'),
(3, 2, 11, '2026-06-15 01:10:03');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_email_unique` (`email`);

--
-- Indexes for table `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `app_settings_key_unique` (`key`);

--
-- Indexes for table `banner`
--
ALTER TABLE `banner`
  ADD PRIMARY KEY (`id`),
  ADD KEY `banner_category_id_foreign` (`category_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_items_user_id_foreign` (`user_id`),
  ADD KEY `cart_items_product_id_foreign` (`product_id`);

--
-- Indexes for table `city`
--
ALTER TABLE `city`
  ADD PRIMARY KEY (`id`),
  ADD KEY `city_district_id_foreign` (`district_id`);

--
-- Indexes for table `coupon`
--
ALTER TABLE `coupon`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `coupon_code_name_unique` (`code_name`);

--
-- Indexes for table `delivery_address`
--
ALTER TABLE `delivery_address`
  ADD PRIMARY KEY (`id`),
  ADD KEY `delivery_address_user_id_foreign` (`user_id`);

--
-- Indexes for table `delivery_boy`
--
ALTER TABLE `delivery_boy`
  ADD PRIMARY KEY (`id`),
  ADD KEY `delivery_boy_vendor_id_index` (`vendor_id`);

--
-- Indexes for table `delivery_charge`
--
ALTER TABLE `delivery_charge`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `deliver_time`
--
ALTER TABLE `deliver_time`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `district`
--
ALTER TABLE `district`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `flash_deals`
--
ALTER TABLE `flash_deals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `flash_deals_product_id_foreign` (`product_id`),
  ADD KEY `flash_deals_variant_id_foreign` (`variant_id`);

--
-- Indexes for table `free_delivey`
--
ALTER TABLE `free_delivey`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `handling_charge`
--
ALTER TABLE `handling_charge`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `help_call`
--
ALTER TABLE `help_call`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `help_email`
--
ALTER TABLE `help_email`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `help_whatsapp`
--
ALTER TABLE `help_whatsapp`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `home_sections`
--
ALTER TABLE `home_sections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `home_sections_main_category_id_foreign` (`main_category_id`);

--
-- Indexes for table `home_tabs`
--
ALTER TABLE `home_tabs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `main_category`
--
ALTER TABLE `main_category`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `minimum_order_amout`
--
ALTER TABLE `minimum_order_amout`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_user_id_foreign` (`user_id`),
  ADD KEY `orders_location_id_foreign` (`location_id`),
  ADD KEY `orders_vendor_id_foreign` (`vendor_id`);

--
-- Indexes for table `order_assignment`
--
ALTER TABLE `order_assignment`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_assignment_order_id_foreign` (`order_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_vendor_order_id_index` (`vendor_order_id`);

--
-- Indexes for table `order_status_history`
--
ALTER TABLE `order_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_status_history_parent_order_id_index` (`parent_order_id`),
  ADD KEY `order_status_history_vendor_order_id_index` (`vendor_order_id`);

--
-- Indexes for table `otp_table`
--
ALTER TABLE `otp_table`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `otp_table_email_unique` (`email`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `pincodes`
--
ALTER TABLE `pincodes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pincodes_code_unique` (`code`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `products_main_category_id_foreign` (`main_category_id`),
  ADD KEY `products_subcategory_id_foreign` (`subcategory_id`),
  ADD KEY `products_brand_id_foreign` (`brand_id`),
  ADD KEY `products_vendor_id_foreign` (`vendor_id`);

--
-- Indexes for table `product_highlights`
--
ALTER TABLE `product_highlights`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_highlights_product_id_foreign` (`product_id`);

--
-- Indexes for table `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_images_product_id_foreign` (`product_id`);

--
-- Indexes for table `product_info`
--
ALTER TABLE `product_info`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_info_product_id_foreign` (`product_id`);

--
-- Indexes for table `product_types`
--
ALTER TABLE `product_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `product_types_name_unique` (`name`);

--
-- Indexes for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_variants_product_id_foreign` (`product_id`);

--
-- Indexes for table `refunds`
--
ALTER TABLE `refunds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `refunds_parent_order_id_index` (`parent_order_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `subscription_plans`
--
ALTER TABLE `subscription_plans`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sub_category`
--
ALTER TABLE `sub_category`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sub_category_main_category_id_foreign` (`main_category_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `vendors`
--
ALTER TABLE `vendors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `vendors_email_unique` (`email`);

--
-- Indexes for table `vendor_orders`
--
ALTER TABLE `vendor_orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `vendor_orders_parent_order_id_vendor_id_unique` (`parent_order_id`,`vendor_id`),
  ADD KEY `vendor_orders_vendor_id_status_index` (`vendor_id`,`status`);

--
-- Indexes for table `vendor_payouts`
--
ALTER TABLE `vendor_payouts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vendor_payouts_vendor_id_status_index` (`vendor_id`,`status`);

--
-- Indexes for table `vendor_pincodes`
--
ALTER TABLE `vendor_pincodes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `vendor_pincodes_vendor_id_pincode_unique` (`vendor_id`,`pincode`),
  ADD UNIQUE KEY `vendor_pincodes_vendor_id_pincode_id_unique` (`vendor_id`,`pincode_id`),
  ADD KEY `vendor_pincodes_pincode_index` (`pincode`),
  ADD KEY `vendor_pincodes_pincode_id_foreign` (`pincode_id`);

--
-- Indexes for table `vendor_subscriptions`
--
ALTER TABLE `vendor_subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vendor_subscriptions_vendor_id_foreign` (`vendor_id`),
  ADD KEY `vendor_subscriptions_plan_id_foreign` (`plan_id`);

--
-- Indexes for table `wishlist`
--
ALTER TABLE `wishlist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `wishlist_user_id_product_id_unique` (`user_id`,`product_id`),
  ADD KEY `wishlist_product_id_foreign` (`product_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `banner`
--
ALTER TABLE `banner`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `city`
--
ALTER TABLE `city`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `coupon`
--
ALTER TABLE `coupon`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `delivery_address`
--
ALTER TABLE `delivery_address`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `delivery_boy`
--
ALTER TABLE `delivery_boy`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `delivery_charge`
--
ALTER TABLE `delivery_charge`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `deliver_time`
--
ALTER TABLE `deliver_time`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `district`
--
ALTER TABLE `district`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `flash_deals`
--
ALTER TABLE `flash_deals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `free_delivey`
--
ALTER TABLE `free_delivey`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `handling_charge`
--
ALTER TABLE `handling_charge`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `help_call`
--
ALTER TABLE `help_call`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `help_email`
--
ALTER TABLE `help_email`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `help_whatsapp`
--
ALTER TABLE `help_whatsapp`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `home_sections`
--
ALTER TABLE `home_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `home_tabs`
--
ALTER TABLE `home_tabs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `main_category`
--
ALTER TABLE `main_category`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `minimum_order_amout`
--
ALTER TABLE `minimum_order_amout`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `order_assignment`
--
ALTER TABLE `order_assignment`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `order_status_history`
--
ALTER TABLE `order_status_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `otp_table`
--
ALTER TABLE `otp_table`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `pincodes`
--
ALTER TABLE `pincodes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `product_highlights`
--
ALTER TABLE `product_highlights`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `product_info`
--
ALTER TABLE `product_info`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT for table `product_types`
--
ALTER TABLE `product_types`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `refunds`
--
ALTER TABLE `refunds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subscription_plans`
--
ALTER TABLE `subscription_plans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `sub_category`
--
ALTER TABLE `sub_category`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `vendors`
--
ALTER TABLE `vendors`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `vendor_orders`
--
ALTER TABLE `vendor_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `vendor_payouts`
--
ALTER TABLE `vendor_payouts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vendor_pincodes`
--
ALTER TABLE `vendor_pincodes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `vendor_subscriptions`
--
ALTER TABLE `vendor_subscriptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `wishlist`
--
ALTER TABLE `wishlist`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `banner`
--
ALTER TABLE `banner`
  ADD CONSTRAINT `banner_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `main_category` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `city`
--
ALTER TABLE `city`
  ADD CONSTRAINT `city_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `district` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `delivery_address`
--
ALTER TABLE `delivery_address`
  ADD CONSTRAINT `delivery_address_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `flash_deals`
--
ALTER TABLE `flash_deals`
  ADD CONSTRAINT `flash_deals_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `flash_deals_variant_id_foreign` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `home_sections`
--
ALTER TABLE `home_sections`
  ADD CONSTRAINT `home_sections_main_category_id_foreign` FOREIGN KEY (`main_category_id`) REFERENCES `main_category` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `delivery_address` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `order_assignment`
--
ALTER TABLE `order_assignment`
  ADD CONSTRAINT `order_assignment_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_brand_id_foreign` FOREIGN KEY (`brand_id`) REFERENCES `main_category` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_main_category_id_foreign` FOREIGN KEY (`main_category_id`) REFERENCES `main_category` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_subcategory_id_foreign` FOREIGN KEY (`subcategory_id`) REFERENCES `sub_category` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `product_highlights`
--
ALTER TABLE `product_highlights`
  ADD CONSTRAINT `product_highlights_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `product_images_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_info`
--
ALTER TABLE `product_info`
  ADD CONSTRAINT `product_info_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `product_variants_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sub_category`
--
ALTER TABLE `sub_category`
  ADD CONSTRAINT `sub_category_main_category_id_foreign` FOREIGN KEY (`main_category_id`) REFERENCES `main_category` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vendor_orders`
--
ALTER TABLE `vendor_orders`
  ADD CONSTRAINT `vendor_orders_parent_order_id_foreign` FOREIGN KEY (`parent_order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vendor_pincodes`
--
ALTER TABLE `vendor_pincodes`
  ADD CONSTRAINT `vendor_pincodes_pincode_id_foreign` FOREIGN KEY (`pincode_id`) REFERENCES `pincodes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vendor_pincodes_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vendor_subscriptions`
--
ALTER TABLE `vendor_subscriptions`
  ADD CONSTRAINT `vendor_subscriptions_plan_id_foreign` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`),
  ADD CONSTRAINT `vendor_subscriptions_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wishlist`
--
ALTER TABLE `wishlist`
  ADD CONSTRAINT `wishlist_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlist_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
