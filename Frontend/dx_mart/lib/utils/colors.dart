import 'package:flutter/material.dart';

class AppColors {

  static const Color backgroundColor = Color(0xffFFFFFF);

  // primaryColor / secondaryColor are NOT const: they are overridden at startup
  // from the admin-controlled /app-config theme (see AppConfig.load()).
  static Color primaryColor = const Color(0xffF5BF14);
  static Color secondaryColor = const Color(0xffFFC63A);

  /// Parses "#RRGGBB" / "RRGGBB" / "#AARRGGBB" into a Color; null on failure.
  static Color? fromHex(String? hex) {
    if (hex == null) return null;
    var h = hex.trim().replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return null;
    final v = int.tryParse(h, radix: 16);
    return v == null ? null : Color(v);
  }

  static const Color primaryTextColor = Color(0xff000000);
  static const Color secondaryTextColor = Color(0xffFFFFFF);

  static const Color ratingColor = Color(0xffF5B30E);
  static const Color iconColor = Color(0xff000000);


  static const Color hintTextColor = Color(0xff4B4A4A);
  static const Color borderColor = Color(0xffFFE57B);
  static const Color gray = Color(0xffF8F4F4);

  static const Color searchBorderHome = Color(0xffC17F06);
  static const Color errorColor = Color(0xFFE53E3E); // Red for errors
  static const Color DisountPriceColor = Color(0xff7E7B7B); // Red for errors
  static const Color lineColor = Color(0xFFE0E0E0); // Light gray separator/line
  static const Color successColor = Color(0xFF38A169); // Green for success
  static const Color warningColor = Color(0xFFDD6B20); // Orange for warnings





}
