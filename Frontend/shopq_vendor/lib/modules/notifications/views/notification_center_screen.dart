import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shopq_vendor/app/theme/app_colors.dart';
import '../controllers/notification_controller.dart';
import '../models/app_notification.dart';
import '../utils/deeplink_router.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());
    WidgetsBinding.instance.addPostFrameCallback((_) => c.fetch());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text('Notifications',
            style: GoogleFonts.jost(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        actions: [
          Obx(() => c.unread.value == 0
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: c.markAllRead,
                  child: Text('Mark all read',
                      style: GoogleFonts.jost(
                          fontSize: 12.sp, color: AppColors.primary)),
                )),
        ],
      ),
      body: Obx(() {
        if (c.loading.value && c.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.items.isEmpty) return _empty();
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.fetch,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: c.items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColors.borderColor),
            itemBuilder: (_, i) => _tile(c, c.items[i]),
          ),
        );
      }),
    );
  }

  Widget _tile(NotificationController c, AppNotification n) {
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.archive_outlined, color: Colors.white),
      ),
      onDismissed: (_) => c.archive(n.id),
      child: InkWell(
        onTap: () {
          c.markRead(n.id);
          DeepLinkRouter.open(n.data);
        },
        child: Container(
          color: n.isRead
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.05),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(_iconFor(n.type),
                    color: AppColors.primary, size: 19.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title,
                        style: GoogleFonts.jost(
                            fontSize: 14.sp,
                            fontWeight:
                                n.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: AppColors.textPrimary)),
                    if (n.body.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(n.body,
                          style: GoogleFonts.jost(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary)),
                    ],
                    SizedBox(height: 4.h),
                    Text(_timeAgo(n.createdAt),
                        style: GoogleFonts.jost(
                            fontSize: 10.sp, color: AppColors.hintTextColor)),
                  ],
                ),
              ),
              if (!n.isRead)
                Container(
                  margin: EdgeInsets.only(top: 4.h, left: 6.w),
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 60.sp, color: AppColors.hintTextColor),
            SizedBox(height: 12.h),
            Text('No notifications yet',
                style: GoogleFonts.jost(
                    fontSize: 15.sp, color: AppColors.textSecondary)),
          ],
        ),
      );

  IconData _iconFor(String type) {
    switch (type) {
      case 'order_update':
      case 'new_order':
        return Icons.receipt_long_rounded;
      case 'settlement_update':
        return Icons.account_balance_wallet_rounded;
      case 'new_review':
        return Icons.star_rounded;
      case 'stock_warning':
        return Icons.inventory_2_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _timeAgo(DateTime? t) {
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}
