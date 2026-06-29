-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 29, 2026 at 12:45 PM
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
(1, 'admin@shopq.com', '$2y$12$RF6pB8RQUX.Eg49rdkCDv.Kw03wJ.ZePuu5uYMrOj8b6etP7H4CcK', '2026-06-27 06:00:05', '2026-06-27 06:00:05');

-- --------------------------------------------------------

--
-- Table structure for table `app_notifications`
--

CREATE TABLE `app_notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `notifiable_type` varchar(255) NOT NULL,
  `notifiable_id` bigint(20) UNSIGNED NOT NULL,
  `campaign_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'custom',
  `title` varchar(255) NOT NULL,
  `body` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `clicked_at` timestamp NULL DEFAULT NULL,
  `archived_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_notifications`
--

INSERT INTO `app_notifications` (`id`, `notifiable_type`, `notifiable_id`, `campaign_id`, `type`, `title`, `body`, `image`, `data`, `read_at`, `clicked_at`, `archived_at`, `created_at`, `updated_at`) VALUES
(34, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #2 is now: Confirmed.', NULL, '{\"order_id\":\"2\",\"status\":\"confirmed\",\"deeplink\":\"shopq:\\/\\/order\\/2\"}', '2026-06-29 03:30:45', NULL, NULL, '2026-06-29 03:28:13', '2026-06-29 03:30:45'),
(35, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #2 is now: Packed.', NULL, '{\"order_id\":\"2\",\"status\":\"packed\",\"deeplink\":\"shopq:\\/\\/order\\/2\"}', '2026-06-29 03:30:45', NULL, NULL, '2026-06-29 03:28:26', '2026-06-29 03:30:45'),
(36, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #2 is now: Assigned.', NULL, '{\"order_id\":\"2\",\"status\":\"assigned\",\"deeplink\":\"shopq:\\/\\/order\\/2\"}', '2026-06-29 03:30:45', NULL, NULL, '2026-06-29 03:28:49', '2026-06-29 03:30:45'),
(37, 'App\\Models\\DeliveryBoy', 1, NULL, 'new_assignment', 'New delivery assigned', 'Order #2 has been assigned to you.', NULL, '{\"order_id\":\"2\",\"deeplink\":\"shopq:\\/\\/order\"}', '2026-06-29 04:30:26', NULL, NULL, '2026-06-29 03:28:50', '2026-06-29 04:30:26'),
(38, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #2 is now: Out For Delivery.', NULL, '{\"order_id\":\"2\",\"status\":\"out_for_delivery\",\"deeplink\":\"shopq:\\/\\/order\\/2\"}', '2026-06-29 03:30:45', NULL, NULL, '2026-06-29 03:29:06', '2026-06-29 03:30:45'),
(39, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #2 is now: Delivered.', NULL, '{\"order_id\":\"2\",\"status\":\"delivered\",\"deeplink\":\"shopq:\\/\\/order\\/2\"}', '2026-06-29 03:30:42', '2026-06-29 03:30:42', NULL, '2026-06-29 03:29:13', '2026-06-29 03:30:42'),
(40, 'App\\Models\\User', 1, 23, 'promo', 'Sync Send Test', 'works without worker', NULL, '[]', '2026-06-29 03:33:33', '2026-06-29 03:33:33', NULL, '2026-06-29 03:33:23', '2026-06-29 03:33:33'),
(41, 'App\\Models\\User', 2, 23, 'promo', 'Sync Send Test', 'works without worker', NULL, '[]', NULL, NULL, NULL, '2026-06-29 03:33:24', '2026-06-29 03:33:24'),
(42, 'App\\Models\\User', 3, 23, 'promo', 'Sync Send Test', 'works without worker', NULL, '[]', NULL, NULL, NULL, '2026-06-29 03:33:24', '2026-06-29 03:33:24'),
(43, 'App\\Models\\User', 4, 23, 'promo', 'Sync Send Test', 'works without worker', NULL, '[]', NULL, NULL, NULL, '2026-06-29 03:33:24', '2026-06-29 03:33:24'),
(44, 'App\\Models\\User', 5, 23, 'promo', 'Sync Send Test', 'works without worker', NULL, '[]', NULL, NULL, NULL, '2026-06-29 03:33:24', '2026-06-29 03:33:24'),
(45, 'App\\Models\\User', 1, 21, 'promotional_offer', 'Special offer just for you! 🎉', 'Exclusive deals are live — grab them before they\'re gone.', NULL, '{\"deeplink\":\"shopq:\\/\\/offers\"}', '2026-06-29 03:49:26', NULL, NULL, '2026-06-29 03:34:56', '2026-06-29 03:49:26'),
(46, 'App\\Models\\User', 2, 21, 'promotional_offer', 'Special offer just for you! 🎉', 'Exclusive deals are live — grab them before they\'re gone.', NULL, '{\"deeplink\":\"shopq:\\/\\/offers\"}', NULL, NULL, NULL, '2026-06-29 03:34:58', '2026-06-29 03:34:58'),
(47, 'App\\Models\\User', 3, 21, 'promotional_offer', 'Special offer just for you! 🎉', 'Exclusive deals are live — grab them before they\'re gone.', NULL, '{\"deeplink\":\"shopq:\\/\\/offers\"}', NULL, NULL, NULL, '2026-06-29 03:34:58', '2026-06-29 03:34:58'),
(48, 'App\\Models\\User', 4, 21, 'promotional_offer', 'Special offer just for you! 🎉', 'Exclusive deals are live — grab them before they\'re gone.', NULL, '{\"deeplink\":\"shopq:\\/\\/offers\"}', NULL, NULL, NULL, '2026-06-29 03:34:58', '2026-06-29 03:34:58'),
(49, 'App\\Models\\User', 5, 21, 'promotional_offer', 'Special offer just for you! 🎉', 'Exclusive deals are live — grab them before they\'re gone.', NULL, '{\"deeplink\":\"shopq:\\/\\/offers\"}', NULL, NULL, NULL, '2026-06-29 03:34:58', '2026-06-29 03:34:58'),
(50, 'App\\Models\\User', 1, 24, 'general_announcement', 'New arrivals are here! 🆕', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', '2026-06-29 03:49:26', NULL, NULL, '2026-06-29 03:35:39', '2026-06-29 03:49:26'),
(51, 'App\\Models\\User', 2, 24, 'general_announcement', 'New arrivals are here! 🆕', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, NULL, NULL, '2026-06-29 03:35:40', '2026-06-29 03:35:40'),
(52, 'App\\Models\\User', 3, 24, 'general_announcement', 'New arrivals are here! 🆕', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, NULL, NULL, '2026-06-29 03:35:40', '2026-06-29 03:35:40'),
(53, 'App\\Models\\User', 4, 24, 'general_announcement', 'New arrivals are here! 🆕', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, NULL, NULL, '2026-06-29 03:35:40', '2026-06-29 03:35:40'),
(54, 'App\\Models\\User', 5, 24, 'general_announcement', 'New arrivals are here! 🆕', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, NULL, NULL, '2026-06-29 03:35:40', '2026-06-29 03:35:40'),
(55, 'App\\Models\\User', 1, 25, 'general_announcement', 'New arrivals are here! 🆕 (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', '2026-06-29 03:42:14', '2026-06-29 03:42:14', NULL, '2026-06-29 03:38:13', '2026-06-29 03:42:14'),
(56, 'App\\Models\\User', 1, 26, 'general_announcement', 'New arrivals are here! 🆕 (copy) (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', '2026-06-29 03:40:34', '2026-06-29 03:40:34', NULL, '2026-06-29 03:38:21', '2026-06-29 03:40:34'),
(57, 'App\\Models\\Vendor', 1, 28, 'general_announcement', 'New arrivals are here! 🆕 (copy) (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, NULL, NULL, '2026-06-29 03:48:41', '2026-06-29 03:48:41'),
(58, 'App\\Models\\Vendor', 2, 28, 'general_announcement', 'New arrivals are here! 🆕 (copy) (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', '2026-06-29 03:49:03', NULL, NULL, '2026-06-29 03:48:42', '2026-06-29 03:49:03'),
(59, 'App\\Models\\Vendor', 3, 28, 'general_announcement', 'New arrivals are here! 🆕 (copy) (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, NULL, NULL, '2026-06-29 03:48:44', '2026-06-29 03:48:44'),
(60, 'App\\Models\\Vendor', 4, 28, 'general_announcement', 'New arrivals are here! 🆕 (copy) (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, NULL, NULL, '2026-06-29 03:48:44', '2026-06-29 03:48:44'),
(61, 'App\\Models\\Vendor', 5, 28, 'general_announcement', 'New arrivals are here! 🆕 (copy) (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, NULL, NULL, '2026-06-29 03:48:44', '2026-06-29 03:48:44'),
(62, 'App\\Models\\Vendor', 1, 29, 'vendor_update', 'Payout ready', 'Your settlement is ready.', NULL, '{\"deeplink\":\"shopq:\\/\\/payouts\"}', NULL, NULL, NULL, '2026-06-29 03:58:35', '2026-06-29 03:58:35'),
(63, 'App\\Models\\Vendor', 2, 29, 'vendor_update', 'Payout ready', 'Your settlement is ready.', NULL, '{\"deeplink\":\"shopq:\\/\\/payouts\"}', '2026-06-29 03:58:53', NULL, NULL, '2026-06-29 03:58:37', '2026-06-29 03:58:53'),
(64, 'App\\Models\\Vendor', 3, 29, 'vendor_update', 'Payout ready', 'Your settlement is ready.', NULL, '{\"deeplink\":\"shopq:\\/\\/payouts\"}', NULL, NULL, NULL, '2026-06-29 03:58:38', '2026-06-29 03:58:38'),
(65, 'App\\Models\\Vendor', 4, 29, 'vendor_update', 'Payout ready', 'Your settlement is ready.', NULL, '{\"deeplink\":\"shopq:\\/\\/payouts\"}', NULL, NULL, NULL, '2026-06-29 03:58:38', '2026-06-29 03:58:38'),
(66, 'App\\Models\\Vendor', 5, 29, 'vendor_update', 'Payout ready', 'Your settlement is ready.', NULL, '{\"deeplink\":\"shopq:\\/\\/payouts\"}', NULL, NULL, NULL, '2026-06-29 03:58:38', '2026-06-29 03:58:38'),
(67, 'App\\Models\\Vendor', 1, 30, 'general_announcement', 'test', 'test fdgdfg', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, NULL, NULL, '2026-06-29 04:00:44', '2026-06-29 04:00:44'),
(68, 'App\\Models\\Vendor', 2, 30, 'general_announcement', 'test', 'test fdgdfg', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', '2026-06-29 04:00:54', NULL, NULL, '2026-06-29 04:00:45', '2026-06-29 04:00:54'),
(69, 'App\\Models\\Vendor', 3, 30, 'general_announcement', 'test', 'test fdgdfg', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, NULL, NULL, '2026-06-29 04:00:47', '2026-06-29 04:00:47'),
(70, 'App\\Models\\Vendor', 4, 30, 'general_announcement', 'test', 'test fdgdfg', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, NULL, NULL, '2026-06-29 04:00:47', '2026-06-29 04:00:47'),
(71, 'App\\Models\\Vendor', 5, 30, 'general_announcement', 'test', 'test fdgdfg', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, NULL, NULL, '2026-06-29 04:00:47', '2026-06-29 04:00:47'),
(72, 'App\\Models\\Vendor', 1, 31, 'stock_warning', 'hgfhfg', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/orders\"}', NULL, NULL, NULL, '2026-06-29 04:18:43', '2026-06-29 04:18:43'),
(73, 'App\\Models\\Vendor', 2, 31, 'stock_warning', 'hgfhfg', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/orders\"}', '2026-06-29 04:18:52', NULL, NULL, '2026-06-29 04:18:45', '2026-06-29 04:18:52'),
(74, 'App\\Models\\Vendor', 3, 31, 'stock_warning', 'hgfhfg', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/orders\"}', NULL, NULL, NULL, '2026-06-29 04:18:47', '2026-06-29 04:18:47'),
(75, 'App\\Models\\Vendor', 4, 31, 'stock_warning', 'hgfhfg', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/orders\"}', NULL, NULL, NULL, '2026-06-29 04:18:47', '2026-06-29 04:18:47'),
(76, 'App\\Models\\Vendor', 5, 31, 'stock_warning', 'hgfhfg', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/orders\"}', NULL, NULL, NULL, '2026-06-29 04:18:47', '2026-06-29 04:18:47'),
(77, 'App\\Models\\Vendor', 1, 32, 'stock_warning', 'hgfhfg (copy)', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, NULL, NULL, '2026-06-29 04:19:15', '2026-06-29 04:19:15'),
(78, 'App\\Models\\Vendor', 2, 32, 'stock_warning', 'hgfhfg (copy)', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', '2026-06-29 04:19:23', NULL, NULL, '2026-06-29 04:19:16', '2026-06-29 04:19:23'),
(79, 'App\\Models\\Vendor', 3, 32, 'stock_warning', 'hgfhfg (copy)', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, NULL, NULL, '2026-06-29 04:19:19', '2026-06-29 04:19:19'),
(80, 'App\\Models\\Vendor', 4, 32, 'stock_warning', 'hgfhfg (copy)', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, NULL, NULL, '2026-06-29 04:19:19', '2026-06-29 04:19:19'),
(81, 'App\\Models\\Vendor', 5, 32, 'stock_warning', 'hgfhfg (copy)', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, NULL, NULL, '2026-06-29 04:19:19', '2026-06-29 04:19:19'),
(82, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #1 is now: Confirmed.', NULL, '{\"order_id\":\"1\",\"status\":\"confirmed\",\"deeplink\":\"shopq:\\/\\/order\\/1\"}', '2026-06-29 04:22:39', NULL, NULL, '2026-06-29 04:22:25', '2026-06-29 04:22:39'),
(83, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #1 is now: Confirmed.', NULL, '{\"order_id\":\"1\",\"status\":\"confirmed\",\"deeplink\":\"shopq:\\/\\/order\\/1\"}', '2026-06-29 04:22:39', NULL, NULL, '2026-06-29 04:22:27', '2026-06-29 04:22:39'),
(84, 'App\\Models\\Vendor', 2, NULL, 'new_order', 'New order received', 'You have a new order #3.', NULL, '{\"order_id\":\"3\",\"deeplink\":\"shopq:\\/\\/order\"}', '2026-06-29 04:26:28', NULL, NULL, '2026-06-29 04:23:48', '2026-06-29 04:26:28'),
(85, 'App\\Models\\Vendor', 2, NULL, 'new_order', 'New order received', 'You have a new order #4.', NULL, '{\"order_id\":\"4\",\"deeplink\":\"shopq:\\/\\/order\"}', '2026-06-29 04:28:15', NULL, NULL, '2026-06-29 04:26:55', '2026-06-29 04:28:15'),
(86, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #3 is now: Confirmed.', NULL, '{\"order_id\":\"3\",\"status\":\"confirmed\",\"deeplink\":\"shopq:\\/\\/order\\/3\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:28:20', '2026-06-29 04:34:56'),
(87, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #3 is now: Packed.', NULL, '{\"order_id\":\"3\",\"status\":\"packed\",\"deeplink\":\"shopq:\\/\\/order\\/3\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:28:27', '2026-06-29 04:34:56'),
(88, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #3 is now: Assigned.', NULL, '{\"order_id\":\"3\",\"status\":\"assigned\",\"deeplink\":\"shopq:\\/\\/order\\/3\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:28:33', '2026-06-29 04:34:56'),
(89, 'App\\Models\\DeliveryBoy', 1, NULL, 'new_assignment', 'New delivery assigned', 'Order #3 has been assigned to you.', NULL, '{\"order_id\":\"3\",\"deeplink\":\"shopq:\\/\\/order\"}', '2026-06-29 04:29:57', NULL, NULL, '2026-06-29 04:28:34', '2026-06-29 04:29:57'),
(90, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #4 is now: Confirmed.', NULL, '{\"order_id\":\"4\",\"status\":\"confirmed\",\"deeplink\":\"shopq:\\/\\/order\\/4\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:30:07', '2026-06-29 04:34:56'),
(91, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #4 is now: Packed.', NULL, '{\"order_id\":\"4\",\"status\":\"packed\",\"deeplink\":\"shopq:\\/\\/order\\/4\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:30:11', '2026-06-29 04:34:56'),
(92, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #4 is now: Assigned.', NULL, '{\"order_id\":\"4\",\"status\":\"assigned\",\"deeplink\":\"shopq:\\/\\/order\\/4\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:30:16', '2026-06-29 04:34:56'),
(93, 'App\\Models\\DeliveryBoy', 1, NULL, 'new_assignment', 'New delivery assigned', 'Order #4 has been assigned to you.', NULL, '{\"order_id\":\"4\",\"deeplink\":\"shopq:\\/\\/order\"}', '2026-06-29 04:30:24', NULL, NULL, '2026-06-29 04:30:18', '2026-06-29 04:30:24'),
(94, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #4 is now: Picked Up.', NULL, '{\"order_id\":\"4\",\"status\":\"picked_up\",\"deeplink\":\"shopq:\\/\\/order\\/4\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:30:32', '2026-06-29 04:34:56'),
(95, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #4 is now: Out For Delivery.', NULL, '{\"order_id\":\"4\",\"status\":\"out_for_delivery\",\"deeplink\":\"shopq:\\/\\/order\\/4\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:31:01', '2026-06-29 04:34:56'),
(96, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #3 is now: Out For Delivery.', NULL, '{\"order_id\":\"3\",\"status\":\"out_for_delivery\",\"deeplink\":\"shopq:\\/\\/order\\/3\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:31:16', '2026-06-29 04:34:56'),
(97, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #3 is now: Delivered.', NULL, '{\"order_id\":\"3\",\"status\":\"delivered\",\"deeplink\":\"shopq:\\/\\/order\\/3\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:31:26', '2026-06-29 04:34:56'),
(98, 'App\\Models\\User', 1, NULL, 'order_update', 'Order Update', 'Your order #4 is now: Delivered.', NULL, '{\"order_id\":\"4\",\"status\":\"delivered\",\"deeplink\":\"shopq:\\/\\/order\\/4\"}', '2026-06-29 04:34:56', NULL, NULL, '2026-06-29 04:31:33', '2026-06-29 04:34:56');

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
(1, 'primary_color', '#F5BF14', '2026-06-18 05:16:50', '2026-06-18 05:16:50'),
(2, 'secondary_color', '#FFC63A', '2026-06-18 05:16:50', '2026-06-18 05:16:50'),
(3, 'app_name', 'DxMart', '2026-06-18 05:16:50', '2026-06-18 05:16:50'),
(4, 'delivery_time_text', '24 Min', '2026-06-18 05:16:50', '2026-06-18 05:16:50'),
(5, 'free_delivery_text', '₹0 delivery fee', '2026-06-18 05:16:50', '2026-06-18 05:16:50'),
(6, 'search_hint', 'Search for \"Milk\"', '2026-06-18 05:16:50', '2026-06-18 05:16:50'),
(7, 'assurance_1', 'Lowest Prices', '2026-06-18 05:16:50', '2026-06-18 05:16:50'),
(8, 'assurance_2', 'Quality Checked', '2026-06-18 05:16:50', '2026-06-18 05:16:50'),
(9, 'assurance_3', 'Easy Returns', '2026-06-18 05:16:50', '2026-06-18 05:16:50');

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
(1, 1, 'categories/cat_1781166858821.png', 1, '2026-06-18 05:17:18', '2026-06-23 06:41:23'),
(2, 3, 'banners/banner_image_1781941437355.png', 1, '2026-06-20 02:28:04', '2026-06-20 02:28:04');

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `position` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `brands`
--

INSERT INTO `brands` (`id`, `name`, `image`, `is_active`, `position`, `created_at`, `updated_at`) VALUES
(1, 'Lux', 'brands/brand_1782728384494_ChatGPT Image Jun 23, 2026, 04_47_57 PM.png', 1, 4, '2026-06-29 04:38:43', '2026-06-29 04:52:46'),
(2, 'Parle', 'brands/brand_1782728399529_ChatGPT Image Jun 23, 2026, 04_43_24 PM.png', 1, 2, '2026-06-29 04:38:43', '2026-06-29 04:52:46'),
(3, 'Amul', 'brands/brand_1782728440613_asset 19.webp', 1, 3, '2026-06-29 04:38:43', '2026-06-29 04:52:46'),
(4, 'Tata', 'brands/brand_1782728454408_asset 3.webp', 1, 1, '2026-06-29 04:38:43', '2026-06-29 04:52:46');

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
(1, 1, 'Connaught Place', '2026-06-18 05:17:18', '2026-06-18 05:17:18');

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
(1, 'Welcome Offer', 'Flat 10% off on your first order', 'WELCOME10', 10.00, '31-12-2026', 'Public', 199.00, '2026-06-18 05:17:18', '2026-06-18 05:17:18'),
(2, 'DIWALI OFFER', 'Integrating Firebase Cloud', 'DIWALI20', 20.00, '31-07-2026', 'Public', 499.00, '2026-06-20 02:28:04', '2026-06-20 02:28:04');

-- --------------------------------------------------------

--
-- Table structure for table `delivery_address`
--

CREATE TABLE `delivery_address` (
  `id` bigint(20) UNSIGNED NOT NULL,
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

INSERT INTO `delivery_address` (`id`, `user_id`, `name`, `phone`, `full_address`, `pin_code`, `landmark`, `created_at`, `updated_at`) VALUES
(1, 1, 'rhtth', '6565599322', 'hrthhtbtbtr tvt tb', '110001', 'rhrrhr', '2026-06-20 02:28:04', '2026-06-20 02:28:04');

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
  `status` varchar(30) NOT NULL,
  `fcm_token` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `delivery_boy`
--

INSERT INTO `delivery_boy` (`id`, `vendor_id`, `name`, `email`, `mobile`, `pin_code`, `address`, `password`, `date_time`, `status`, `fcm_token`) VALUES
(1, NULL, 'Rajesh Kumar', 'rajesh49011@gmail.com', '8102337432', '825408', 'Vill - Paroriya, Post - Badgwan, Chatra Jharkhand ', '$2y$12$v7jVf81pxf96wfAt65lNBuk7co2xbEa/lJasIHLr3.Ndi.6vMtsdC', '14-10-2025 08:24 AM', 'active', 'fghFlbb1RPiHgFaknVrsAl:APA91bESkvR_jMerQI3W9D2lPCxcWgP0rOnDXYNm7AU42MyS1NjAFrW5zBxyUGSO8la7cJCt4VkIHyqSlyPIejItfdqdJrmBbFidwBAgV9KpyCNZwzuPcDI'),
(2, NULL, 'Pankaj Kumar', 'pankajkumar.hzb143@gmail.com', '6205511717', '834002', 'Ranchi', '$2y$12$pt5swy9WeKJT.LA8j9/FMO4Y5P9arV0oaao5UiLWRGpa5se9jY9gm', '29-10-2025 06:54 PM', 'inactive', NULL);

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
(1, 10.00, '2026-06-20 02:28:04', '2026-06-20 02:28:04');

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
(1, '24 Min', '2026-06-18 05:17:18', '2026-06-18 05:17:18');

-- --------------------------------------------------------

--
-- Table structure for table `device_tokens`
--

CREATE TABLE `device_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `token` varchar(512) NOT NULL,
  `platform` varchar(20) DEFAULT NULL,
  `app_version` varchar(20) DEFAULT NULL,
  `language` varchar(10) DEFAULT NULL,
  `is_valid` tinyint(1) NOT NULL DEFAULT 1,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `device_tokens`
--

INSERT INTO `device_tokens` (`id`, `tokenable_type`, `tokenable_id`, `token`, `platform`, `app_version`, `language`, `is_valid`, `last_seen_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'fxNNPpsDSzi4zShE4g9U-4:APA91bETYYOeOOL9xcKDihcNM-weNxmrMn7vv--ZrhGyzyE844IwQTSZMVzLcDnecdm7wDWWi38YZkzq--jiWWl6MKDUIhujMapSlk3CrYlSm0QIr-TBxmY', NULL, NULL, NULL, 0, '2026-06-27 05:08:40', '2026-06-27 05:08:40', '2026-06-27 05:08:43'),
(2, 'App\\Models\\Vendor', 1, 'ecqo3jutTpC6z7geUbLcRn:APA91bGJCa0GmpJrRM-CXwCFT4MALlaCHzjO5-HOw0oZInZHPXw6a-c3sYKJ2HQQf5rbV3BuC1LBYSPSVgDcWh8fODKZtlqBRKqEl-PPDBoPbWDe-zXFyME', NULL, NULL, NULL, 0, '2026-06-27 05:08:40', '2026-06-27 05:08:40', '2026-06-29 03:19:25'),
(3, 'App\\Models\\Vendor', 2, 'eiROahAZq6aXK0XLGGGemT:APA91bFfLstioudhPCHSE5V-7vY7i9JhCBxjDk2VechiUCvzWTSRMtslR5q-xOnEmkd1QM0VYOd6Tm6apIyDQkjR5Os-aMypV2vWUXO_WwznhqgP5CgmAoY', NULL, NULL, NULL, 1, '2026-06-27 05:08:40', '2026-06-27 05:08:40', '2026-06-27 05:08:40'),
(4, 'App\\Models\\DeliveryBoy', 1, 'dzhumtU8S9ikNHCbP6iI5p:APA91bECPLjJKATwjaQLvne996DwJDQh88HKWdIRrnf0EwTFuKFaX8dSvNB_gGBsezLJRnUubjO9kf8c3WnyO4knOedqr9JaMK1_yloE6KinzSuuAVzjH3A', NULL, NULL, NULL, 0, '2026-06-27 05:08:40', '2026-06-27 05:08:40', '2026-06-29 03:19:26'),
(5, 'App\\Models\\User', 1, 'cgOUXKYiREqbz_f64QZ4_u:APA91bGaYSXbLeZMbQ4sCswsrVw-sKPO4Dm9rX_PrV3Du72Aa3_JBRhmP-ShzLQZUq5Suo7ewndjnFLXDA9EsiIdX7WwtFUm7By5H3A3jImusxkc2jMm43M', 'android', NULL, 'en', 1, '2026-06-29 05:08:30', '2026-06-27 05:31:35', '2026-06-29 05:08:30'),
(6, 'App\\Models\\Vendor', 2, 'ftASG_ocCvom54aUP6c7HM:APA91bF_PZfqAXHSw9v5FIlP-TmtBS7uwnwrCKV11bOsW8wMVUEFZE_EFKsUn_NweN9lFxUgQB2baBlmKLQeL39BeV1pwiqZoMeW5xzSo6qZkStNs_DoOi4', 'web', NULL, 'en', 1, '2026-06-29 03:59:23', '2026-06-29 03:27:15', '2026-06-29 03:59:23'),
(7, 'App\\Models\\Vendor', 2, 'frvQgAALT0SDWUpANcTrxF:APA91bEQIHDYR5fn_6E9t1p6pMWIb023Z-mHJabeEaTFc9S0bXh-yfyVR-wAsv0fkKmGQtjzv0wBpzBGucM-87kZs-iBgwdYdppTVLyPfuVeb8jsSlRbiVI', 'android', NULL, 'en', 1, '2026-06-29 05:12:48', '2026-06-29 04:05:01', '2026-06-29 05:12:48'),
(8, 'App\\Models\\DeliveryBoy', 1, 'fghFlbb1RPiHgFaknVrsAl:APA91bESkvR_jMerQI3W9D2lPCxcWgP0rOnDXYNm7AU42MyS1NjAFrW5zBxyUGSO8la7cJCt4VkIHyqSlyPIejItfdqdJrmBbFidwBAgV9KpyCNZwzuPcDI', 'android', NULL, 'en', 1, '2026-06-29 04:30:51', '2026-06-29 04:29:53', '2026-06-29 04:30:51');

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
(1, 'New Delhi', '2026-06-18 05:17:18', '2026-06-18 05:17:18');

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
(1, 1, 1, 'Flash Sale', 399.00, '2026-06-18 10:47:18', '2026-06-25 10:47:18', 1, '2026-06-18 05:17:18');

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
(1, 499.00, '2026-06-18 05:17:18', '2026-06-18 05:17:18');

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
(1, 9.00, '2026-06-18 05:17:18', '2026-06-18 05:17:18');

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
(1, '+91 90000 00000', '2026-06-18 05:17:18', '2026-06-18 05:17:18');

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
(1, 'support@shopq.com', '2026-06-18 05:17:18', '2026-06-18 05:17:18');

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
(1, '+91 90000 00000', '2026-06-18 05:17:18', '2026-06-18 05:17:18');

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
(1, 1, 'Shop by Category', NULL, NULL, NULL, 'category_grid', NULL, NULL, NULL, NULL, NULL, 12, 2, 1, '2026-06-18 05:17:05', '2026-06-20 02:18:15'),
(2, 1, 'Best Selling', NULL, NULL, NULL, 'product_type', 'Best Selling', NULL, NULL, NULL, NULL, 2, 3, 1, '2026-06-18 05:17:05', '2026-06-29 03:50:03'),
(3, 1, 'Daily Deals', NULL, NULL, NULL, 'product_type', 'Daily Deals', NULL, NULL, NULL, NULL, 10, 5, 1, '2026-06-18 05:17:05', '2026-06-20 02:18:15'),
(4, 1, 'Brands You Love', NULL, NULL, NULL, 'brand_grid', NULL, NULL, NULL, NULL, NULL, 12, 6, 1, '2026-06-18 05:17:05', '2026-06-20 02:18:15'),
(5, 1, 'Hot Deals', NULL, NULL, NULL, 'product_type', 'Hot Deals', NULL, NULL, NULL, NULL, 10, 7, 1, '2026-06-18 05:17:05', '2026-06-20 02:18:15'),
(6, 1, 'Shops Near You', NULL, NULL, NULL, 'shop_grid', NULL, NULL, NULL, NULL, NULL, 10, 9, 1, '2026-06-18 05:17:05', '2026-06-20 02:18:15'),
(7, 3, 'Fresh Categories', NULL, NULL, NULL, 'category_grid', NULL, NULL, NULL, NULL, NULL, 8, 1, 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(9, 1, '', NULL, NULL, '[2,1]', 'banner', NULL, NULL, NULL, NULL, NULL, 10, 1, 1, '2026-06-20 02:17:17', '2026-06-20 02:18:15'),
(10, 1, '', NULL, NULL, '[2]', 'banner', NULL, NULL, NULL, NULL, NULL, 10, 4, 1, '2026-06-20 02:17:30', '2026-06-20 02:18:15'),
(11, 1, '', NULL, NULL, '[2]', 'banner', NULL, NULL, NULL, NULL, NULL, 10, 8, 1, '2026-06-20 02:17:39', '2026-06-20 02:18:15'),
(13, 3, 'Fresh Fruit', NULL, NULL, NULL, 'products', NULL, 5, 27, NULL, NULL, 10, 2, 1, '2026-06-29 04:07:48', '2026-06-29 04:07:48');

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
(1, 'All', 'all', NULL, 'all', NULL, '#6C63FF', NULL, 0, 1, '2026-06-18 05:16:32', '2026-06-23 06:41:22'),
(2, 'Categories', 'grid', NULL, 'categories', NULL, '#FF6584', NULL, 1, 1, '2026-06-18 05:16:32', '2026-06-18 05:16:32'),
(3, 'Fresh', 'apple', NULL, 'category', 5, '#2DB87B', NULL, 1, 1, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(4, 'Deals', 'deals', NULL, 'none', NULL, '#FF8C42', NULL, 2, 1, '2026-06-20 02:28:04', '2026-06-20 02:28:04');

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

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at`) VALUES
(48, 'default', '{\"uuid\":\"00d7f398-a0f0-40f3-b820-36c137a157b2\",\"displayName\":\"App\\\\Jobs\\\\SendOrderConfirmationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":30,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendOrderConfirmationEmail\",\"command\":\"O:35:\\\"App\\\\Jobs\\\\SendOrderConfirmationEmail\\\":9:{s:44:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000orderId\\\";i:3;s:42:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000items\\\";a:4:{i:0;a:8:{s:10:\\\"product_id\\\";i:19;s:10:\\\"variant_id\\\";i:40;s:8:\\\"quantity\\\";i:1;s:9:\\\"image_url\\\";s:32:\\\"products\\/6874fa3e9f2ab_image.png\\\";s:5:\\\"price\\\";s:5:\\\"68.00\\\";s:3:\\\"mrp\\\";s:5:\\\"75.00\\\";s:12:\\\"product_name\\\";s:33:\\\"Britannia Good Day Cashew Cookies\\\";s:9:\\\"vendor_id\\\";i:2;}i:1;a:8:{s:10:\\\"product_id\\\";i:19;s:10:\\\"variant_id\\\";i:39;s:8:\\\"quantity\\\";i:1;s:9:\\\"image_url\\\";s:32:\\\"products\\/6874fa3e9f2ab_image.png\\\";s:5:\\\"price\\\";s:5:\\\"22.00\\\";s:3:\\\"mrp\\\";s:5:\\\"25.00\\\";s:12:\\\"product_name\\\";s:33:\\\"Britannia Good Day Cashew Cookies\\\";s:9:\\\"vendor_id\\\";i:2;}i:2;a:8:{s:10:\\\"product_id\\\";i:18;s:10:\\\"variant_id\\\";i:38;s:8:\\\"quantity\\\";i:1;s:9:\\\"image_url\\\";s:30:\\\"products\\/6a33d756bb1cd_img.png\\\";s:5:\\\"price\\\";s:6:\\\"175.00\\\";s:3:\\\"mrp\\\";s:6:\\\"190.00\\\";s:12:\\\"product_name\\\";s:25:\\\"Dairy Milk Silk Chocolate\\\";s:9:\\\"vendor_id\\\";i:2;}i:3;a:8:{s:10:\\\"product_id\\\";i:18;s:10:\\\"variant_id\\\";i:37;s:8:\\\"quantity\\\";i:1;s:9:\\\"image_url\\\";s:30:\\\"products\\/6a33d756bb1cd_img.png\\\";s:5:\\\"price\\\";s:5:\\\"75.00\\\";s:3:\\\"mrp\\\";s:5:\\\"80.00\\\";s:12:\\\"product_name\\\";s:25:\\\"Dairy Milk Silk Chocolate\\\";s:9:\\\"vendor_id\\\";i:2;}}s:45:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000userName\\\";s:12:\\\"Rahul Sharma\\\";s:46:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000userEmail\\\";s:17:\\\"rahul@example.com\\\";s:45:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000discount\\\";d:30;s:51:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000deliveryCharge\\\";d:10;s:51:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000handlingCharge\\\";d:9;s:48:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000finalAmount\\\";d:359;s:46:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000cartTotal\\\";d:370;}\",\"batchId\":null},\"createdAt\":1782726828,\"delay\":null}', 0, NULL, 1782726828, 1782726828),
(49, 'default', '{\"uuid\":\"d881e6a0-c2c3-4b04-bf0d-2ca127565451\",\"displayName\":\"App\\\\Jobs\\\\SendOrderConfirmationEmail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":30,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\SendOrderConfirmationEmail\",\"command\":\"O:35:\\\"App\\\\Jobs\\\\SendOrderConfirmationEmail\\\":9:{s:44:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000orderId\\\";i:4;s:42:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000items\\\";a:1:{i:0;a:8:{s:10:\\\"product_id\\\";i:18;s:10:\\\"variant_id\\\";i:38;s:8:\\\"quantity\\\";i:1;s:9:\\\"image_url\\\";s:30:\\\"products\\/6a33d756bb1cd_img.png\\\";s:5:\\\"price\\\";s:6:\\\"175.00\\\";s:3:\\\"mrp\\\";s:6:\\\"190.00\\\";s:12:\\\"product_name\\\";s:25:\\\"Dairy Milk Silk Chocolate\\\";s:9:\\\"vendor_id\\\";i:2;}}s:45:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000userName\\\";s:12:\\\"Rahul Sharma\\\";s:46:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000userEmail\\\";s:17:\\\"rahul@example.com\\\";s:45:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000discount\\\";d:15;s:51:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000deliveryCharge\\\";d:10;s:51:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000handlingCharge\\\";d:9;s:48:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000finalAmount\\\";d:194;s:46:\\\"\\u0000App\\\\Jobs\\\\SendOrderConfirmationEmail\\u0000cartTotal\\\";d:190;}\",\"batchId\":null},\"createdAt\":1782727015,\"delay\":null}', 0, NULL, 1782727015, 1782727015);

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
-- Table structure for table `ledger_accounts`
--

CREATE TABLE `ledger_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(64) NOT NULL,
  `owner_type` varchar(64) NOT NULL DEFAULT '',
  `owner_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `type` varchar(16) NOT NULL,
  `normal_balance` varchar(8) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'INR',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ledger_entries`
--

CREATE TABLE `ledger_entries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `reference` varchar(255) NOT NULL DEFAULT '',
  `entry_type` varchar(48) NOT NULL,
  `idempotency_key` varchar(255) DEFAULT NULL,
  `source_type` varchar(64) DEFAULT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reversed_entry_id` bigint(20) UNSIGNED DEFAULT NULL,
  `memo` text DEFAULT NULL,
  `actor_type` varchar(32) DEFAULT NULL,
  `actor_id` bigint(20) UNSIGNED DEFAULT NULL,
  `posted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ledger_lines`
--

CREATE TABLE `ledger_lines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `entry_id` bigint(20) UNSIGNED NOT NULL,
  `account_id` bigint(20) UNSIGNED NOT NULL,
  `debit` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `credit` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
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
(1, 'Atta, Rice, Oil & Dals', 'categories/cat_1781166858821.png', 'categories/cat_1781166858821.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 1, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(2, 'Breakfast & Sauces', 'categories/cat_1781167059680.png', 'categories/cat_1781167059680.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 2, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(3, 'Dairy, Bread & Eggs', 'categories/cat_1781167075020.png', 'categories/cat_1781167075020.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 3, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(4, 'Electronics & Appliances', 'categories/cat_1781167096944.png', 'categories/cat_1781167096944.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 4, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(5, 'Fruits & Vegetables', 'categories/cat_1781167109376.png', 'categories/cat_1781167109376.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 5, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(6, 'Ice Creams & More', 'categories/cat_1781167130681.png', 'categories/cat_1781167130681.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 6, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(7, 'Kitchen & Dining', 'categories/cat_1781167152666.png', 'categories/cat_1781167152666.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 7, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(8, 'Masala & Dry Fruits', 'categories/cat_1781167163939.png', 'categories/cat_1781167163939.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 8, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(9, 'Frozen Food', 'categories/cat_1781167176047.png', 'categories/cat_1781167176047.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 9, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(10, 'Sweet Cravings', 'categories/cat_1781167186281.png', 'categories/cat_1781167186281.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 10, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(11, 'Tea, Coffee & More', 'categories/cat_1781167196982.png', 'categories/cat_1781167196982.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 11, '2026-06-20 02:28:04', '2026-06-20 02:28:04'),
(12, 'Packaged Food', 'categories/cat_1781167207109.png', 'categories/cat_1781167207109.png', '#FFFFFF', NULL, '#F5F5F5', 1, 0, NULL, 1, 12, '2026-06-20 02:28:04', '2026-06-20 02:28:04');

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
(41, '2026_06_16_000001_add_banner_ids_to_home_sections', 1),
(42, '2026_06_16_000002_multi_vendor_orders', 1),
(43, '2026_06_16_000003_add_vendor_to_delivery_boy', 1),
(44, '2026_06_17_000001_freeze_settlement_values', 1),
(45, '2026_06_17_000002_backfill_settlement_values', 1),
(46, '2026_06_18_000001_add_reset_token_to_otp_table', 1),
(47, '2026_06_18_000002_add_performance_indexes', 1),
(48, '2026_06_18_000003_add_ordered_at_to_orders', 1),
(49, '2026_06_20_000001_add_fcm_token_to_user_tables', 2),
(50, '2026_06_20_000002_fix_timestamps_and_unused_columns', 3),
(51, '2026_06_24_000001_create_ledger_tables', 4),
(52, '2026_06_27_000001_create_device_tokens_table', 5),
(53, '2026_06_27_000002_backfill_device_tokens', 6),
(54, '2026_06_27_000003_create_app_notifications_table', 7),
(55, '2026_06_27_000004_create_user_stats_table', 7),
(56, '2026_06_27_000005_create_notification_campaigns_table', 7),
(57, '2026_06_27_000006_add_clicked_at_to_app_notifications', 8),
(58, '2026_06_27_000007_add_delivery_mode_to_campaigns', 9),
(59, '2026_06_27_000008_create_brands_table', 10);

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
(1, 99.00, '2026-06-18 05:17:18', '2026-06-18 05:17:18');

-- --------------------------------------------------------

--
-- Table structure for table `notification_campaigns`
--

CREATE TABLE `notification_campaigns` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'custom',
  `audience` varchar(20) NOT NULL DEFAULT 'customers',
  `delivery_mode` varchar(10) NOT NULL DEFAULT 'token',
  `title` varchar(255) NOT NULL,
  `body` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`criteria`)),
  `status` varchar(20) NOT NULL DEFAULT 'draft',
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `recurrence` varchar(50) DEFAULT NULL,
  `next_run_at` timestamp NULL DEFAULT NULL,
  `expiry_at` timestamp NULL DEFAULT NULL,
  `audience_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `sent_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `failed_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `read_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `click_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notification_campaigns`
--

INSERT INTO `notification_campaigns` (`id`, `type`, `audience`, `delivery_mode`, `title`, `body`, `image`, `data`, `criteria`, `status`, `scheduled_at`, `recurrence`, `next_run_at`, `expiry_at`, `audience_count`, `sent_count`, `failed_count`, `read_count`, `click_count`, `created_by`, `created_at`, `updated_at`) VALUES
(21, 'promotional_offer', 'customers', 'token', 'Special offer just for you! 🎉', 'Exclusive deals are live — grab them before they\'re gone.', NULL, '{\"deeplink\":\"shopq:\\/\\/offers\"}', NULL, 'sent', NULL, NULL, NULL, NULL, 5, 5, 0, 0, 0, 1, '2026-06-29 03:21:19', '2026-06-29 03:34:58'),
(22, 'promotional_offer', 'customers', 'topic', 'Special offer just for you! 🎉', 'Exclusive deals are live — grab them before they\'re gone.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Everyday%20Essentials\"}', NULL, 'sent', NULL, NULL, NULL, NULL, 1, 1, 0, 0, 0, 1, '2026-06-29 03:22:09', '2026-06-29 03:34:33'),
(23, 'promo', 'customers', 'token', 'Sync Send Test', 'works without worker', NULL, NULL, '[]', 'sent', NULL, NULL, NULL, NULL, 5, 5, 0, 1, 1, NULL, '2026-06-29 03:33:21', '2026-06-29 03:33:33'),
(24, 'general_announcement', 'customers', 'token', 'New arrivals are here! 🆕', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', NULL, 'sent', NULL, NULL, NULL, NULL, 5, 5, 0, 0, 0, 1, '2026-06-29 03:35:39', '2026-06-29 03:35:40'),
(25, 'general_announcement', 'customers', 'token', 'New arrivals are here! 🆕 (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', '{\"geo\":{\"pincode\":[\"110001\"]}}', 'sent', NULL, NULL, NULL, NULL, 1, 1, 0, 1, 1, 1, '2026-06-29 03:37:59', '2026-06-29 03:42:14'),
(28, 'general_announcement', 'vendors', 'token', 'New arrivals are here! 🆕 (copy) (copy)', 'Fresh products just added. Be the first to check them out.', NULL, '{\"deeplink\":\"shopq:\\/\\/product_type\\/Best%20Selling\"}', '{\"geo\":{\"pincode\":[\"110001\"]}}', 'sent', NULL, NULL, NULL, NULL, 5, 5, 0, 1, 0, 1, '2026-06-29 03:48:32', '2026-06-29 03:49:03'),
(29, 'vendor_update', 'vendors', 'token', 'Payout ready', 'Your settlement is ready.', NULL, '{\"deeplink\":\"shopq:\\/\\/payouts\"}', '[]', 'sent', NULL, NULL, NULL, NULL, 5, 5, 0, 1, 0, NULL, '2026-06-29 03:58:35', '2026-06-29 03:58:53'),
(30, 'general_announcement', 'vendors', 'token', 'test', 'test fdgdfg', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', NULL, 'sent', NULL, NULL, NULL, NULL, 5, 5, 0, 1, 0, 1, '2026-06-29 04:00:44', '2026-06-29 04:00:54'),
(31, 'stock_warning', 'vendors', 'token', 'hgfhfg', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/orders\"}', NULL, 'sent', NULL, NULL, NULL, NULL, 5, 5, 0, 1, 0, 1, '2026-06-29 04:18:43', '2026-06-29 04:18:52'),
(32, 'stock_warning', 'vendors', 'token', 'hgfhfg (copy)', 'hf gfhgfhfgh hg fg gf', NULL, '{\"deeplink\":\"shopq:\\/\\/products\"}', '[]', 'sent', NULL, NULL, NULL, NULL, 5, 5, 0, 1, 0, 1, '2026-06-29 04:19:00', '2026-06-29 04:19:23');

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
  `coupon_title` varchar(150) DEFAULT NULL,
  `coupon_type` varchar(20) DEFAULT NULL,
  `coupon_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `coupon_discount` int(11) NOT NULL DEFAULT 0,
  `settlement_frozen` tinyint(1) NOT NULL DEFAULT 0,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `delivery_charge` decimal(10,2) NOT NULL DEFAULT 0.00,
  `handling_charge` decimal(10,2) NOT NULL DEFAULT 0.00,
  `final_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `derived_status` varchar(30) NOT NULL DEFAULT 'pending',
  `payment_method` varchar(255) NOT NULL DEFAULT 'COD',
  `payment_status` varchar(20) NOT NULL DEFAULT 'pending',
  `order_datetime` varchar(255) DEFAULT NULL,
  `ordered_at` datetime DEFAULT NULL,
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

INSERT INTO `orders` (`id`, `user_id`, `vendor_id`, `total_amount`, `coupon_code`, `coupon_title`, `coupon_type`, `coupon_value`, `coupon_discount`, `settlement_frozen`, `discount_amount`, `delivery_charge`, `handling_charge`, `final_amount`, `status`, `derived_status`, `payment_method`, `payment_status`, `order_datetime`, `ordered_at`, `delivery_date`, `delivery_time`, `location_id`, `gift`, `created_at`, `updated_at`) VALUES
(1, 1, NULL, 190.00, NULL, NULL, NULL, 0.00, 0, 1, 15.00, 10.00, 9.00, 194.00, 'processing', 'processing', 'COD', 'pending', '29-06-2026 01:53 PM', '2026-06-29 08:23:02', '2026-06-29', '9 AM - 2 PM', 1, 'noGift', NULL, NULL),
(2, 1, NULL, 330.00, 'WELCOME10', 'Welcome Offer', 'percent', 10.00, 30, 1, 63.60, 10.00, 9.00, 285.00, 'delivered', 'delivered', 'COD', 'pending', '29-06-2026 02:01 PM', '2026-06-29 08:31:59', '2026-06-29', '9 AM - 2 PM', 1, 'noGift', NULL, NULL),
(3, 1, NULL, 370.00, NULL, NULL, NULL, 0.00, 0, 1, 30.00, 10.00, 9.00, 359.00, 'delivered', 'delivered', 'COD', 'pending', '29-06-2026 03:23 PM', '2026-06-29 09:53:48', '2026-06-29', '9 AM - 2 PM', 1, 'noGift', NULL, NULL),
(4, 1, NULL, 190.00, NULL, NULL, NULL, 0.00, 0, 1, 15.00, 10.00, 9.00, 194.00, 'delivered', 'delivered', 'COD', 'pending', '29-06-2026 03:26 PM', '2026-06-29 09:56:55', '2026-06-29', '9 AM - 2 PM', 1, 'noGift', NULL, NULL);

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
(1, 1, 1, 18, 2, 38, 1, 175.00, 'products/6a33d756bb1cd_img.png', NULL, NULL),
(2, 2, 2, 14, 2, 31, 2, 148.00, 'products/6874f7554f275_image.png', NULL, NULL),
(3, 3, 3, 19, 2, 40, 1, 68.00, 'products/6874fa3e9f2ab_image.png', NULL, NULL),
(4, 3, 3, 19, 2, 39, 1, 22.00, 'products/6874fa3e9f2ab_image.png', NULL, NULL),
(5, 3, 3, 18, 2, 38, 1, 175.00, 'products/6a33d756bb1cd_img.png', NULL, NULL),
(6, 3, 3, 18, 2, 37, 1, 75.00, 'products/6a33d756bb1cd_img.png', NULL, NULL),
(7, 4, 4, 18, 2, 38, 1, 175.00, 'products/6a33d756bb1cd_img.png', NULL, NULL);

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
(1, 1, NULL, 'customer', 1, NULL, 'pending', 'Order placed', '2026-06-29 02:53:02'),
(2, 2, NULL, 'customer', 1, NULL, 'pending', 'Order placed', '2026-06-29 03:01:59'),
(3, 2, 2, 'vendor', 2, 'pending', 'confirmed', NULL, '2026-06-29 03:28:13'),
(4, 2, 2, 'vendor', 2, 'confirmed', 'packed', NULL, '2026-06-29 03:28:26'),
(5, 2, 2, 'vendor', 2, 'packed', 'assigned', 'Assigned delivery boy #1', '2026-06-29 03:28:49'),
(6, 2, 2, 'vendor', 2, 'assigned', 'out_for_delivery', NULL, '2026-06-29 03:29:06'),
(7, 2, 2, 'vendor', 2, 'out_for_delivery', 'delivered', NULL, '2026-06-29 03:29:13'),
(8, 1, 1, 'vendor', 2, 'pending', 'confirmed', NULL, '2026-06-29 04:22:25'),
(9, 1, 1, 'vendor', 2, 'confirmed', 'confirmed', NULL, '2026-06-29 04:22:27'),
(10, 3, NULL, 'customer', 1, NULL, 'pending', 'Order placed', '2026-06-29 04:23:48'),
(11, 4, NULL, 'customer', 1, NULL, 'pending', 'Order placed', '2026-06-29 04:26:55'),
(12, 3, 3, 'vendor', 2, 'pending', 'confirmed', NULL, '2026-06-29 04:28:20'),
(13, 3, 3, 'vendor', 2, 'confirmed', 'packed', NULL, '2026-06-29 04:28:27'),
(14, 3, 3, 'vendor', 2, 'packed', 'assigned', 'Assigned delivery boy #1', '2026-06-29 04:28:33'),
(15, 4, 4, 'vendor', 2, 'pending', 'confirmed', NULL, '2026-06-29 04:30:07'),
(16, 4, 4, 'vendor', 2, 'confirmed', 'packed', NULL, '2026-06-29 04:30:11'),
(17, 4, 4, 'vendor', 2, 'packed', 'assigned', 'Assigned delivery boy #1', '2026-06-29 04:30:16'),
(18, 4, 4, 'delivery', 1, 'assigned', 'picked_up', NULL, '2026-06-29 04:30:32'),
(19, 4, 4, 'delivery', 1, 'picked_up', 'out_for_delivery', NULL, '2026-06-29 04:31:01'),
(20, 3, 3, 'vendor', 2, 'assigned', 'out_for_delivery', NULL, '2026-06-29 04:31:16'),
(21, 3, 3, 'delivery', 1, 'out_for_delivery', 'delivered', NULL, '2026-06-29 04:31:26'),
(22, 4, 4, 'delivery', 1, 'out_for_delivery', 'delivered', NULL, '2026-06-29 04:31:33');

-- --------------------------------------------------------

--
-- Table structure for table `otp_table`
--

CREATE TABLE `otp_table` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `otp` varchar(255) NOT NULL,
  `expiry` bigint(20) NOT NULL,
  `reset_token` varchar(128) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otp_table`
--

INSERT INTO `otp_table` (`id`, `email`, `otp`, `expiry`, `reset_token`, `created_at`, `updated_at`) VALUES
(1, 'demo@shopq.com', '123456', 1781780238, NULL, '2026-06-18 05:17:18', '2026-06-18 05:17:18');

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
(4, 'App\\Models\\User', 1, 'auth_token', '670974558bdd3de58190781b522a2e799ca93f9f3a81d18e3461056fad90bd86', '[\"*\"]', '2026-06-18 06:07:04', NULL, '2026-06-18 05:57:46', '2026-06-18 06:07:04'),
(6, 'App\\Models\\User', 1, 'auth_token', '982344d5a1d257053741f20cc26ef21270c896e60a84d29586e205ff00ad7ca2', '[\"*\"]', '2026-06-20 03:02:45', NULL, '2026-06-20 01:53:28', '2026-06-20 03:02:45'),
(7, 'App\\Models\\User', 1, 'auth_token', '715e5eea57efc3fa6b722c6ec0377ca0c3c6fd3d3ad6f074f1e713b90f87a666', '[\"*\"]', NULL, NULL, '2026-06-20 01:53:31', '2026-06-20 01:53:31'),
(9, 'App\\Models\\User', 1, 'auth_token', '7054fb330568c9eca6ad02dcc0498db6f2e4eaf168218e87785314e691615001', '[\"*\"]', NULL, NULL, '2026-06-20 04:32:03', '2026-06-20 04:32:03'),
(10, 'App\\Models\\User', 1, 'auth_token', '4fd3809482a90c3e00dc22c39f9e6e3d719379f014dc1e84d8221a866fe31abc', '[\"*\"]', NULL, NULL, '2026-06-20 04:32:08', '2026-06-20 04:32:08'),
(14, 'App\\Models\\User', 1, 'auth_token', '068c04891bf17eba664dc253507f08c8787c9384f4e67227c01287a11018b9f5', '[\"*\"]', '2026-06-20 04:44:29', NULL, '2026-06-20 04:42:41', '2026-06-20 04:44:29'),
(26, 'App\\Models\\User', 1, 'auth_token', '22389f4f6999e170fa4d1307acb80357d2f0dfbb4fe2b2b34a26f6c4e17d82c8', '[\"*\"]', NULL, NULL, '2026-06-22 06:52:54', '2026-06-22 06:52:54'),
(27, 'App\\Models\\User', 1, 'auth_token', '569d8498739a32d42a043235df47853fdc87c2696fdc43641677893649568cdf', '[\"*\"]', NULL, NULL, '2026-06-22 06:52:58', '2026-06-22 06:52:58'),
(28, 'App\\Models\\User', 1, 'auth_token', '6db2aa2d9cf7622b09107c68ed36860713b243f449394dc7a323a50877499fb1', '[\"*\"]', NULL, NULL, '2026-06-22 06:53:02', '2026-06-22 06:53:02'),
(29, 'App\\Models\\User', 1, 'auth_token', '53cb56f353864aae739d14c336da266275a8dbfce3c99d327477a0218f7c6974', '[\"*\"]', NULL, NULL, '2026-06-22 06:53:05', '2026-06-22 06:53:05'),
(30, 'App\\Models\\User', 1, 'auth_token', '96581321d8e2523ade6c7af4287c57d7cff32573b3b97f501c15213467be4c6e', '[\"*\"]', '2026-06-23 00:12:49', NULL, '2026-06-23 00:12:33', '2026-06-23 00:12:49'),
(61, 'App\\Models\\User', 1, 'test', '7a64cb979ef33a48c80c8577c935e759abd372bed263ee9fa5f5bff23df1245e', '[\"*\"]', NULL, NULL, '2026-06-27 05:15:33', '2026-06-27 05:15:33'),
(62, 'App\\Models\\User', 1, 'test2', '0c9a441c526e07051cbdf66fd55df4005f09b3c0562662da96ef673028e1a1b0', '[\"*\"]', NULL, NULL, '2026-06-27 05:16:06', '2026-06-27 05:16:06'),
(63, 'App\\Models\\User', 1, 't3', 'b2a917e29817d21609a556d6a32b69a5b02d4e1f3d945a50c74ceee85cc78e28', '[\"*\"]', '2026-06-27 05:18:01', NULL, '2026-06-27 05:17:54', '2026-06-27 05:18:01'),
(64, 'App\\Models\\User', 1, 't4', '7f24601e71eb4e1dfeb534060a4bef30b835f0f07c2e6a7e982e659e8d62116d', '[\"*\"]', '2026-06-27 05:18:20', NULL, '2026-06-27 05:18:19', '2026-06-27 05:18:20'),
(70, 'App\\Models\\User', 2, 't', '11aa6c52c99c8f420af05355bd42161de620bd68ce22ea1f2cb3f6a265a293ed', '[\"*\"]', '2026-06-27 06:09:58', NULL, '2026-06-27 06:09:55', '2026-06-27 06:09:58'),
(73, 'App\\Models\\User', 1, 't', '917852cadb15642f465042ceb5c6f4c723556e2edf2f13596df27314eb9ebcbd', '[\"*\"]', '2026-06-27 06:36:01', NULL, '2026-06-27 06:36:00', '2026-06-27 06:36:01'),
(74, 'App\\Models\\User', 1, 'auth_token', '70bf342bf4fbad5af1f88816b36eef1a1d6c2b8bc014961bd60cef1acfbf41b6', '[\"*\"]', '2026-06-29 05:13:46', NULL, '2026-06-27 06:40:58', '2026-06-29 05:13:46'),
(75, 'App\\Models\\User', 1, 'auth_token', '21c90644ef93c3aaac7889fc546ef6fe3f943d70ec973902c37fac4d6f22e7ef', '[\"*\"]', NULL, NULL, '2026-06-27 06:41:01', '2026-06-27 06:41:01'),
(83, 'App\\Models\\Vendor', 2, 'vendor-token', '70220aeda5ff259a42144077ea319d29717956e556567e3b82ad225031789bbf', '[\"*\"]', '2026-06-29 05:13:31', NULL, '2026-06-29 04:26:24', '2026-06-29 05:13:31'),
(84, 'App\\Models\\DeliveryBoy', 1, 'delivery-token', 'f5eaf05289daabfa528dbae6db0ca7f5ebebe08fdade2dd1f9c0d29ca99384d4', '[\"*\"]', '2026-06-29 04:31:38', NULL, '2026-06-29 04:29:52', '2026-06-29 04:31:38'),
(85, 'App\\Models\\Admin', 1, 'admin-token', '3e6164f689f74142f7462391832ab89385ed8cce91f4aeebc87a059d57ec6521', '[\"*\"]', '2026-06-29 05:10:22', NULL, '2026-06-29 04:49:23', '2026-06-29 05:10:22');

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
(1, '110001', 'Connaught Place', 'New Delhi', 'Delhi', 1, '2026-06-18 05:17:05', '2026-06-23 06:41:23'),
(2, '110002', 'Darya Ganj', 'New Delhi', 'Delhi', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(3, '110003', 'Lodi Road', 'New Delhi', 'Delhi', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(4, '110011', 'Karol Bagh', 'New Delhi', 'Delhi', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(5, '110015', 'Rajouri Garden', 'New Delhi', 'Delhi', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(6, '110020', 'Saket', 'New Delhi', 'Delhi', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(7, '400001', 'Fort', 'Mumbai', 'Maharashtra', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(8, '400050', 'Bandra West', 'Mumbai', 'Maharashtra', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(9, '400069', 'Andheri East', 'Mumbai', 'Maharashtra', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(10, '560001', 'MG Road', 'Bengaluru', 'Karnataka', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(11, '560034', 'Jayanagar', 'Bengaluru', 'Karnataka', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(12, '600001', 'George Town', 'Chennai', 'Tamil Nadu', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(13, '700001', 'BBD Bagh', 'Kolkata', 'West Bengal', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(14, '380001', 'Relief Road', 'Ahmedabad', 'Gujarat', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(15, '411001', 'Shivajinagar', 'Pune', 'Maharashtra', 1, '2026-06-18 05:17:05', '2026-06-18 05:17:05');

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
(1, 1, 'Alphonso Mangoes', 'Premium Alphonso mangoes from Ratnagiri. Sweet, pulpy and aromatic. 1 dozen box.', 5, 27, 3, 'Fresh Arrivals, Best Selling', 1, 'products/68722a4216ede_image.png', 'products/68722a4216ede_image.png', '2026-06-18 05:17:10', '2026-06-29 04:46:41'),
(2, 1, 'Banana (Robusta)', 'Fresh robusta bananas. Rich in potassium and natural sugars. Best for breakfast.', 5, 27, NULL, 'Fresh Arrivals, Everyday Essentials', 1, 'products/68722a4c3421e_image.png', 'products/68722a4c3421e_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(3, 1, 'Tomato (Country)', 'Farm-fresh country tomatoes. Ideal for curries, salads and chutneys.', 5, 28, NULL, 'Fresh Arrivals, Everyday Essentials', 1, 'products/68722a5a1a545_image.png', 'products/68722a5a1a545_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(4, 1, 'Potato (White)', 'Fresh white potatoes. Great for sabzi, fries and curries.', 5, 28, NULL, 'Fresh Arrivals, Everyday Essentials', 1, 'products/687233df47746_image.png', 'products/687233df47746_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(5, 1, 'Onion (Red)', 'Red onions sourced from Nashik. Strong flavour, perfect for Indian cooking.', 5, 28, NULL, 'Fresh Arrivals, Everyday Essentials', 1, 'products/68732823e176f_image.png', 'products/68732823e176f_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(6, 1, 'Full Cream Milk', 'Fresh full-cream toned milk. Rich in calcium and protein. Pasteurised and hygienically packed.', 3, 13, NULL, 'Everyday Essentials', 1, 'products/6873282405fa9_image.png', 'products/6873282405fa9_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(7, 1, 'Whole Wheat Bread', 'Soft whole wheat bread. No artificial colours. Best with butter or jam.', 3, 17, NULL, 'Everyday Essentials', 1, 'products/6874f5b7246a8_image.png', 'products/6874f5b7246a8_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(8, 1, 'Fresh Paneer', 'Soft, fresh cottage cheese made from full cream milk. Perfect for paneer dishes.', 3, 15, NULL, 'Fresh Arrivals, Best Selling', 1, 'products/6874f5b765f83_image.png', 'products/6874f5b765f83_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(9, 2, 'Basmati Rice (Long Grain)', 'Premium aged long-grain basmati rice. Perfect for biryanis, pulao and special occasions.', 1, 2, NULL, 'Best Selling', 1, 'products/6874f5b77a0ba_image.png', 'products/6874f5b77a0ba_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(10, 2, 'Sunflower Cooking Oil', 'Refined sunflower oil. Light and healthy for everyday Indian cooking.', 1, 3, NULL, 'Everyday Essentials', 1, 'products/6874f5b78cad1_image.png', 'products/6874f5b78cad1_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(11, 2, 'Toor Dal (Arhar)', 'Unpolished split pigeon peas. Protein-rich, easy to cook. Ideal for dal tadka.', 1, 4, NULL, 'Everyday Essentials', 1, 'products/6874f5b7a6aa9_image.png', 'products/6874f5b7a6aa9_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(12, 2, 'Garam Masala', 'Aromatic blend of whole spices ground fresh. Adds rich flavour to curries and biryanis.', 8, 42, NULL, 'Best Selling', 1, 'products/6874f5b7b7e2a_image.png', 'products/6874f5b7b7e2a_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(13, 2, 'Turmeric Powder (Haldi)', 'Pure ground turmeric with high curcumin content. Bright colour and strong aroma.', 8, 42, NULL, 'Everyday Essentials', 1, 'products/6874f7552d622_image.png', 'products/6874f7552d622_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(14, 2, 'Maggi 2-Minute Noodles', 'India\'s favourite instant noodles. Ready in 2 minutes. Original masala flavour.', 12, 61, NULL, 'Best Selling, Daily Deals', 1, 'products/6874f7554f275_image.png', 'products/6874f7554f275_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(15, 3, 'Mixer Grinder 750W', 'Powerful 750W mixer grinder with 3 stainless steel jars. Ideal for wet and dry grinding.', 4, 22, NULL, 'Best Selling', 1, 'products/6874f7556a332_image.png', 'products/6874f7556a332_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(16, 3, 'Non-stick Kadai Set', 'Premium 3-piece non-stick kadai set. PFOA-free coating. Induction compatible.', 4, 36, NULL, 'Hot Deals, Daily Deals', 1, 'products/6874f8d6e7645_image.png', 'products/6874f8d6e7645_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(17, 2, 'Darjeeling Green Tea', 'First-flush Darjeeling green tea. Light, floral and refreshing. Rich in antioxidants.', 11, 56, NULL, 'Handpicked You 💝', 1, 'products/6874fa3e66b54_image.png', 'products/6874fa3e66b54_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(18, 2, 'Dairy Milk Silk Chocolate', 'Smooth, creamy Cadbury Dairy Milk Silk bar. The perfect gifting chocolate.', 10, 51, 3, 'Best Selling,Hot Deals,Everyday Essentials,Daily Deals,50% Off,Buy 1 Get 1', 1, 'products/6874fa3e806c5_image.png', 'products/6874fa3e806c5_image.png', '2026-06-18 05:17:10', '2026-06-29 05:01:45'),
(19, 2, 'Britannia Good Day Cashew Cookies', 'Buttery cookies loaded with premium cashew pieces. A great snack for tea time.', 10, 52, 3, 'Everyday Essentials, Handpicked You 💝', 1, 'products/6874fa3e9f2ab_image.png', 'products/6874fa3e9f2ab_image.png', '2026-06-18 05:17:10', '2026-06-29 05:13:12');

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
(1, 1, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(2, 1, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(3, 1, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(4, 2, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(5, 2, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(6, 2, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(7, 3, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(8, 3, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(9, 3, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(10, 4, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(11, 4, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(12, 4, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(13, 5, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(14, 5, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(15, 5, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(16, 6, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(17, 6, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(18, 6, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(19, 7, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(20, 7, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(21, 7, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(22, 8, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(23, 8, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(24, 8, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(25, 9, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(26, 9, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(27, 9, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(28, 10, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(29, 10, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(30, 10, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(31, 11, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(32, 11, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(33, 11, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(34, 12, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(35, 12, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(36, 12, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(37, 13, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(38, 13, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(39, 13, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(40, 14, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(41, 14, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(42, 14, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(43, 15, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(44, 15, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(45, 15, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(46, 16, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(47, 16, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(48, 16, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(49, 17, 'Quality', 'Quality checked & hygienically packed', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(50, 17, 'Freshness', 'Sourced fresh daily', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(51, 17, 'Return', 'Easy returns within 24 hours', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(70, 19, 'Quality', 'Quality checked & hygienically packed', NULL, NULL),
(71, 19, 'Freshness', 'Sourced fresh daily', NULL, NULL),
(72, 19, 'Return', 'Easy returns within 24 hours', NULL, NULL),
(79, 18, 'Quality', 'Quality checked & hygienically packed', NULL, NULL),
(80, 18, 'Freshness', 'Sourced fresh daily', NULL, NULL),
(81, 18, 'Return', 'Easy returns within 24 hours', NULL, NULL);

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
(1, 1, 'products/68722a4216ede_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(2, 2, 'products/68722a4c3421e_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(3, 3, 'products/68722a5a1a545_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(4, 4, 'products/687233df47746_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(5, 5, 'products/68732823e176f_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(6, 6, 'products/6873282405fa9_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(7, 7, 'products/6874f5b7246a8_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(8, 8, 'products/6874f5b765f83_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(9, 9, 'products/6874f5b77a0ba_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(10, 10, 'products/6874f5b78cad1_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(11, 11, 'products/6874f5b7a6aa9_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(12, 12, 'products/6874f5b7b7e2a_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(13, 13, 'products/6874f7552d622_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(14, 14, 'products/6874f7554f275_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(15, 15, 'products/6874f7556a332_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(16, 16, 'products/6874f8d6e7645_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(17, 17, 'products/6874fa3e66b54_image.png', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(21, 19, 'products/6a424a2477a49_img.png', NULL, NULL),
(22, 19, 'products/6a424a250188b_img.png', NULL, NULL),
(27, 18, 'products/6a424aaa867e0_img.png', NULL, NULL),
(28, 18, 'products/6a424aab56f33_img.png', NULL, NULL),
(29, 19, 'products/6a424c410af63_scaled_1000109544.png', NULL, NULL);

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
(1, 1, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(2, 1, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(3, 1, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(4, 1, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(5, 2, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(6, 2, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(7, 2, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(8, 2, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(9, 3, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(10, 3, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(11, 3, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(12, 3, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(13, 4, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(14, 4, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(15, 4, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(16, 4, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(17, 5, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(18, 5, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(19, 5, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(20, 5, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(21, 6, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(22, 6, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(23, 6, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(24, 6, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(25, 7, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(26, 7, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(27, 7, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(28, 7, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(29, 8, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(30, 8, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(31, 8, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(32, 8, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(33, 9, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(34, 9, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(35, 9, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(36, 9, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(37, 10, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(38, 10, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(39, 10, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(40, 10, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(41, 11, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(42, 11, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(43, 11, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(44, 11, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(45, 12, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(46, 12, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(47, 12, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(48, 12, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(49, 13, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(50, 13, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(51, 13, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(52, 13, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(53, 14, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(54, 14, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(55, 14, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(56, 14, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(57, 15, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(58, 15, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(59, 15, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(60, 15, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(61, 16, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(62, 16, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(63, 16, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(64, 16, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(65, 17, 'Country of Origin', 'India', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(66, 17, 'Shelf Life', '7 days from packaging', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(67, 17, 'Customer Care', 'support@shopq.com', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(68, 17, 'Seller', 'ShopQ Retail', '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(93, 19, 'Country of Origin', 'India', NULL, NULL),
(94, 19, 'Shelf Life', '7 days from packaging', NULL, NULL),
(95, 19, 'Customer Care', 'support@shopq.com', NULL, NULL),
(96, 19, 'Seller', 'ShopQ Retail', NULL, NULL),
(105, 18, 'Country of Origin', 'India', NULL, NULL),
(106, 18, 'Shelf Life', '7 days from packaging', NULL, NULL),
(107, 18, 'Customer Care', 'support@shopq.com', NULL, NULL),
(108, 18, 'Seller', 'ShopQ Retail', NULL, NULL);

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
(1, 'Handpicked You 💝', 1, '2026-06-18 05:17:05', '2026-06-23 06:41:22'),
(2, 'Daily Deals', 2, '2026-06-18 05:17:04', '2026-06-23 06:41:22'),
(3, 'Everyday Essentials', 3, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(4, 'Best Selling', 1, '2026-06-18 05:17:04', '2026-06-18 05:17:04'),
(5, 'Hot Deals', 5, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(6, 'Buy 1 Get 1', 6, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(7, '50% Off', 7, '2026-06-18 05:17:05', '2026-06-18 05:17:05'),
(8, 'Fresh Arrivals', 8, '2026-06-18 05:17:05', '2026-06-18 05:17:05');

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
(1, 1, '1 Dozen (12 pcs)', 450.00, 399.00, 319.20, 50, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(2, 1, '2 Dozen (24 pcs)', 850.00, 749.00, 599.20, 30, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(3, 2, '6 pcs', 40.00, 35.00, 28.00, 100, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(4, 2, '12 pcs', 75.00, 65.00, 52.00, 80, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(5, 3, '500g', 30.00, 25.00, 20.00, 200, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(6, 3, '1 kg', 55.00, 45.00, 36.00, 150, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(7, 4, '1 kg', 35.00, 28.00, 22.40, 200, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(8, 4, '3 kg', 99.00, 79.00, 63.20, 100, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(9, 4, '5 kg', 155.00, 125.00, 100.00, 60, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(10, 5, '1 kg', 40.00, 32.00, 25.60, 180, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(11, 5, '3 kg', 110.00, 90.00, 72.00, 80, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(12, 6, '500ml', 28.00, 26.00, 20.80, 150, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(13, 6, '1 litre', 54.00, 50.00, 40.00, 200, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(14, 7, '400g (18 slices)', 45.00, 40.00, 32.00, 100, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(15, 8, '200g', 80.00, 72.00, 57.60, 80, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(16, 8, '500g', 190.00, 170.00, 136.00, 50, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(17, 9, '1 kg', 150.00, 129.00, 103.20, 100, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(18, 9, '5 kg', 700.00, 599.00, 479.20, 50, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(19, 9, '10 kg', 1350.00, 1149.00, 919.20, 25, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(20, 10, '1 litre', 160.00, 145.00, 116.00, 80, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(21, 10, '5 litres', 775.00, 699.00, 559.20, 40, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(22, 11, '500g', 75.00, 65.00, 52.00, 100, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(23, 11, '1 kg', 145.00, 125.00, 100.00, 80, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(24, 11, '5 kg', 690.00, 599.00, 479.20, 30, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(25, 12, '100g', 65.00, 55.00, 44.00, 120, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(26, 12, '250g', 150.00, 125.00, 100.00, 60, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(27, 13, '100g', 40.00, 34.00, 27.20, 150, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(28, 13, '200g', 75.00, 62.00, 49.60, 80, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(29, 14, '70g (single)', 14.00, 13.00, 10.40, 300, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(30, 14, '4-pack (280g)', 56.00, 50.00, 40.00, 150, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(31, 14, '12-pack (840g)', 165.00, 148.00, 118.40, 78, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(32, 15, 'White (750W)', 3500.00, 2799.00, 2239.20, 20, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(33, 15, 'Black (750W)', 3500.00, 2799.00, 2239.20, 15, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(34, 16, '24cm + 28cm + 32cm', 2199.00, 1599.00, 1279.20, 25, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(35, 17, '25 tea bags', 120.00, 99.00, 79.20, 80, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(36, 17, '50 tea bags', 230.00, 189.00, 151.20, 50, '2026-06-18 05:17:10', '2026-06-18 05:17:10'),
(37, 18, '58g', 80.00, 75.00, 60.00, 149, '2026-06-18 05:17:10', '2026-06-29 05:06:25'),
(38, 18, '145g', 190.00, 175.00, 140.00, 77, '2026-06-18 05:17:10', '2026-06-29 05:06:25'),
(39, 19, '75g', 25.00, 22.00, 17.60, 199, '2026-06-18 05:17:10', '2026-06-29 05:13:12'),
(40, 19, '240g', 75.00, 68.00, 54.40, 119, '2026-06-18 05:17:10', '2026-06-29 05:13:12');

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
(1, 'Basic Monthly', 'monthly', 30, 299.00, '[\"List up to 50 products\",\"Select up to 3 pincodes\",\"Basic order management\",\"Email support\"]', 50, 1, 1, '2026-06-18 05:17:06', '2026-06-23 06:41:24'),
(2, 'Basic Yearly', 'yearly', 365, 2999.00, '[\"List up to 50 products\",\"Select up to 3 pincodes\",\"Basic order management\",\"Email support\",\"2 months free\"]', 50, 1, 2, '2026-06-18 05:17:06', '2026-06-18 05:17:06'),
(3, 'Standard Monthly', 'monthly', 30, 599.00, '[\"List up to 200 products\",\"Select up to 10 pincodes\",\"Priority order management\",\"Chat support\",\"Analytics dashboard\"]', 200, 1, 3, '2026-06-18 05:17:06', '2026-06-18 05:17:06'),
(4, 'Standard Yearly', 'yearly', 365, 5999.00, '[\"List up to 200 products\",\"Select up to 10 pincodes\",\"Priority order management\",\"Chat support\",\"Analytics dashboard\",\"2 months free\"]', 200, 1, 4, '2026-06-18 05:17:06', '2026-06-18 05:17:06'),
(5, 'Premium Monthly', 'monthly', 30, 999.00, '[\"Unlimited products\",\"All pincodes\",\"Dedicated account manager\",\"24\\/7 phone support\",\"Advanced analytics\",\"Featured listings\"]', 0, 1, 5, '2026-06-18 05:17:06', '2026-06-18 05:17:06'),
(6, 'Premium Yearly', 'yearly', 365, 9999.00, '[\"Unlimited products\",\"All pincodes\",\"Dedicated account manager\",\"24\\/7 phone support\",\"Advanced analytics\",\"Featured listings\",\"2 months free\"]', 0, 1, 6, '2026-06-18 05:17:06', '2026-06-18 05:17:06');

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
(1, 1, 'Atta & Flour', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:03'),
(2, 1, 'Rice', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:03'),
(3, 1, 'Cooking Oil', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:03'),
(4, 1, 'Dals & Pulses', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:03'),
(5, 1, 'Ghee', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:03'),
(6, 1, 'Suji, Maida & Besan', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-18 05:17:03'),
(7, 2, 'Cereals & Muesli', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:03'),
(8, 2, 'Ketchup & Sauces', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:03'),
(9, 2, 'Peanut Butter & Jam', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:03'),
(10, 2, 'Honey & Spreads', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:03'),
(11, 2, 'Oats & Porridge', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:03'),
(12, 2, 'Energy & Health Bars', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-18 05:17:03'),
(13, 3, 'Milk', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:03'),
(14, 3, 'Butter & Cream', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(15, 3, 'Paneer & Tofu', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(16, 3, 'Curd & Yogurt', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(17, 3, 'Bread & Buns', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:04'),
(18, 3, 'Eggs', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-18 05:17:04'),
(19, 3, 'Cheese', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 7, 1, '2026-06-18 05:17:04'),
(20, 3, 'Dairy Whitener', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 8, 1, '2026-06-18 05:17:04'),
(21, 4, 'Bulbs & Lighting', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(22, 4, 'Kitchen Appliances', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(23, 4, 'Mixer & Grinder', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(24, 4, 'Smartwatches', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(25, 4, 'Speakers & Audio', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:04'),
(26, 4, 'Fans & Coolers', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-18 05:17:04'),
(27, 5, 'Fresh Fruits', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(28, 5, 'Fresh Vegetables', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(29, 5, 'Leafy Greens', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(30, 5, 'Exotic Fruits', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(31, 5, 'Organic Produce', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:04'),
(32, 6, 'Ice Creams', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(33, 6, 'Kulfi', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(34, 6, 'Ice Cream Bars', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(35, 6, 'Frozen Desserts', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(36, 7, 'Cookware', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(37, 7, 'Storage Containers', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(38, 7, 'Dinner Sets', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(39, 7, 'Kitchen Tools', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(40, 7, 'Bakeware', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:04'),
(41, 8, 'Whole Spices', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(42, 8, 'Blended Masala', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(43, 8, 'Salt & Sugar', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(44, 8, 'Almonds & Cashews', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(45, 8, 'Raisins & Dates', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:04'),
(46, 8, 'Seeds & Superfoods', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-18 05:17:04'),
(47, 9, 'Frozen Vegetables', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(48, 9, 'Frozen Snacks', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(49, 9, 'Frozen Parathas', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(50, 9, 'Frozen Meat & Seafood', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(51, 10, 'Chocolates', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(52, 10, 'Cookies & Biscuits', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(53, 10, 'Cakes & Pastries', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(54, 10, 'Mithai & Sweets', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(55, 10, 'Candies & Gummies', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:04'),
(56, 11, 'Tea', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(57, 11, 'Coffee', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(58, 11, 'Green Tea', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(59, 11, 'Health Drinks', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(60, 11, 'Juices & Shakes', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:04'),
(61, 12, 'Instant Noodles', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 1, 1, '2026-06-18 05:17:04'),
(62, 12, 'Ready to Cook', 'subcategories/sub_1781169615267.png', 'subcategories/sub_1781169615267.png', 2, 1, '2026-06-18 05:17:04'),
(63, 12, 'Chips & Namkeen', 'subcategories/sub_1781335626718.png', 'subcategories/sub_1781335626718.png', 3, 1, '2026-06-18 05:17:04'),
(64, 12, 'Canned & Tinned', 'subcategories/sub_1781335644937.png', 'subcategories/sub_1781335644937.png', 4, 1, '2026-06-18 05:17:04'),
(65, 12, 'Pasta & Vermicelli', 'subcategories/sub_1781335660557.png', 'subcategories/sub_1781335660557.png', 5, 1, '2026-06-18 05:17:04'),
(66, 12, 'Soups & Broths', 'subcategories/sub_1781088653742.png', 'subcategories/sub_1781088653742.png', 6, 1, '2026-06-18 05:17:04');

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `status`, `pincode_id`, `date_time`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`, `fcm_token`) VALUES
(1, 'Rahul Sharma', 'rahul@example.com', 'active', 1, NULL, NULL, '$2y$12$dgsWXqxCj77Tkpd59REZCuYbZWlWfbT9LzdbfqMzG0yQCVMCNDlX2', NULL, '2026-06-18 05:17:08', '2026-06-18 05:17:08', 'cgOUXKYiREqbz_f64QZ4_u:APA91bGaYSXbLeZMbQ4sCswsrVw-sKPO4Dm9rX_PrV3Du72Aa3_JBRhmP-ShzLQZUq5Suo7ewndjnFLXDA9EsiIdX7WwtFUm7By5H3A3jImusxkc2jMm43M'),
(2, 'Priya Verma', 'priya@example.com', 'active', NULL, NULL, NULL, '$2y$12$EUfODR5m4l3.h8LxtUooUuHcBRuthbKak2ZGMrP0bT6X1z8zAyT.i', NULL, '2026-06-18 05:17:08', '2026-06-18 05:17:08', NULL),
(3, 'Amit Kumar', 'amit@example.com', 'active', NULL, NULL, NULL, '$2y$12$bCyW69U3V.gIvKjSVOFwxulvnX.UDB6jNcgmxWKrnR4yweWAp/6iC', NULL, '2026-06-18 05:17:08', '2026-06-18 05:17:08', NULL),
(4, 'Sneha Patel', 'sneha@example.com', 'active', NULL, NULL, NULL, '$2y$12$kfA80Ib9kbTtVuzo1mpD6OhyDVTay/aa.b6/R08z.i8mE8uyBFLJC', NULL, '2026-06-18 05:17:09', '2026-06-18 05:17:09', NULL),
(5, 'Vikas Singh', 'vikas@example.com', 'active', NULL, NULL, NULL, '$2y$12$psWqbIG.gbciqL7paEur6e18my8yP3JND5m8oEqDl5QSM68HI5oP.', NULL, '2026-06-18 05:17:09', '2026-06-18 05:17:09', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_stats`
--

CREATE TABLE `user_stats` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `pincode_id` bigint(20) UNSIGNED DEFAULT NULL,
  `pincode_code` varchar(20) DEFAULT NULL,
  `area_name` varchar(255) DEFAULT NULL,
  `city` varchar(120) DEFAULT NULL,
  `state` varchar(120) DEFAULT NULL,
  `language` varchar(10) DEFAULT NULL,
  `registered_at` timestamp NULL DEFAULT NULL,
  `total_orders` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `last_order_at` timestamp NULL DEFAULT NULL,
  `has_pending` tinyint(1) NOT NULL DEFAULT 0,
  `has_cancelled` tinyint(1) NOT NULL DEFAULT 0,
  `has_completed` tinyint(1) NOT NULL DEFAULT 0,
  `last_active_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_stats`
--

INSERT INTO `user_stats` (`user_id`, `pincode_id`, `pincode_code`, `area_name`, `city`, `state`, `language`, `registered_at`, `total_orders`, `last_order_at`, `has_pending`, `has_cancelled`, `has_completed`, `last_active_at`, `created_at`, `updated_at`) VALUES
(1, 1, '110001', 'Connaught Place', 'New Delhi', 'Delhi', 'en', '2026-06-18 05:17:08', 0, NULL, 0, 0, 0, '2026-06-18 05:17:08', '2026-06-27 05:54:58', '2026-06-27 06:14:25'),
(2, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-18 05:17:08', 0, NULL, 0, 0, 0, '2026-06-18 05:17:08', '2026-06-27 05:54:58', '2026-06-27 06:14:24'),
(3, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-18 05:17:08', 0, NULL, 0, 0, 0, '2026-06-18 05:17:08', '2026-06-27 05:54:58', '2026-06-27 06:14:24'),
(4, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-18 05:17:09', 0, NULL, 0, 0, 0, '2026-06-18 05:17:09', '2026-06-27 05:54:58', '2026-06-27 06:14:24'),
(5, NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-18 05:17:09', 0, NULL, 0, 0, 0, '2026-06-18 05:17:09', '2026-06-27 05:54:58', '2026-06-27 06:14:24');

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
  `updated_at` timestamp NULL DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vendors`
--

INSERT INTO `vendors` (`id`, `name`, `email`, `phone`, `password`, `shop_name`, `shop_description`, `logo`, `status`, `commission_rate`, `payout_account`, `rejection_reason`, `remember_token`, `created_at`, `updated_at`, `fcm_token`) VALUES
(1, 'Ravi Groceries', 'ravi@vendor.com', '9876543210', '$2y$12$ikUjlBBhtSxdB6FWWD3cL.Dg4O01INqduw6NQa/2o0nyWRSBAqChy', 'Ravi Fresh Store', 'Fresh fruits, vegetables and dairy products delivered daily.', 'vendors/scaled_logo (4).png', 'approved', NULL, NULL, NULL, NULL, '2026-06-18 05:17:06', '2026-06-29 03:27:15', 'ftASG_ocCvom54aUP6c7HM:APA91bF_PZfqAXHSw9v5FIlP-TmtBS7uwnwrCKV11bOsW8wMVUEFZE_EFKsUn_NweN9lFxUgQB2baBlmKLQeL39BeV1pwiqZoMeW5xzSo6qZkStNs_DoOi4'),
(2, 'Meena Supermart', 'meena@vendor.com', '9123456780', '$2y$12$7NARqPFDaU4ofAgvYhZToe3gtEZVCZMIu1MM0PBAbTfwDeox6noAy', 'Meena Super Mart', 'Your one-stop shop for packaged food, snacks and beverages.', 'vendors/scaled_logo (4).png', 'approved', NULL, NULL, NULL, NULL, '2026-06-18 05:17:06', '2026-06-29 04:05:01', 'frvQgAALT0SDWUpANcTrxF:APA91bEQIHDYR5fn_6E9t1p6pMWIb023Z-mHJabeEaTFc9S0bXh-yfyVR-wAsv0fkKmGQtjzv0wBpzBGucM-87kZs-iBgwdYdppTVLyPfuVeb8jsSlRbiVI'),
(3, 'Deepak Electronics', 'deepak@vendor.com', '9988776655', '$2y$12$pNGucFVwgHGjdMhz0kVlEepl/gSwlJgHi457P8OtYZgLTk2.jB08G', 'Deepak Electronics Hub', 'Kitchen appliances, gadgets and electronics at best prices.', 'vendors/scaled_logo (4).png', 'approved', NULL, NULL, NULL, NULL, '2026-06-18 05:17:06', '2026-06-18 05:17:06', NULL),
(4, 'Sunita Dairy', 'sunita@vendor.com', '9001122334', '$2y$12$LJlif5IAGh.XxIc1xAPQGeeB8kmOI2iY2SZvjHNKTKWLzfsXlAXcC', 'Sunita Pure Dairy', 'Organic dairy products — milk, curd, paneer and ghee.', NULL, 'pending', NULL, NULL, NULL, NULL, '2026-06-18 05:17:06', '2026-06-18 05:17:06', NULL),
(5, 'Prakash Spices', 'prakash@vendor.com', '9445566778', '$2y$12$9.D9GcTAKHj0OjbDIUz52uFGXmDWDh0ttDfaVmXebT8gOJ9wJtcsC', 'Prakash Masala King', 'Authentic Indian spices and masalas sourced directly from farms.', NULL, 'suspended', NULL, NULL, NULL, NULL, '2026-06-18 05:17:06', '2026-06-18 05:17:06', NULL);

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
  `goods_subtotal` int(11) NOT NULL DEFAULT 0,
  `coupon_share` int(11) NOT NULL DEFAULT 0,
  `delivery_share` int(11) NOT NULL DEFAULT 0,
  `handling_share` int(11) NOT NULL DEFAULT 0,
  `collect_amount` int(11) NOT NULL DEFAULT 0,
  `payment_status` varchar(20) NOT NULL DEFAULT 'pending',
  `cod_collected_amount` int(11) DEFAULT NULL,
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

INSERT INTO `vendor_orders` (`id`, `parent_order_id`, `vendor_id`, `status`, `items_subtotal`, `goods_subtotal`, `coupon_share`, `delivery_share`, `handling_share`, `collect_amount`, `payment_status`, `cod_collected_amount`, `commission_rate`, `commission_amount`, `vendor_earning`, `delivery_boy_id`, `tracking_number`, `courier_name`, `cancel_reason`, `payout_id`, `confirmed_at`, `packed_at`, `assigned_at`, `picked_up_at`, `out_for_delivery_at`, `delivered_at`, `cancelled_at`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 'confirmed', 175.00, 175, 0, 10, 9, 194, 'pending', NULL, 0.00, 0.00, 175.00, NULL, NULL, NULL, NULL, NULL, '2026-06-29 04:22:27', NULL, NULL, NULL, NULL, NULL, NULL, '2026-06-29 02:53:02', '2026-06-29 04:22:27'),
(2, 2, 2, 'delivered', 296.00, 296, 30, 10, 9, 285, 'pending', NULL, 0.00, 0.00, 266.00, 1, NULL, NULL, NULL, NULL, '2026-06-29 03:28:13', '2026-06-29 03:28:26', '2026-06-29 03:28:48', NULL, '2026-06-29 03:29:06', '2026-06-29 03:29:13', NULL, '2026-06-29 03:01:59', '2026-06-29 03:29:13'),
(3, 3, 2, 'delivered', 340.00, 340, 0, 10, 9, 359, 'collected', 359, 0.00, 0.00, 340.00, 1, NULL, NULL, NULL, NULL, '2026-06-29 04:28:20', '2026-06-29 04:28:27', '2026-06-29 04:28:32', NULL, '2026-06-29 04:31:16', '2026-06-29 04:31:26', NULL, '2026-06-29 04:23:48', '2026-06-29 04:31:26'),
(4, 4, 2, 'delivered', 175.00, 175, 0, 10, 9, 194, 'collected', 194, 0.00, 0.00, 175.00, 1, NULL, NULL, NULL, NULL, '2026-06-29 04:30:07', '2026-06-29 04:30:11', '2026-06-29 04:30:16', '2026-06-29 04:30:32', '2026-06-29 04:31:01', '2026-06-29 04:31:33', NULL, '2026-06-29 04:26:55', '2026-06-29 04:31:33');

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
(1, 1, 1, '110001', 'Connaught Place', 1, '2026-06-18 05:17:06'),
(2, 1, 2, '110002', 'Darya Ganj', 1, '2026-06-18 05:17:06'),
(3, 1, 4, '110011', 'Karol Bagh', 1, '2026-06-18 05:17:06'),
(4, 1, 6, '110020', 'Saket', 1, '2026-06-18 05:17:06'),
(8, 3, 10, '560001', 'MG Road', 1, '2026-06-18 05:17:06'),
(9, 3, 11, '560034', 'Jayanagar', 1, '2026-06-18 05:17:06'),
(10, 3, 15, '411001', 'Shivajinagar', 1, '2026-06-18 05:17:06'),
(11, 2, 1, '110001', 'Connaught Place', 1, '2026-06-18 11:49:52'),
(12, 2, 2, '110002', 'Darya Ganj', 1, '2026-06-18 11:49:52'),
(13, 2, 3, '110003', 'Lodi Road', 1, '2026-06-22 11:25:30'),
(14, 2, 4, '110011', 'Karol Bagh', 1, '2026-06-22 11:25:31'),
(15, 2, 5, '110015', 'Rajouri Garden', 1, '2026-06-22 11:25:31');

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
(1, 1, 3, '2026-06-18', '2026-07-18', 'active', NULL, NULL, NULL, '2026-06-18 05:17:06', '2026-06-18 05:17:06'),
(2, 2, 5, '2026-06-18', '2026-07-18', 'active', NULL, NULL, NULL, '2026-06-18 05:17:06', '2026-06-18 05:17:06'),
(3, 3, 1, '2026-06-18', '2026-07-18', 'active', NULL, NULL, NULL, '2026-06-18 05:17:06', '2026-06-18 05:17:06');

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
(1, 3, 9, '2026-06-18 05:17:18'),
(2, 3, 10, '2026-06-18 05:17:18'),
(3, 2, 11, '2026-06-18 05:17:18');

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
-- Indexes for table `app_notifications`
--
ALTER TABLE `app_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `app_notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`),
  ADD KEY `app_notifications_notifiable_type_notifiable_id_read_at_index` (`notifiable_type`,`notifiable_id`,`read_at`);

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
-- Indexes for table `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`id`),
  ADD KEY `brands_is_active_position_index` (`is_active`,`position`);

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
  ADD KEY `cart_items_product_id_foreign` (`product_id`),
  ADD KEY `cart_items_user_id_index` (`user_id`);

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
-- Indexes for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `device_tokens_token_unique` (`token`),
  ADD KEY `device_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `device_tokens_is_valid_last_seen_at_index` (`is_valid`,`last_seen_at`);

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
-- Indexes for table `ledger_accounts`
--
ALTER TABLE `ledger_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ledger_accounts_identity_unique` (`code`,`owner_type`,`owner_id`);

--
-- Indexes for table `ledger_entries`
--
ALTER TABLE `ledger_entries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ledger_entries_idem_unique` (`idempotency_key`),
  ADD KEY `ledger_entries_entry_type_index` (`entry_type`),
  ADD KEY `ledger_entries_source_type_source_id_index` (`source_type`,`source_id`),
  ADD KEY `ledger_entries_reversed_entry_id_index` (`reversed_entry_id`);

--
-- Indexes for table `ledger_lines`
--
ALTER TABLE `ledger_lines`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ledger_lines_account_id_index` (`account_id`),
  ADD KEY `ledger_lines_entry_id_index` (`entry_id`);

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
-- Indexes for table `notification_campaigns`
--
ALTER TABLE `notification_campaigns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notification_campaigns_status_scheduled_at_index` (`status`,`scheduled_at`),
  ADD KEY `notification_campaigns_status_next_run_at_index` (`status`,`next_run_at`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_location_id_foreign` (`location_id`),
  ADD KEY `orders_vendor_id_foreign` (`vendor_id`),
  ADD KEY `orders_user_id_index` (`user_id`),
  ADD KEY `orders_status_index` (`status`);

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
  ADD KEY `order_items_vendor_order_id_index` (`vendor_order_id`),
  ADD KEY `order_items_order_id_index` (`order_id`);

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
-- Indexes for table `user_stats`
--
ALTER TABLE `user_stats`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `user_stats_city_index` (`city`),
  ADD KEY `user_stats_state_index` (`state`),
  ADD KEY `user_stats_pincode_code_index` (`pincode_code`),
  ADD KEY `user_stats_total_orders_index` (`total_orders`),
  ADD KEY `user_stats_last_order_at_index` (`last_order_at`);

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
  ADD KEY `wishlist_product_id_foreign` (`product_id`),
  ADD KEY `wishlist_user_id_index` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `app_notifications`
--
ALTER TABLE `app_notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=99;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `banner`
--
ALTER TABLE `banner`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `delivery_boy`
--
ALTER TABLE `delivery_boy`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
-- AUTO_INCREMENT for table `device_tokens`
--
ALTER TABLE `device_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `home_tabs`
--
ALTER TABLE `home_tabs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT for table `ledger_accounts`
--
ALTER TABLE `ledger_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `ledger_entries`
--
ALTER TABLE `ledger_entries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `ledger_lines`
--
ALTER TABLE `ledger_lines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `main_category`
--
ALTER TABLE `main_category`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `minimum_order_amout`
--
ALTER TABLE `minimum_order_amout`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `notification_campaigns`
--
ALTER TABLE `notification_campaigns`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `order_assignment`
--
ALTER TABLE `order_assignment`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `order_status_history`
--
ALTER TABLE `order_status_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `otp_table`
--
ALTER TABLE `otp_table`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT for table `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `product_info`
--
ALTER TABLE `product_info`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=109;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `vendors`
--
ALTER TABLE `vendors`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `vendor_orders`
--
ALTER TABLE `vendor_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `vendor_payouts`
--
ALTER TABLE `vendor_payouts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vendor_pincodes`
--
ALTER TABLE `vendor_pincodes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

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
-- Constraints for table `ledger_lines`
--
ALTER TABLE `ledger_lines`
  ADD CONSTRAINT `ledger_lines_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `ledger_accounts` (`id`),
  ADD CONSTRAINT `ledger_lines_entry_id_foreign` FOREIGN KEY (`entry_id`) REFERENCES `ledger_entries` (`id`) ON DELETE CASCADE;

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
