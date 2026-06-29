import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shopq/app/theme/app_colors.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/core/widgets/app_network_image.dart';
import 'package:shopq/core/widgets/section_header.dart';

/// A home section that shows a titled grid of categories / sub-categories
/// (used by `category_grid` and `brand_grid`). Extracted as a common widget so
/// the layout — and the tight title-to-cards spacing — stays consistent
/// everywhere it's used.
class CategorySection extends StatelessWidget {
  final String title;
  final String? emoji;
  final List items;
  final void Function(Map item) onItemTap;
  final int crossAxisCount;

  const CategorySection({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    this.emoji,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) SectionHeader(title, emoji: emoji),
        // No SizedBox here — header has zero bottom padding and the grid zero
        // top padding, so the cards sit right under the title (no big gap).
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 2.h, 12.w, 0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.82,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 10.h,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) => CategoryTile(
              item: items[i] as Map,
              onTap: () => onItemTap(items[i] as Map),
            ),
          ),
        ),
      ],
    );
  }
}

/// A single category/sub-category cell: rounded image tile + centered label.
class CategoryTile extends StatelessWidget {
  final Map item;
  final VoidCallback onTap;

  const CategoryTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = item['image']?.toString() ?? '';
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: img.isEmpty
                  ? Icon(Icons.category_outlined,
                      color: AppColors.primaryColor, size: 22.sp)
                  : SizedBox.expand(
                      child: AppNetworkImage(ApiEndpoints.imageUrl(img),
                          fit: BoxFit.cover)),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            item['name']?.toString() ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jost(
                fontSize: 10.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
