import 'package:flutter/material.dart';

class AppColors {
  // These are mutable so admin can override them at runtime via AppConfig.
  static Color primaryColor = const Color(0xffFFC107);
  static Color secondaryColor = const Color(0xffFF9800);

  static Color get backgroundColor => const Color(0xffFFFFFF);
  static const Color primaryTextColor = Color(0xff212121);
  static Color get secondaryTextColor => const Color(0xff757575);
  static Color get ratingColor => const Color(0xffFFC107);
  static Color get iconColor => const Color(0xff212121);
  static Color get hintTextColor => const Color(0xff9E9E9E);
  static Color get borderColor => const Color(0xffE0E0E0);
  static Color get gray => const Color(0xffF5F5F5);
  static Color get searchBorderHome => const Color(0xff616161);
  static Color get errorColor => const Color(0xffF44336);
  static Color get DisountPriceColor => const Color(0xff9E9E9E);
  static Color get lineColor => const Color(0xffE0E0E0);
  static Color get successColor => const Color(0xff4CAF50);
  static Color get warningColor => const Color(0xffFF9800);

  /// Parse a hex color string like '#FF0000' or 'FF0000'.
  /// Returns null if the string is empty or invalid.
  static Color? fromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      final value = int.tryParse('FF$cleaned', radix: 16);
      return value != null ? Color(value) : null;
    }
    if (cleaned.length == 8) {
      final value = int.tryParse(cleaned, radix: 16);
      return value != null ? Color(value) : null;
    }
    return null;
  }
}
