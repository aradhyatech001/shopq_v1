class ApiEndpoints {
  static const String BASE_URL       = "http://192.168.1.6:8000/api";
  static const String BASE_IMAGE_URL = "http://192.168.1.6:8000/storage/";
  // static const String BASE_URL       = "http://localhost:8000/api";
  // static const String BASE_IMAGE_URL = "http://localhost:8000/storage/";
  // static const String BASE_URL       = "https://shopq.solarsunshakti.com/api";
  // static const String BASE_IMAGE_URL = "https://shopq.solarsunshakti.com/storage/";

  // ── Vendor Auth ────────────────────────────────────
  static const String VENDOR_REGISTER       = "$BASE_URL/vendor/register";
  static const String VENDOR_LOGIN          = "$BASE_URL/vendor/login";
  static const String VENDOR_LOGOUT         = "$BASE_URL/vendor/logout";
  static const String VENDOR_FCM_TOKEN      = "$BASE_URL/vendor/fcm/token";
  static const String VENDOR_PROFILE        = "$BASE_URL/vendor/profile";
  static const String VENDOR_PROFILE_UPDATE   = "$BASE_URL/vendor/profile/update";
  static const String VENDOR_CHANGE_PASSWORD  = "$BASE_URL/vendor/change-password";

  // ── Subscription ───────────────────────────────────
  static const String SUBSCRIPTION_PLANS    = "$BASE_URL/subscription-plans";
  static const String VENDOR_SUBSCRIPTION   = "$BASE_URL/vendor/subscription";
  static const String VENDOR_SUBSCRIBE      = "$BASE_URL/vendor/subscribe";

  // ── Pincodes ───────────────────────────────────────
  static const String PINCODES_ALL          = "$BASE_URL/pincodes";
  static const String VENDOR_PINCODES       = "$BASE_URL/vendor/pincodes";
  static const String VENDOR_PINCODES_UPDATE= "$BASE_URL/vendor/pincodes/update";

  // ── Products ───────────────────────────────────────
  static const String VENDOR_PRODUCTS       = "$BASE_URL/vendor/products";
  static const String VENDOR_PRODUCT_SINGLE = "$BASE_URL/vendor/products/single";
  static const String VENDOR_PRODUCT_INSERT = "$BASE_URL/vendor/products/insert";
  static const String VENDOR_PRODUCT_UPDATE = "$BASE_URL/vendor/products/update";
  static const String VENDOR_PRODUCT_DELETE = "$BASE_URL/vendor/products/delete";
  static const String VENDOR_PRODUCT_IMAGE  = "$BASE_URL/vendor/products/upload-image";
  static const String VENDOR_PRODUCT_STOCK  = "$BASE_URL/vendor/products/update-stock";

  // ── Dashboard ──────────────────────────────────────
  static const String VENDOR_DASHBOARD           = "$BASE_URL/vendor/dashboard";
  static const String VENDOR_LOW_STOCK           = "$BASE_URL/vendor/products/low-stock";

  // ── Payouts ────────────────────────────────────────
  static const String VENDOR_PAYOUTS             = "$BASE_URL/vendor/payouts";

  // ── Orders ─────────────────────────────────────────
  static const String VENDOR_ORDERS               = "$BASE_URL/vendor/orders";
  static const String VENDOR_ORDER_UPDATE_STATUS  = "$BASE_URL/vendor/orders/update-status";
  static const String VENDOR_ORDER_ASSIGN_DELIVERY= "$BASE_URL/vendor/orders/assign-delivery";
  static const String VENDOR_DELIVERY_BOYS        = "$BASE_URL/vendor/delivery-boys";
  static const String VENDOR_DELIVERY_BOYS_MINE   = "$BASE_URL/vendor/delivery-boys/mine";
  static const String VENDOR_DELIVERY_BOYS_ADD    = "$BASE_URL/vendor/delivery-boys/add";
  static const String VENDOR_DELIVERY_BOYS_EDIT   = "$BASE_URL/vendor/delivery-boys/edit";
  static const String VENDOR_DELIVERY_BOYS_DELETE = "$BASE_URL/vendor/delivery-boys/delete";

  // ── Categories (for product form) ─────────────────
  static const String CATEGORIES            = "$BASE_URL/categories";
  static const String SUBCATEGORIES         = "$BASE_URL/categories/subcategories";
  static const String PRODUCT_TYPES         = "$BASE_URL/product-types";

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

// Backward-compat alias
typedef ApiConstants = ApiEndpoints;
