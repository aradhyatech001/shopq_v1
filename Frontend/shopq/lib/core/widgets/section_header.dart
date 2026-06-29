import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shopq/app/theme/app_colors.dart';

/// Reusable bold section heading shown above home sections (category grids,
/// product rows, shop grids). Keeps spacing consistent and tight so the title
/// sits close to the content below it.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? emoji;

  /// Optional trailing action (e.g. a "See all" button).
  final Widget? trailing;

  /// Override the default padding. Defaults to a tight header with no bottom
  /// gap so the following content starts right beneath it.
  final EdgeInsetsGeometry? padding;

  const SectionHeader(
    this.title, {
    super.key,
    this.emoji,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        (emoji != null && emoji!.isNotEmpty) ? '$title $emoji' : title;
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.jost(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
