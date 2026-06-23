import 'dart:typed_data';
import 'package:shopq_admin/CustomWidgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page shell — consistent header + content area used by every screen
// ─────────────────────────────────────────────────────────────────────────────
class AdminPageShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget child;

  const AdminPageShell({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top header bar ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: const BoxDecoration(
            color: AppColors.surfaceColor,
            border: Border(bottom: BorderSide(color: AppColors.borderColor)),
          ),
          child: Row(
            children: [
              // Title + subtitle — takes available space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.jost(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: GoogleFonts.jost(
                          fontSize: 11.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Actions — wrap so they don't overflow
              if (actions != null)
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4.w,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),

        // ── Content ─────────────────────────────────────────
        Expanded(child: child),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card  — white card with title inside a screen
// ─────────────────────────────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SectionCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 0),
              child: Row(
                mainAxisAlignment: trailing != null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: GoogleFonts.jost(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          Padding(
            padding:
                padding ??
                EdgeInsets.fromLTRB(
                  20.w,
                  title != null ? 14.h : 20.h,
                  20.w,
                  20.h,
                ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────
class AdminSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onClear;

  const AdminSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.jost(fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.jost(
            color: AppColors.hintTextColor,
            fontSize: 13.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 10.h,
            horizontal: 14.w,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.hintTextColor,
            size: 18.sp,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.hintTextColor,
                      size: 16.sp,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jost(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image picker tile
// ─────────────────────────────────────────────────────────────────────────────
class ImagePickerTile extends StatelessWidget {
  final Uint8List? bytes;
  final String? networkUrl;
  final VoidCallback onTap;
  final double height;

  const ImagePickerTile({
    super.key,
    this.bytes,
    this.networkUrl,
    required this.onTap,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: bytes != null || networkUrl != null
                ? AppColors.primaryColor.withValues(alpha: 0.4)
                : AppColors.borderColor,
            width: 1.5,
          ),
          color: AppColors.backgroundColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11.r),
          child: bytes != null
              ? Image.memory(bytes!, fit: BoxFit.cover)
              : networkUrl != null && networkUrl!.isNotEmpty
              ? AppNetworkImage(
                  networkUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.add_photo_alternate_outlined,
        size: 32,
        color: AppColors.hintTextColor,
      ),
      const SizedBox(height: 6),
      Text(
        'Tap to pick image',
        style: GoogleFonts.jost(color: AppColors.hintTextColor, fontSize: 12),
      ),
      Text(
        'Max 100 KB',
        style: GoogleFonts.jost(color: AppColors.hintTextColor, fontSize: 11),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirm delete dialog
// ─────────────────────────────────────────────────────────────────────────────
Future<bool> confirmDelete(
  BuildContext context, {
  String title = 'Delete',
  String message = 'This action cannot be undone.',
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            title,
            style: GoogleFonts.jost(
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.jost(
              color: AppColors.secondaryTextColor,
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.jost()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.jost(color: Colors.white),
              ),
            ),
          ],
        ),
      ) ??
      false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? hint;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56.sp, color: AppColors.hintTextColor),
          SizedBox(height: 12.h),
          Text(
            message,
            style: GoogleFonts.jost(
              fontSize: 16.sp,
              color: AppColors.secondaryTextColor,
            ),
          ),
          if (hint != null) ...[
            SizedBox(height: 4.h),
            Text(
              hint!,
              style: GoogleFonts.jost(
                fontSize: 12.sp,
                color: AppColors.hintTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Side sheet — a right-aligned full-height panel that replaces center dialogs.
// Use showAdminSideSheet(...) with an AdminSideSheet child.
// ─────────────────────────────────────────────────────────────────────────────
Future<T?> showAdminSideSheet<T>(
  BuildContext context, {
  required Widget child,
  double width = 460,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, _, __) {
      final screenW = MediaQuery.of(ctx).size.width;
      final w = screenW < width + 40 ? screenW : width;
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: AppColors.surfaceColor,
          elevation: 12,
          child: SizedBox(width: w, height: double.infinity, child: child),
        ),
      );
    },
    transitionBuilder: (ctx, anim, _, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

/// Standard layout for the content of a side sheet: sticky header with a close
/// button, a scrollable body, and an optional sticky footer of actions.
class AdminSideSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  // When set, the close (✕) calls this instead of popping a route — lets the
  // same widget be embedded inline as a split panel, not just as an overlay.
  final VoidCallback? onClose;

  const AdminSideSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 16.h),
          decoration: const BoxDecoration(
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
                            fontSize: 17.sp, fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(subtitle!,
                          style: GoogleFonts.jost(
                              fontSize: 11.sp,
                              color: AppColors.secondaryTextColor),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, size: 20.sp),
                color: AppColors.secondaryTextColor,
                onPressed: onClose ?? () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        // Body (scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: child,
          ),
        ),
        // Footer actions
        if (actions != null && actions!.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (int i = 0; i < actions!.length; i++) ...[
                  if (i > 0) SizedBox(width: 10.w),
                  actions![i],
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form label
// ─────────────────────────────────────────────────────────────────────────────
class FormLabel extends StatelessWidget {
  final String text;
  final bool required;

  const FormLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.jost(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          if (required)
            Text(
              ' *',
              style: GoogleFonts.jost(
                fontSize: 13.sp,
                color: AppColors.errorColor,
              ),
            ),
        ],
      ),
    );
  }
}
