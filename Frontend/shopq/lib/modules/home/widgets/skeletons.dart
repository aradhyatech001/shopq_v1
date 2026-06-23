import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable shimmer skeleton loaders for the user app.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Wraps [child] (built from [SkeletonBox]es) in the app's shimmer effect.
class Skeleton extends StatelessWidget {
  final Widget child;
  const Skeleton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  final double? width;
  const ProductCardSkeleton({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 12),
        ),
        SizedBox(height: 8.h),
        SkeletonBox(width: double.infinity, height: 10.h),
        SizedBox(height: 6.h),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.6,
          child: SkeletonBox(width: double.infinity, height: 10.h),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonBox(width: 34.w, height: 14.h),
            SkeletonBox(width: 34.w, height: 24.h, radius: 6),
          ],
        ),
      ],
    );
    return Skeleton(child: width == null ? col : SizedBox(width: width!.w, child: col));
  }
}

class HorizontalProductsSkeleton extends StatelessWidget {
  final int count;
  final bool withHeader;
  const HorizontalProductsSkeleton({super.key, this.count = 5, this.withHeader = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (withHeader)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
            child: const Skeleton(child: SkeletonBox(width: 140, height: 16)),
          ),
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: count,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (_, __) => const ProductCardSkeleton(width: 110),
          ),
        ),
      ],
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  final int count;
  final int crossAxisCount;
  const ProductGridSkeleton({super.key, this.count = 6, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const ProductCardSkeleton(),
    );
  }
}

class CategoryGridSkeleton extends StatelessWidget {
  final int count;
  final int crossAxisCount;
  const CategoryGridSkeleton({super.key, this.count = 8, this.crossAxisCount = 4});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.82,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 10.h,
        ),
        itemCount: count,
        itemBuilder: (_, __) => Column(
          children: [
            Expanded(child: SkeletonBox(width: double.infinity, height: 60.h, radius: 10)),
            SizedBox(height: 6.h),
            SkeletonBox(width: 48.w, height: 9.h),
          ],
        ),
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Skeleton(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: SkeletonBox(width: double.infinity, height: 140.h, radius: 16),
          ),
        ),
        SizedBox(height: 8.h),
        const CategoryGridSkeleton(count: 8),
        const HorizontalProductsSkeleton(),
        const HorizontalProductsSkeleton(),
      ],
    );
  }
}

class OrderListSkeleton extends StatelessWidget {
  final int count;
  const OrderListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => Skeleton(
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                SkeletonBox(width: 56.w, height: 56.w, radius: 10),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120.w, height: 12.h),
                      SizedBox(height: 8.h),
                      SkeletonBox(width: 80.w, height: 10.h),
                      SizedBox(height: 8.h),
                      SkeletonBox(width: 60.w, height: 10.h),
                    ],
                  ),
                ),
                SkeletonBox(width: 48.w, height: 22.h, radius: 20),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class ListRowsSkeleton extends StatelessWidget {
  final int count;
  const ListRowsSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => Skeleton(
        child: Row(children: [
          SkeletonBox(width: 64.w, height: 64.w, radius: 10),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 12.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: 140.w, height: 10.h),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          SkeletonBox(width: double.infinity, height: 260.h, radius: 16),
          SizedBox(height: 16.h),
          SkeletonBox(width: 220.w, height: 18.h),
          SizedBox(height: 10.h),
          SkeletonBox(width: 140.w, height: 14.h),
          SizedBox(height: 16.h),
          Row(children: [
            SkeletonBox(width: 70.w, height: 32.h, radius: 8),
            SizedBox(width: 10.w),
            SkeletonBox(width: 70.w, height: 32.h, radius: 8),
            SizedBox(width: 10.w),
            SkeletonBox(width: 70.w, height: 32.h, radius: 8),
          ]),
          SizedBox(height: 20.h),
          SkeletonBox(width: double.infinity, height: 12.h),
          SizedBox(height: 8.h),
          SkeletonBox(width: double.infinity, height: 12.h),
          SizedBox(height: 8.h),
          SkeletonBox(width: 200.w, height: 12.h),
          SizedBox(height: 24.h),
          SkeletonBox(width: double.infinity, height: 48.h, radius: 12),
        ],
      ),
    );
  }
}
