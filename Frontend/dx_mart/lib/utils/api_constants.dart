class ApiConstants {
  // ── HOW TO SET BASE_URL ───────────────────────────────────────────────────
  // Android Emulator  → http://10.0.2.2:8000/api
  // Physical device   → http://<YOUR_PC_WIFI_IP>:8000/api  (e.g. 192.168.1.5)
  // iOS Simulator     → http://localhost:8000/api  (works on iOS only)
  // Run: ipconfig (Windows) or ifconfig (Mac/Linux) to find your WiFi IP
  // ─────────────────────────────────────────────────────────────────────────
  static const String BASE_URL = "http://192.168.1.4:8000/api"; // Android emulator
  static const String BASE_IMAGE_URL = "http://192.168.1.4:8000/storage/";
  // static const String BASE_URL = "https://shopq.solarsunshakti.com/api"; // Android emulator
  // static const String BASE_IMAGE_URL = "https://shopq.solarsunshakti.com/storage/";
  // static const String BASE_URL = "http://localhost:8000/api"; // Android emulator
  // static const String BASE_IMAGE_URL = "http://localhost:8000/storage/";

  // ── Auth ──────────────────────────────────────────
  static const String SIGNUP = "$BASE_URL/auth/signup";
  static const String LOGIN = "$BASE_URL/auth/login";
  static const String LOGOUT = "$BASE_URL/auth/logout";
  static const String FORGET_PASSWORD = "$BASE_URL/auth/forgot-password";
  static const String OTP_VERIFY = "$BASE_URL/auth/verify-otp";
  static const String RESET_PASSWORD = "$BASE_URL/auth/reset-password";
  static const String GET_USER = "$BASE_URL/auth/user";
  static const String EDIT_PROFILE = "$BASE_URL/auth/edit-profile";

  // ── Admin ─────────────────────────────────────────
  static const String ADMIN_LOGIN = "$BASE_URL/admin/login";
  static const String GET_ALL_USERS = "$BASE_URL/auth/all-users";
  static const String USER_STATUS = "$BASE_URL/auth/user-status";

  // ── Categories ────────────────────────────────────
  static const String MAIN_VIEW_CATEGORY = "$BASE_URL/categories";
  static const String VIEW_SUBCATEGORIES = "$BASE_URL/categories/subcategories";
  static const String ADD_CATEGORY = "$BASE_URL/categories/add";
  static const String EDIT_CATEGORY = "$BASE_URL/categories/edit";
  static const String DELETE_CATEGORY = "$BASE_URL/categories/delete";
  static const String ADD_SUBCATEGORY =
      "$BASE_URL/categories/subcategories/add";
  static const String EDIT_SUBCATEGORY =
      "$BASE_URL/categories/subcategories/edit";
  static const String DELETE_SUBCATEGORY =
      "$BASE_URL/categories/subcategories/delete";

  // ── App config / theme (admin-controlled) ────────
  static const String APP_CONFIG = "$BASE_URL/app-config";

  // ── Admin-configured per-tab storefront layout ───
  static const String TAB_LAYOUT = "$BASE_URL/tab-layout";

  // ── Banners ───────────────────────────────────────
  static const String VIEW_SLIDER = "$BASE_URL/banners";
  static const String ADD_BANNER = "$BASE_URL/banners/add";
  static const String DELETE_BANNER = "$BASE_URL/banners/delete";

  // ── Products ──────────────────────────────────────
  static const String VIEW_ALL_PRODUCTS = "$BASE_URL/products";
  static const String VIEW_ALL_PRODUCTS_BY_CATEGORY =
      "$BASE_URL/products/by-category";
  static const String VIEW_PRODUCT_BY_TYPE = "$BASE_URL/products/by-type";
  static const String VIEW_PRODUCT_TYPES = "$BASE_URL/product-types";
  static const String HOME_TABS = "$BASE_URL/home-tabs";
  static const String SINGLE_PRODUCT = "$BASE_URL/products/single";
  static const String INSERT_PRODUCT = "$BASE_URL/products/insert";
  static const String UPDATE_PRODUCT = "$BASE_URL/products/update";
  static const String DELETE_PRODUCT = "$BASE_URL/products/delete";
  static const String UPDATE_STOCK = "$BASE_URL/products/update-stock";
  static const String UPDATE_TYPE = "$BASE_URL/products/update-type";
  static const String UPLOAD_PRODUCT_IMAGE = "$BASE_URL/products/upload-image";
  static const String SAVE_VARIANT = "$BASE_URL/products/variant";
  static const String SAVE_HIGHLIGHT = "$BASE_URL/products/highlight";
  static const String SAVE_INFO = "$BASE_URL/products/info";

  // ── Brand ─────────────────────────────────────────
  static const String VIEW_BRAND = "$BASE_URL/brand";

  // ── Cart ──────────────────────────────────────────
  static const String ADD_TO_CART = "$BASE_URL/cart/add";
  static const String GET_CART_ITEMS = "$BASE_URL/cart";
  static const String REMOVE_CART_ITEM = "$BASE_URL/cart/remove";
  static const String UPDATE_QUANTITY = "$BASE_URL/cart/update-quantity";

  // ── Wishlist ──────────────────────────────────────
  static const String ADD_TO_WISHLIST = "$BASE_URL/wishlist/add";
  static const String GET_WISHLIST = "$BASE_URL/wishlist";
  static const String CHECK_WISHLIST = "$BASE_URL/wishlist/check";
  static const String REMOVE_FROM_WISHLIST = "$BASE_URL/wishlist/remove";

  // ── Delivery Address ──────────────────────────────
  static const String ADD_ADDRESS = "$BASE_URL/address/add";
  static const String VIEW_ADDRESS = "$BASE_URL/address";
  static const String UPDATE_ADDRESS = "$BASE_URL/address/edit";
  static const String DELETE_ADDRESS = "$BASE_URL/address/delete";

  // ── Orders ────────────────────────────────────────
  static const String PLACE_ORDER = "$BASE_URL/orders/place";
  static const String GET_ORDER_BY_USER = "$BASE_URL/orders/by-user";
  static const String GET_ALL_ORDERS = "$BASE_URL/orders";
  static const String ORDER_DASHBOARD = "$BASE_URL/orders/dashboard";
  static const String UPDATE_ORDER_STATUS = "$BASE_URL/orders/update-status";
  static const String SALES_REPORT = "$BASE_URL/orders/sales-report";
  static const String ASSIGN_ORDER = "$BASE_URL/orders/assign";
  static const String DELIVERY_ORDERS = "$BASE_URL/orders/delivery";

  // ── Coupons ───────────────────────────────────────
  static const String VIEW_COUPON = "$BASE_URL/coupons";
  static const String VALIDATE_COUPON = "$BASE_URL/coupons/validate";
  static const String ADD_COUPON = "$BASE_URL/coupons/add";
  static const String DELETE_COUPON = "$BASE_URL/coupons/delete";

  // ── Settings ──────────────────────────────────────
  static const String FETCH_DELIVERY_AMOUNT =
      "$BASE_URL/settings/delivery-charge";
  static const String GET_FREE_DELIVERY_AMOUNT =
      "$BASE_URL/settings/free-delivery";
  static const String GET_HANDLING_CHARGE =
      "$BASE_URL/settings/handling-charge";
  static const String DELIVERY_TIME = "$BASE_URL/settings/delivery-time";
  static const String GET_MINIMUM_ORDER_AMOUT = "$BASE_URL/settings/min-order";

  // ── Help ──────────────────────────────────────────
  static const String GET_CALLING_NUMBER = "$BASE_URL/help/call";
  static const String GET_WHATSAPP_NUMBER = "$BASE_URL/help/whatsapp";
  static const String GET_EMAIL = "$BASE_URL/help/email";

  // ── Location (legacy district/city) ───────────────
  static const String VIEW_DISTRICT = "$BASE_URL/location/districts";
  static const String VIEW_CITY     = "$BASE_URL/location/cities";

  // ── Pincodes ──────────────────────────────────────
  static const String VIEW_PINCODES = "$BASE_URL/pincodes";
  static const String CHECK_PINCODE = "$BASE_URL/pincodes/check";
  static const String SET_PINCODE   = "$BASE_URL/auth/set-pincode";

  // ── Image URL resolver ────────────────────────────
  /// Turns any image value from the API into a loadable absolute URL.
  /// - empty        → '' (callers show a placeholder)
  /// - full URL     → returned unchanged (backend already uses the right host)
  /// - relative path→ prefixed with BASE_IMAGE_URL (the /storage/ host)
  /// Use this everywhere instead of manually concatenating BASE_IMAGE_URL,
  /// so a full URL is never double-prefixed.
  static String imageUrl(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '';
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return '$BASE_IMAGE_URL${s.startsWith('/') ? s.substring(1) : s}';
  }
}
