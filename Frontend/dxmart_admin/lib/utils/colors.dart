import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ──────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF1A73E8); // Vibrant blue
  static const Color primaryDark = Color(0xFF0D47A1); // Darker shade
  static const Color primaryLight = Color(0xFFE8F0FE); // Very light blue tint
  static const Color accentColor = Color(0xFF00BFA5); // Teal accent

  // ── Backgrounds ────────────────────────────────────────────
  static const Color backgroundColor = Color(0xFFF4F6FA); // Page bg
  static const Color surfaceColor = Color(0xFFFFFFFF); // Cards / panels
  static const Color sidebarColor = Color(0xFF1E2A3A); // Dark sidebar
  static const Color sidebarHover = Color(0xFF2D3E50); // Sidebar hover
  static const Color sidebarSelected = Color(0xFF1A73E8); // Selected item bg

  // ── Text ───────────────────────────────────────────────────
  static const Color primaryTextColor = Color(0xFF1A202C); // Near-black
  static const Color secondaryTextColor = Color(0xFF718096); // Medium grey
  static const Color hintTextColor = Color(0xFFA0AEC0); // Light grey
  static const Color sidebarTextColor = Color(0xFFCBD5E0); // Sidebar labels
  static const Color sidebarTextActive = Color(0xFFFFFFFF); // Active label

  // ── Border & Divider ───────────────────────────────────────
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFF0F4F8);

  // ── Status ─────────────────────────────────────────────────
  static const Color successColor = Color(0xFF38A169);
  static const Color successLight = Color(0xFFE6FFFA);
  static const Color warningColor = Color(0xFFDD6B20);
  static const Color warningLight = Color(0xFFFFF5EB);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFFF5F5);
  static const Color infoColor = Color(0xFF3182CE);
  static const Color infoLight = Color(0xFFEBF8FF);

  // ── Chart / Card accents ───────────────────────────────────
  static const Color cardBlue = Color(0xFF1A73E8);
  static const Color cardPurple = Color(0xFF7C3AED);
  static const Color cardOrange = Color(0xFFED8936);
  static const Color cardRed = Color(0xFFFC4444);
  static const Color cardGreen = Color(0xFF38A169);
  static const Color cardTeal = Color(0xFF00BFA5);

  // ── Shadow ─────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: const Color(0xFF1A73E8).withValues(alpha: 0.18),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
