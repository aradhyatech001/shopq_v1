import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shopq/app/theme/app_colors.dart';
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
    // Load the list on open.
    WidgetsBinding.instance.addPostFrameCallback((_) => c.fetch());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primaryTextColor),
        title: Text('Notifications',
            style: GoogleFonts.jost(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor)),
        actions: [
          Obx(() => c.unread.value == 0
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: c.markAllRead,
                  child: Text('Mark all read',
                      style: GoogleFonts.jost(
                          fontSize: 12.sp, color: AppColors.primaryColor)),
                )),
        ],
      ),
      body: Obx(() {
        if (c.loading.value && c.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.items.isEmpty) return _empty();
        return RefreshIndicator(
          color: AppColors.primaryColor,
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
        color: AppColors.errorColor,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => c.delete(n.id),
      child: InkWell(
        onTap: () {
          c.clicked(n.id);
          DeepLinkRouter.open(n.data);
        },
        child: Container(
          color: n.isRead
              ? AppColors.backgroundColor
              : AppColors.primaryColor.withValues(alpha: 0.05),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(_iconFor(n.type),
                    color: AppColors.primaryColor, size: 19.sp),
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
                            color: AppColors.primaryTextColor)),
                    if (n.body.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(n.body,
                          style: GoogleFonts.jost(
                              fontSize: 12.sp,
                              color: AppColors.secondaryTextColor)),
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
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor, shape: BoxShape.circle),
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
                    fontSize: 15.sp, color: AppColors.secondaryTextColor)),
            SizedBox(height: 4.h),
            Text("We'll let you know when something arrives.",
                style: GoogleFonts.jost(
                    fontSize: 12.sp, color: AppColors.hintTextColor)),
          ],
        ),
      );

  IconData _iconFor(String type) {
    switch (type) {
      case 'order_update':
        return Icons.receipt_long_rounded;
      case 'payment_update':
      case 'wallet_update':
      case 'refund_update':
        return Icons.account_balance_wallet_rounded;
      case 'delivery_update':
        return Icons.local_shipping_rounded;
      case 'promo':
      case 'coupon':
      case 'flash_sale':
        return Icons.local_offer_rounded;
      case 'festival':
        return Icons.celebration_rounded;
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
