import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'colors.dart';

/// Admin-controlled app configuration / theme.
///
/// Fetched once at startup from `GET /app-config`. Values are set by the admin
/// panel, so the whole user app's look & text is managed from there.
class AppConfig {
  static Map<String, dynamic> _values = {};

  static String get appName        => str('app_name', 'DxMart');
  static String get deliveryTime   => str('delivery_time_text', '24 Min');
  static String get freeDelivery   => str('free_delivery_text', '₹0 delivery fee');
  static String get searchHint     => str('search_hint', 'Search for "Milk"');
  static String get assurance1     => str('assurance_1', 'Lowest Prices');
  static String get assurance2     => str('assurance_2', 'Quality Checked');
  static String get assurance3     => str('assurance_3', 'Easy Returns');

  // Payment methods (admin-controlled). COD defaults on, online defaults off.
  static bool get codEnabled    => flag('payment_cod_enabled', true);
  static bool get onlineEnabled => flag('payment_online_enabled', false);

  // Banner appearance (admin-controlled, all optional). When the admin hasn't
  // set a value the app keeps its built-in default (passed as the fallback).
  static double bannerHeight(double fallback) => num('banner_height', fallback);
  static double bannerRadius(double fallback) => num('banner_radius', fallback);
  static bool   get bannerAutoplay            => flag('banner_autoplay', true);

  /// Reads a numeric setting, returning [fallback] when unset/invalid.
  static double num(String key, double fallback) {
    final v = _values[key];
    if (v == null || '$v'.isEmpty) return fallback;
    return double.tryParse('$v') ?? fallback;
  }

  static String str(String key, [String fallback = '']) {
    final v = _values[key];
    return (v == null || '$v'.isEmpty) ? fallback : '$v';
  }

  /// Reads a boolean-ish setting. Treats '1'/'true' as true, '0'/'false' as
  /// false, and anything missing/empty as [fallback].
  static bool flag(String key, [bool fallback = false]) {
    final v = _values[key];
    if (v == null || '$v'.isEmpty) return fallback;
    final s = '$v'.toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  /// Loads the config and applies the theme colors. Never throws — on any
  /// failure the app keeps its built-in defaults.
  static Future<void> load() async {
    try {
      final res = await http
          .get(Uri.parse(ApiConstants.APP_CONFIG))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body);
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
