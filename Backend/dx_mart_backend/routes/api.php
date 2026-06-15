<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\BannerController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CouponController;
use App\Http\Controllers\DeliveryAddressController;
use App\Http\Controllers\SettingsController;
use App\Http\Controllers\HelpController;
use App\Http\Controllers\LocationController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\WishlistController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ProductTypeController;
use App\Http\Controllers\HomeTabController;
use App\Http\Controllers\VendorAuthController;
use App\Http\Controllers\VendorController;
use App\Http\Controllers\VendorProductController;
use App\Http\Controllers\SubscriptionPlanController;
use App\Http\Controllers\PincodeController;
use App\Http\Controllers\AppConfigController;
use App\Http\Controllers\HomeSectionController;

// ─────────────────────────────────────────────
// PUBLIC ROUTES
// ─────────────────────────────────────────────

Route::get('/test', function () {
    return response()->json([
        'success' => true,
        'message' => 'API Working'
    ]);
});

// User auth
Route::post('/auth/signup',           [AuthController::class, 'signup']);
Route::post('/auth/login',            [AuthController::class, 'login']);
Route::post('/auth/forgot-password',  [AuthController::class, 'forgotPassword']);
Route::post('/auth/verify-otp',       [AuthController::class, 'verifyOtp']);
Route::post('/auth/reset-password',   [AuthController::class, 'resetPassword']);
Route::get('/auth/user',              [AuthController::class, 'getUser']);

// Banners & Categories (read)
Route::get('/banners',                [BannerController::class, 'view']);
Route::get('/categories',             [CategoryController::class, 'view']);
Route::get('/categories/subcategories', [CategoryController::class, 'getSubcategories']);
Route::get('/brand',                  [CategoryController::class, 'view']);

// Coupons (read)
Route::get('/coupons',                [CouponController::class, 'view']);
Route::get('/coupons/validate',       [CouponController::class, 'validate']);

// Product Types (read)
Route::get('/product-types',          [ProductTypeController::class, 'view']);

// Home Tabs (read)
Route::get('/home-tabs',              [HomeTabController::class, 'view']);

// Admin-configured per-tab storefront layout (read)
Route::get('/tab-layout',             [HomeSectionController::class, 'tabLayout']);

// Products (read)
Route::get('/products',               [ProductController::class, 'getAll']);
Route::get('/products/by-category',   [ProductController::class, 'getByCategory']);
Route::get('/products/by-type',       [ProductController::class, 'getByType']);
Route::get('/products/by-subcategory', [ProductController::class, 'getBySubcategory']);
Route::get('/products/single',        [ProductController::class, 'single']);

// Settings (read)
Route::get('/settings/delivery-charge',  [SettingsController::class, 'getDeliveryCharge']);
Route::get('/settings/free-delivery',    [SettingsController::class, 'getFreeDelivery']);
Route::get('/settings/handling-charge',  [SettingsController::class, 'getHandlingCharge']);
Route::get('/settings/delivery-time',    [SettingsController::class, 'getDeliveryTime']);
Route::get('/settings/min-order',        [SettingsController::class, 'getMinOrderAmount']);

// Help (read)
Route::get('/help/call',              [HelpController::class, 'getCall']);
Route::get('/help/email',             [HelpController::class, 'getEmail']);
Route::get('/help/whatsapp',          [HelpController::class, 'getWhatsapp']);

// Location (read)
Route::get('/location/districts',     [LocationController::class, 'viewDistricts']);
Route::post('/location/cities',       [LocationController::class, 'viewCities']);

// Pincodes (read)
Route::get('/pincodes',               [PincodeController::class, 'view']);
Route::get('/pincodes/check',         [PincodeController::class, 'check']);

// Subscription Plans (read)
Route::get('/subscription-plans',     [SubscriptionPlanController::class, 'view']);

// App config / theme (read) — drives admin-controlled user-app appearance
Route::get('/app-config',             [AppConfigController::class, 'get']);

// Cart (user_id-based, no token needed)
Route::post('/cart/add',              [CartController::class, 'add']);
Route::get('/cart',                   [CartController::class, 'get']);
Route::get('/cart/remove',            [CartController::class, 'remove']);
Route::post('/cart/update-quantity',  [CartController::class, 'updateQuantity']);

// Wishlist (user_id-based, no token needed)
Route::post('/wishlist/add',          [WishlistController::class, 'add']);
Route::get('/wishlist',               [WishlistController::class, 'get']);
Route::get('/wishlist/check',         [WishlistController::class, 'check']);
Route::post('/wishlist/remove',       [WishlistController::class, 'remove']);

// Vendor Auth (public)
Route::post('/vendor/register',       [VendorAuthController::class, 'register']);
Route::post('/vendor/login',          [VendorAuthController::class, 'login']);

// Public shop page (user app) — shop info + its products
Route::get('/shop',                   [VendorController::class, 'publicShow']);

// Storage files
Route::get('/files/{path}', function (string $path) {
    $fullPath = storage_path('app/public/' . $path);
    if (!file_exists($fullPath)) {
        return response()->json(['error' => 'File not found'], 404);
    }
    return response()->file($fullPath);
})->where('path', '.*');

// ─────────────────────────────────────────────
// USER-AUTHENTICATED ROUTES (Sanctum token)
// ─────────────────────────────────────────────

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/auth/logout',           [AuthController::class, 'logout']);
    Route::post('/auth/edit-profile',     [AuthController::class, 'editProfile']);

    // Delivery Address
    Route::post('/address/add',           [DeliveryAddressController::class, 'add']);
    Route::post('/address',               [DeliveryAddressController::class, 'view']);
    Route::post('/address/edit',          [DeliveryAddressController::class, 'edit']);
    Route::post('/address/delete',        [DeliveryAddressController::class, 'delete']);

    // Orders (user)
    Route::post('/orders/place',          [OrderController::class, 'place']);
    Route::post('/orders/by-user',        [OrderController::class, 'getByUser']);
    // NOTE: orders/{id} must be defined AFTER all named sub-paths to avoid wildcard capture
    Route::get('/orders/{id}',            [OrderController::class, 'getSingle'])->where('id', '[0-9]+');

    // Pincode
    Route::post('/auth/set-pincode',      [PincodeController::class, 'setUserPincode']);
});

// ─────────────────────────────────────────────
// ADMIN ROUTES — session-based auth
// ─────────────────────────────────────────────
//
// All admin routes go through cookie + session middleware so the
// session cookie is created and validated for auth:admin.
// ─────────────────────────────────────────────

Route::post('/admin/login', [AdminController::class, 'login']);

Route::middleware('auth:admin')->group(function () {

    Route::post('/admin/logout',      [AdminController::class, 'logout']);
    Route::get('/admin/me',           [AdminController::class, 'me']);

    // App config / theme (write)
    Route::post('/admin/app-config',  [AppConfigController::class, 'update']);

    // Users
    Route::get('/auth/all-users',         [AuthController::class, 'getAllUsers']);
    Route::post('/auth/user-status',      [AuthController::class, 'userStatus']);

    // Banners (write)
    Route::get('/admin/banners',            [BannerController::class, 'viewAll']);
    Route::post('/banners/add',           [BannerController::class, 'add']);
    Route::post('/banners/edit',          [BannerController::class, 'edit']);
    Route::post('/banners/toggle',        [BannerController::class, 'toggle']);
    Route::post('/banners/delete',        [BannerController::class, 'delete']);

    // Categories (write)
    Route::get('/admin/categories',        [CategoryController::class, 'viewAll']);
    Route::get('/admin/categories/subcategories', [CategoryController::class, 'getAllSubcategories']);
    Route::post('/categories/add',        [CategoryController::class, 'add']);
    Route::post('/categories/edit',       [CategoryController::class, 'edit']);
    Route::post('/categories/delete',     [CategoryController::class, 'delete']);

    // Subcategories (write)
    Route::post('/categories/subcategories/add',    [CategoryController::class, 'addSubcategory']);
    Route::post('/categories/subcategories/edit',   [CategoryController::class, 'editSubcategory']);
    Route::post('/categories/subcategories/delete', [CategoryController::class, 'deleteSubcategory']);

    // Coupons (write)
    Route::get('/admin/coupons',           [CouponController::class, 'viewAll']);
    Route::post('/coupons/add',           [CouponController::class, 'add']);
    Route::post('/coupons/edit',          [CouponController::class, 'edit']);
    Route::post('/coupons/delete',        [CouponController::class, 'delete']);

    // Settings (write)
    Route::post('/settings/delivery-charge',  [SettingsController::class, 'updateDeliveryCharge']);
    Route::post('/settings/free-delivery',    [SettingsController::class, 'updateFreeDelivery']);
    Route::post('/settings/handling-charge',  [SettingsController::class, 'updateHandlingCharge']);
    Route::post('/settings/delivery-time',    [SettingsController::class, 'updateDeliveryTime']);
    Route::post('/settings/min-order',        [SettingsController::class, 'updateMinOrderAmount']);

    // Help (write)
    Route::post('/help/call',             [HelpController::class, 'updateCall']);
    Route::post('/help/email',            [HelpController::class, 'updateEmail']);
    Route::post('/help/whatsapp',         [HelpController::class, 'updateWhatsapp']);

    // Location (write)
    Route::post('/location/districts/add',     [LocationController::class, 'addDistrict']);
    Route::post('/location/districts/update',  [LocationController::class, 'updateDistrict']);
    Route::post('/location/districts/delete',  [LocationController::class, 'deleteDistrict']);
    Route::post('/location/cities/add',        [LocationController::class, 'addCity']);
    Route::post('/location/cities/update',     [LocationController::class, 'updateCity']);
    Route::post('/location/cities/delete',     [LocationController::class, 'deleteCity']);

    // Product Types (write)
    Route::post('/product-types/add',          [ProductTypeController::class, 'add']);
    Route::post('/product-types/edit',         [ProductTypeController::class, 'edit']);
    Route::post('/product-types/delete',       [ProductTypeController::class, 'delete']);
    Route::post('/product-types/reorder',      [ProductTypeController::class, 'reorder']);

    // Home Tabs (admin)
    Route::get('/home-tabs/all',               [HomeTabController::class, 'viewAll']);

    // Home Sections (admin) — per-tab storefront builder
    Route::get('/admin/home-sections',         [HomeSectionController::class, 'index']);
    Route::post('/admin/home-sections/add',    [HomeSectionController::class, 'add']);
    Route::post('/admin/home-sections/edit',   [HomeSectionController::class, 'edit']);
    Route::post('/admin/home-sections/delete', [HomeSectionController::class, 'delete']);
    Route::post('/admin/home-sections/toggle', [HomeSectionController::class, 'toggle']);
    Route::post('/admin/home-sections/reorder',[HomeSectionController::class, 'reorder']);
    Route::post('/home-tabs/add',              [HomeTabController::class, 'add']);
    Route::post('/home-tabs/edit',             [HomeTabController::class, 'edit']);
    Route::post('/home-tabs/delete',           [HomeTabController::class, 'delete']);
    Route::post('/home-tabs/toggle',           [HomeTabController::class, 'toggle']);
    Route::post('/home-tabs/reorder',          [HomeTabController::class, 'reorder']);

    // Products (write)
    Route::post('/products/insert',            [ProductController::class, 'insert']);
    Route::post('/products/update',            [ProductController::class, 'update']);
    Route::post('/products/delete',            [ProductController::class, 'delete']);
    Route::post('/products/update-stock',      [ProductController::class, 'updateStock']);
    Route::post('/products/update-type',       [ProductController::class, 'updateType']);
    Route::post('/products/upload-image',      [ProductController::class, 'uploadImage']);
    Route::post('/products/variant',           [ProductController::class, 'saveVariant']);
    Route::post('/products/highlight',         [ProductController::class, 'saveHighlight']);
    Route::post('/products/info',              [ProductController::class, 'saveInfo']);

    // Orders (admin)
    Route::get('/orders',                      [OrderController::class, 'getAll']);
    Route::get('/orders/dashboard',            [OrderController::class, 'getAllDashboard']);
    Route::post('/orders/update-status',       [OrderController::class, 'updateStatus']);
    Route::get('/orders/sales-report',         [OrderController::class, 'getSalesReport']);
    Route::post('/orders/assign',              [OrderController::class, 'assign']);
    Route::get('/orders/delivery',             [OrderController::class, 'fetchDeliveryOrders']);
    Route::get('/delivery-boys',               [OrderController::class, 'getDeliveryBoys']);

    // Vendor management
    Route::get('/admin/vendors',               [VendorController::class, 'index']);
    Route::get('/admin/vendors/stats',         [VendorController::class, 'stats']);
    Route::get('/admin/vendors/{id}',          [VendorController::class, 'show']);
    Route::post('/admin/vendors/approve',      [VendorController::class, 'approve']);
    Route::post('/admin/vendors/reject',       [VendorController::class, 'reject']);
    Route::post('/admin/vendors/suspend',      [VendorController::class, 'suspend']);
    Route::post('/admin/vendors/delete',       [VendorController::class, 'delete']);

    // Subscription plans (admin)
    Route::get('/admin/subscription-plans',           [SubscriptionPlanController::class, 'viewAll']);
    Route::post('/admin/subscription-plans/add',      [SubscriptionPlanController::class, 'add']);
    Route::post('/admin/subscription-plans/edit',     [SubscriptionPlanController::class, 'edit']);
    Route::post('/admin/subscription-plans/delete',   [SubscriptionPlanController::class, 'delete']);
    Route::post('/admin/subscription-plans/toggle',   [SubscriptionPlanController::class, 'toggle']);
    Route::post('/admin/subscriptions/grant',         [SubscriptionPlanController::class, 'adminGrant']);

    // Pincodes (admin)
    Route::get('/admin/pincodes',              [PincodeController::class, 'viewAll']);
    Route::post('/admin/pincodes/add',         [PincodeController::class, 'add']);
    Route::post('/admin/pincodes/add-bulk',    [PincodeController::class, 'addBulk']);
    Route::post('/admin/pincodes/edit',        [PincodeController::class, 'edit']);
    Route::post('/admin/pincodes/toggle',      [PincodeController::class, 'toggle']);
    Route::post('/admin/pincodes/delete',      [PincodeController::class, 'delete']);
});

// ─────────────────────────────────────────────
// VENDOR AUTHENTICATED ROUTES (Sanctum — vendor guard)
// ─────────────────────────────────────────────

Route::middleware('auth:vendor')->group(function () {

    Route::post('/vendor/logout',            [VendorAuthController::class, 'logout']);
    Route::get('/vendor/profile',            [VendorAuthController::class, 'profile']);
    Route::post('/vendor/profile/update',    [VendorAuthController::class, 'updateProfile']);
    Route::post('/vendor/change-password',   [VendorAuthController::class, 'changePassword']);

    Route::get('/vendor/pincodes',               [PincodeController::class, 'vendorPincodes']);
    Route::post('/vendor/pincodes/update',       [PincodeController::class, 'vendorUpdatePincodes']);

    Route::get('/vendor/subscription',           [SubscriptionPlanController::class, 'vendorSubscription']);
    Route::post('/vendor/subscribe',             [SubscriptionPlanController::class, 'subscribe']);

    Route::get('/vendor/products',               [VendorProductController::class, 'index']);
    Route::get('/vendor/products/single',        [VendorProductController::class, 'single']);
    Route::post('/vendor/products/insert',       [VendorProductController::class, 'insert']);
    Route::post('/vendor/products/update',       [VendorProductController::class, 'update']);
    Route::post('/vendor/products/delete',       [VendorProductController::class, 'delete']);
    Route::post('/vendor/products/upload-image', [VendorProductController::class, 'uploadImage']);
    Route::post('/vendor/products/update-stock', [VendorProductController::class, 'updateStock']);
    Route::post('/vendor/products/update-type',  [VendorProductController::class, 'updateType']);
    Route::post('/vendor/products/variant',      [VendorProductController::class, 'saveVariant']);
    Route::post('/vendor/products/highlight',    [VendorProductController::class, 'saveHighlight']);
    Route::post('/vendor/products/info',         [VendorProductController::class, 'saveInfo']);

    Route::get('/vendor/orders',                 [VendorProductController::class, 'orders']);
    Route::post('/vendor/orders/update-status',  [VendorProductController::class, 'updateOrderStatus']);
});
