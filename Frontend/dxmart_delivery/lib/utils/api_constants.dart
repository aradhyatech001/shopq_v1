class ApiConstants {
  static const String BASE_URL = "http://192.168.1.4:8000/api";
  static const String BASE_IMAGE_URL = "http://192.168.1.4:8000/storage/";

  static const String LOGIN          = "$BASE_URL/delivery/login";
  static const String LOGOUT         = "$BASE_URL/delivery/logout";
  static const String PROFILE        = "$BASE_URL/delivery/profile";
  static const String ORDERS         = "$BASE_URL/delivery/orders";
  static const String UPDATE_STATUS  = "$BASE_URL/delivery/orders/update-status";

  /// Resolves an image value into a loadable URL (backend usually returns a
  /// full URL already; a relative path gets the storage host prefixed).
  static String imageUrl(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '';
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return '$BASE_IMAGE_URL${s.startsWith('/') ? s.substring(1) : s}';
  }
}
