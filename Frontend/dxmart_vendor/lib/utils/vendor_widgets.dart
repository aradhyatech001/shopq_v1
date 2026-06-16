import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'order_status.dart';

/// Shared admin-panel-style building blocks for the rebuilt vendor app.
/// Every screen composes these so the look stays consistent on web & mobile.

// ─────────────────────────────────────────────────────────────────────────────
// Page scaffold — sticky header (title + subtitle + actions) over content.
// ─────────────────────────────────────────────────────────────────────────────
class VendorPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget child;

  const VendorPage({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 16.h),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: GoogleFonts.jost(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(subtitle!,
                            style: GoogleFonts.jost(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                if (actions != null)
                  Wrap(spacing: 6.w, crossAxisAlignment: WrapCrossAlignment.center, children: actions!),
              ],
            ),
          ),
          Expanded(child: child),
        ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// White rounded card.
// ─────────────────────────────────────────────────────────────────────────────
class VCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const VCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: card,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat tile (label, big value, icon).
// ─────────────────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return VCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 4.h),
          Text(value,
              style: GoogleFonts.jost(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          SizedBox(height: 2.h),
          Text(label,
              style: GoogleFonts.jost(
                  fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order/status helpers + chip.
// ─────────────────────────────────────────────────────────────────────────────
// Delegate to the canonical, app-wide status model so labels/colours match
// the user app, admin and backend exactly.
String prettyStatus(String raw) => OrderStatus.label(raw);

Color statusColor(String raw) => OrderStatus.color(raw);

class VStatusChip extends StatelessWidget {
  final String status;
  const VStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(prettyStatus(status),
          style: GoogleFonts.jost(
              fontSize: 11.sp, fontWeight: FontWeight.w700, color: c)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state.
// ─────────────────────────────────────────────────────────────────────────────
class VEmpty extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? hint;
  const VEmpty({super.key, required this.icon, required this.message, this.hint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54.sp, color: AppColors.hint),
          SizedBox(height: 12.h),
          Text(message,
              style: GoogleFonts.jost(
                  fontSize: 15.sp, color: AppColors.textSecondary)),
          if (hint != null) ...[
            SizedBox(height: 4.h),
            Text(hint!,
                style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.hint)),
          ],
        ],
      ),
    );
  }
}

/// Formats a number like 1287 → "1,287".
String money(num v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
