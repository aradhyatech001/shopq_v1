import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable "end of scroll" message card — drop it in as the last item of a
/// list / scroll view so the user gets a friendly prompt once they reach the
/// bottom (e.g. "Didn't find an item? Request a product").
///
/// Everything is configurable with sensible defaults, so the same widget can be
/// reused for other end-of-list messages (empty states, "you've reached the
/// end", promos, etc.).
///
/// Usage (CustomScrollView):
/// ```dart
/// SliverToBoxAdapter(
///   child: EndOfListMessage(onButtonTap: _openRequestProduct),
/// )
/// ```
/// Usage (ListView): add `EndOfListMessage(...)` as the last child.
class EndOfListMessage extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Action button label. Pass null / [onButtonTap] null to hide the button.
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  /// Custom illustration on the right. Falls back to [illustrationAsset], then
  /// to a built-in decorative icon.
  final Widget? illustration;
  final String? illustrationAsset;

  final Color accentColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry margin;

  const EndOfListMessage({
    super.key,
    this.title = "You've reached the end",
    this.subtitle = "No more items to show right now.",
    this.buttonLabel = 'Back to top',
    this.onButtonTap,
    this.illustration,
    this.illustrationAsset,
    this.accentColor = const Color(0xff5C6BC0),
    this.backgroundColor = const Color(0xffF4F4F6),
    this.margin = EdgeInsets.zero,
  });

  bool get _showButton => buttonLabel != null && onButtonTap != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      color: backgroundColor,
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 16.w, 28.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jost(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff1A1A1A),
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  subtitle,
                  style: GoogleFonts.jost(
                    fontSize: 13.sp,
                    color: const Color(0xff6B6B6B),
                    height: 1.35,
                  ),
                ),
                if (_showButton) ...[
                  SizedBox(height: 18.h),
                  _RequestButton(
                    label: buttonLabel!,
                    accentColor: accentColor,
                    onTap: onButtonTap!,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(flex: 2, child: _buildIllustration()),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    if (illustration != null) return illustration!;
    if (illustrationAsset != null && illustrationAsset!.isNotEmpty) {
      return Image.asset(illustrationAsset!,
          height: 110.h, fit: BoxFit.contain);
    }
    // Built-in decorative fallback so it still looks intentional without an asset.
    return Center(
      child: Container(
        height: 96.w,
        width: 96.w,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(Icons.check_circle_rounded,
            size: 46.sp, color: accentColor.withValues(alpha: 0.85)),
      ),
    );
  }
}

class _RequestButton extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _RequestButton({
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accentColor.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: accentColor.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            style: GoogleFonts.jost(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
