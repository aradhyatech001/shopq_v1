import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFFE8F0FE);
  static const Color accent = Color(0xFF00BFA5);

  // ── Backgrounds ────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);

  // ── Sidebar (dark nav — matches admin panel) ───────────────
  static const Color sidebarColor    = Color(0xFF1E2A3A);
  static const Color sidebarHover    = Color(0xFF2D3E50);
  static const Color sidebarSelected = Color(0xFF1A73E8);
  static const Color sidebarBorder   = Color(0xFF2D3E50);

  // ── Text ───────────────────────────────────────────────────
  static const Color textPrimary       = Color(0xFF1A202C);
  static const Color textSecondary     = Color(0xFF718096);
  static const Color hint              = Color(0xFFA0AEC0);
  static const Color hintTextColor     = Color(0xFFA0AEC0);
  static const Color sidebarTextColor  = Color(0xFFCBD5E0);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);

  // ── Border & Divider ───────────────────────────────────────
  static const Color borderColor  = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFF0F4F8);

  // ── Status ─────────────────────────────────────────────────
  static const Color error   = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFDD6B20);

  // ── Shadows ────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: const Color(0xFF1A73E8).withOpacity(0.18),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
