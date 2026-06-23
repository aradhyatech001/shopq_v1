import 'package:dio/dio.dart';

import '../network/api_endpoints.dart';
import '../network/api_client.dart';
import '../../app/theme/app_colors.dart';

/// Admin-controlled app configuration / theme.
///
/// Fetched once at startup from `GET /app-config`. Values are set by the admin
/// panel, so the whole user app's look & text is managed from there.
///
/// This is the canonical class in the new architecture. The old [AppConfig]
/// (utils/app_config.dart) and [FirebaseService] (firebase/firebase_service.dart)
/// both delegate to this class via typedefs for backward compatibility.
class AppConfigService {
  static Map<String, dynamic> _values = {};

  static String get appName      => str('app_name', 'ShopQ');
  static String get deliveryTime => str('delivery_time_text', '24 Min');
  static String get freeDelivery => str('free_delivery_text', '₹0 delivery fee');
  static String get searchHint   => str('search_hint', 'Search for "Milk"');
  static String get assurance1   => str('assurance_1', 'Lowest Prices');
  static String get assurance2   => str('assurance_2', 'Quality Checked');
  static String get assurance3   => str('assurance_3', 'Easy Returns');

  // Payment methods (admin-controlled). COD defaults on, online defaults off.
  static bool get codEnabled    => flag('payment_cod_enabled', true);
  static bool get onlineEnabled => flag('payment_online_enabled', false);

  // Banner appearance (admin-controlled, all optional).
  static double bannerHeight(double fallback) => num('banner_height', fallback);
  static double bannerRadius(double fallback) => num('banner_radius', fallback);
  static bool get bannerAutoplay              => flag('banner_autoplay', true);

  static double num(String key, double fallback) {
    final v = _values[key];
    if (v == null || '$v'.isEmpty) return fallback;
    return double.tryParse('$v') ?? fallback;
  }

  static String str(String key, [String fallback = '']) {
    final v = _values[key];
    return (v == null || '$v'.isEmpty) ? fallback : '$v';
  }

  static bool flag(String key, [bool fallback = false]) {
    final v = _values[key];
    if (v == null || '$v'.isEmpty) return fallback;
    final s = '$v'.toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  /// Loads the config and applies theme colors. Never throws.
  static Future<void> load() async {
    try {
      final res = await ApiClient.instance.get(
        ApiEndpoints.APP_CONFIG,
        options: Options(receiveTimeout: const Duration(seconds: 6)),
      );
      if (res.statusCode != 200) return;
      final data = res.data;
      if (data['success'] != true || data['config'] is! Map) return;
      _values = Map<String, dynamic>.from(data['config']);
      _applyTheme();
    } catch (_) {
      // keep defaults
    }
  }

  static void _applyTheme() {
    final p = AppColors.fromHex(str('primary_color'));
    final s = AppColors.fromHex(str('secondary_color'));
    if (p != null) AppColors.primaryColor = p;
    if (s != null) AppColors.secondaryColor = s;
  }
}

// Backward-compat typedef so existing code using AppConfig still compiles.
typedef AppConfig = AppConfigService;
