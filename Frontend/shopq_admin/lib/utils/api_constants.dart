class ApiConstants {
  // static const String BASE_URL = "http://192.168.1.6:8000/api";
  // static const String BASE_IMAGE_URL = "http://192.168.1.6:8000/storage/";
  // static const String BASE_URL = "http://localhost:8000/api";
  // static const String BASE_IMAGE_URL = "http://localhost:8000/storage/";
  static const String BASE_URL = "https://shopq.solarsunshakti.com/api";
  static const String BASE_IMAGE_URL = "https://shopq.solarsunshakti.com/storage/";

  // ── Brands ────────────────────────────────────────
  static const String BRANDS_ALL    = "$BASE_URL/admin/brands";
  static const String BRAND_ADD     = "$BASE_URL/admin/brands/add";
  static const String BRAND_EDIT    = "$BASE_URL/admin/brands/edit";
  static const String BRAND_TOGGLE  = "$BASE_URL/admin/brands/toggle";
  static const String BRAND_REORDER = "$BASE_URL/admin/brands/reorder";
  static const String BRAND_DELETE  = "$BASE_URL/admin/brands/delete";

  // ── Notification Campaigns ────────────────────────
  static const String CAMPAIGNS          = "$BASE_URL/admin/campaigns";
  static const String CAMPAIGN_PREVIEW   = "$BASE_URL/admin/campaigns/preview-audience";
  static const String USER_STATS_REBUILD = "$BASE_URL/admin/user-stats/rebuild";
  static String campaignSend(int id)      => "$BASE_URL/admin/campaigns/$id/send";
  static String campaignCancel(int id)    => "$BASE_URL/admin/campaigns/$id/cancel";
  static String campaignUpdate(int id)    => "$BASE_URL/admin/campaigns/$id";
  static String campaignDuplicate(int id) => "$BASE_URL/admin/campaigns/$id/duplicate";
  static String campaignDelete(int id)    => "$BASE_URL/admin/campaigns/$id";

  // ── Auth ──────────────────────────────────────────
  static const String LOGIN    = "$BASE_URL/admin/login";
  static const String LOGOUT   = "$BASE_URL/admin/logout";
  static const String ADMIN_ME = "$BASE_URL/admin/me";

  // ── App config / theme (user-app appearance) ──────
  static const String APP_CONFIG_GET    = "$BASE_URL/app-config";
  static const String APP_CONFIG_UPDATE = "$BASE_URL/admin/app-config";
  static const String GET_ALL_USER = "$BASE_URL/auth/all-users";
  static const String USER_STATUS_UPDATE = "$BASE_URL/auth/user-status";

  // ── Main Category ─────────────────────────────────
  static const String MAIN_ADD_CATEGORY = "$BASE_URL/categories/add";
  static const String MAIN_VIEW_CATEGORY = "$BASE_URL/admin/categories";
  static const String MAIN_EDIT_CATEGORY = "$BASE_URL/categories/edit";
  static const String MAIN_DELETE_CATEGORY = "$BASE_URL/categories/delete";

  // ── Sub Category ──────────────────────────────────
  static const String VIEW_SUBCATEGORIES = "$BASE_URL/admin/categories/subcategories";
  static const String ADD_SUBCATEGORY =
      "$BASE_URL/categories/subcategories/add";
  static const String EDIT_SUBCATEGORY =
      "$BASE_URL/categories/subcategories/edit";
  static const String DELETE_SUBCATEGORY =
      "$BASE_URL/categories/subcategories/delete";

  // ── District ──────────────────────────────────────
  static const String ADD_DISTRICT = "$BASE_URL/location/districts/add";
  static const String VIEW_DISTRICT = "$BASE_URL/location/districts";
  static const String DELETE_DISTRICT = "$BASE_URL/location/districts/delete";
  static const String UPDATE_DISTRICT = "$BASE_URL/location/districts/update";

  // ── City ──────────────────────────────────────────
  static const String ADD_CITY = "$BASE_URL/location/cities/add";
  static const String VIEW_CITY = "$BASE_URL/location/cities";
  static const String DELETE_CITY = "$BASE_URL/location/cities/delete";
  static const String UPDATE_CITY = "$BASE_URL/location/cities/update";

  // ── Products ──────────────────────────────────────
  static const String SAVE_PRODUCT = "$BASE_URL/products/insert";
  static const String SAVE_VARIANT = "$BASE_URL/products/variant";
  static const String SAVE_IMAGE = "$BASE_URL/products/upload-image";
  static const String UPDATE_IMAGE = "$BASE_URL/products/upload-image";
  static const String SAVE_PRODUCT_INFO = "$BASE_URL/products/info";
  static const String SAVE_PRODUCT_HIGHLIGHT = "$BASE_URL/products/highlight";
  static const String UPDATE_PRODUCT = "$BASE_URL/products/update";
  static const String UPDATE_STOCK = "$BASE_URL/products/update-stock";
  static const String UPDATE_PRODUCT_TYPE = "$BASE_URL/products/update-type";
  static const String VIEW_PRODUCT_TYPES = "$BASE_URL/product-types";
  static const String ADD_PRODUCT_TYPE = "$BASE_URL/product-types/add";
  static const String EDIT_PRODUCT_TYPE = "$BASE_URL/product-types/edit";
  static const String DELETE_PRODUCT_TYPE = "$BASE_URL/product-types/delete";
  static const String REORDER_PRODUCT_TYPES = "$BASE_URL/product-types/reorder";
  static const String VIEW_ALL_PRODUCTS = "$BASE_URL/products";
  static const String DELETE_PRODUCTS = "$BASE_URL/products/delete";

  // ── Banners ───────────────────────────────────────
  static const String ADD_BANNER = "$BASE_URL/banners/add";
  static const String EDIT_BANNER = "$BASE_URL/banners/edit";
  static const String TOGGLE_BANNER = "$BASE_URL/banners/toggle";
  static const String DELETE_BANNER = "$BASE_URL/banners/delete";
  static const String VIEW_BANNER = "$BASE_URL/admin/banners";

  // ── Coupons ───────────────────────────────────────
  static const String ADD_COUPON = "$BASE_URL/coupons/add";
  static const String EDIT_COUPON = "$BASE_URL/coupons/edit";
  static const String DELETE_COUPON = "$BASE_URL/coupons/delete";
  static const String VIEW_COUPON = "$BASE_URL/admin/coupons";

  // ── Refunds ────────────────────────────────────────
  static const String ADMIN_REFUNDS         = "$BASE_URL/admin/refunds";
  static const String ADMIN_REFUNDS_APPROVE = "$BASE_URL/admin/refunds/approve";
  static const String ADMIN_REFUNDS_REJECT  = "$BASE_URL/admin/refunds/reject";

  // ── Payouts ────────────────────────────────────────
  static const String ADMIN_PAYOUTS            = "$BASE_URL/admin/payouts";
  static const String ADMIN_PAYOUTS_PENDING    = "$BASE_URL/admin/payouts/pending-earnings";
  static const String ADMIN_PAYOUTS_CREATE     = "$BASE_URL/admin/payouts/create";
  static const String ADMIN_PAYOUTS_MARK_PAID  = "$BASE_URL/admin/payouts/mark-paid";

  // ── Low Stock ─────────────────────────────────────
  static const String ADMIN_LOW_STOCK = "$BASE_URL/admin/products/low-stock";

  // ── Orders ────────────────────────────────────────
  static String orderSettlement(int id) => "$BASE_URL/orders/$id/settlement";
  static const String GET_ALL_ORDER = "$BASE_URL/orders";
  static const String GET_ALL_ORDER_DASHBOARD = "$BASE_URL/orders/dashboard";
  static const String UPDATE_ORDER_STATUS = "$BASE_URL/orders/update-status";
  static const String SALES_REPORT = "$BASE_URL/orders/sales-report";
  static const String ASSIGN_ORDER = "$BASE_URL/orders/assign";
  static const String DELIVERY_ORDERS = "$BASE_URL/orders/delivery";

  // ── Help ──────────────────────────────────────────
  static const String GET_CALLING_NUMBER = "$BASE_URL/help/call";
  static const String UPDATE_CALLING_NUMBER = "$BASE_URL/help/call";

  static const String GET_WHATSAPP_NUMBER = "$BASE_URL/help/whatsapp";
  static const String UPDATE_WHATSAPP_NUMBER = "$BASE_URL/help/whatsapp";

  static const String GET_EMAIL = "$BASE_URL/help/email";
  static const String UPDATE_EMAIL = "$BASE_URL/help/email";

  // ── Settings ──────────────────────────────────────
  static const String GET_HANDLING_CHARGE =
      "$BASE_URL/settings/handling-charge";
  static const String UPDATE_HANDLING_CHARGE =
      "$BASE_URL/settings/handling-charge";

  static const String GET_MINIMUM_ORDER_AMOUT = "$BASE_URL/settings/min-order";
  static const String UPDATE_MINIMUM_ORDER_AMOUT =
      "$BASE_URL/settings/min-order";

  static const String FETCH_DELIVERY_TIME = "$BASE_URL/settings/delivery-time";
  static const String UPDATE_DELIVERY_TIME = "$BASE_URL/settings/delivery-time";

  static const String FETCH_DELIVERY_AMOUNT =
      "$BASE_URL/settings/delivery-charge";
  static const String UPDATE_DELIVERY_AMOUNT =
      "$BASE_URL/settings/delivery-charge";

  static const String GET_FREE_DELIVERY_AMOUNT =
      "$BASE_URL/settings/free-delivery";
  static const String UPDATE_FREE_DELIVERY_AMOUNT =
      "$BASE_URL/settings/free-delivery";

  // ── Home Tabs ──────────────────────────────────────
  static const String HOME_TABS_ALL    = "$BASE_URL/home-tabs/all";
  static const String HOME_TABS_ADD    = "$BASE_URL/home-tabs/add";
  static const String HOME_TABS_EDIT   = "$BASE_URL/home-tabs/edit";
  static const String HOME_TABS_DELETE = "$BASE_URL/home-tabs/delete";
  static const String HOME_TABS_TOGGLE = "$BASE_URL/home-tabs/toggle";
  static const String HOME_TABS_REORDER= "$BASE_URL/home-tabs/reorder";

  // ── Home Sections (per-tab storefront builder) ─────
  static const String HOME_SECTIONS        = "$BASE_URL/admin/home-sections";
  static const String HOME_SECTIONS_ADD    = "$BASE_URL/admin/home-sections/add";
  static const String HOME_SECTIONS_EDIT   = "$BASE_URL/admin/home-sections/edit";
  static const String HOME_SECTIONS_DELETE = "$BASE_URL/admin/home-sections/delete";
  static const String HOME_SECTIONS_TOGGLE = "$BASE_URL/admin/home-sections/toggle";
  static const String HOME_SECTIONS_REORDER= "$BASE_URL/admin/home-sections/reorder";

  // ── Vendors ────────────────────────────────────────
  static const String ADMIN_VENDORS        = "$BASE_URL/admin/vendors";
  static const String ADMIN_VENDORS_STATS  = "$BASE_URL/admin/vendors/stats";
  static const String ADMIN_VENDOR_APPROVE = "$BASE_URL/admin/vendors/approve";
  static const String ADMIN_VENDOR_REJECT  = "$BASE_URL/admin/vendors/reject";
  static const String ADMIN_VENDOR_SUSPEND = "$BASE_URL/admin/vendors/suspend";
  static const String ADMIN_VENDOR_DELETE  = "$BASE_URL/admin/vendors/delete";

  // ── Delivery Boys (platform pool) ──────────────────
  static const String ADMIN_DELIVERY_BOYS        = "$BASE_URL/admin/delivery-boys";
  static const String ADMIN_DELIVERY_BOYS_ADD    = "$BASE_URL/admin/delivery-boys/add";
  static const String ADMIN_DELIVERY_BOYS_EDIT   = "$BASE_URL/admin/delivery-boys/edit";
  static const String ADMIN_DELIVERY_BOYS_DELETE = "$BASE_URL/admin/delivery-boys/delete";

  // ── Subscription Plans ─────────────────────────────
  static const String ADMIN_PLANS        = "$BASE_URL/admin/subscription-plans";
  static const String ADMIN_PLANS_ADD    = "$BASE_URL/admin/subscription-plans/add";
  static const String ADMIN_PLANS_EDIT   = "$BASE_URL/admin/subscription-plans/edit";
  static const String ADMIN_PLANS_DELETE = "$BASE_URL/admin/subscription-plans/delete";
  static const String ADMIN_PLANS_TOGGLE = "$BASE_URL/admin/subscription-plans/toggle";
  static const String ADMIN_SUB_GRANT    = "$BASE_URL/admin/subscriptions/grant";

  // ── Pincodes ───────────────────────────────────────
  static const String ADMIN_PINCODES        = "$BASE_URL/admin/pincodes";
  static const String ADMIN_PINCODES_ADD    = "$BASE_URL/admin/pincodes/add";
  static const String ADMIN_PINCODES_BULK   = "$BASE_URL/admin/pincodes/add-bulk";
  static const String ADMIN_PINCODES_EDIT   = "$BASE_URL/admin/pincodes/edit";
  static const String ADMIN_PINCODES_TOGGLE = "$BASE_URL/admin/pincodes/toggle";
  static const String ADMIN_PINCODES_DELETE = "$BASE_URL/admin/pincodes/delete";

  // ── Image URL resolver ────────────────────────────
  /// Turns any image value from the API into a loadable absolute URL.
  /// - empty        → '' (callers show a placeholder)
  /// - full URL     → returned unchanged (backend already uses the right host)
  /// - relative path→ prefixed with BASE_IMAGE_URL (the /storage/ host)
  static String imageUrl(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '';
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return '$BASE_IMAGE_URL${s.startsWith('/') ? s.substring(1) : s}';
  }
}
