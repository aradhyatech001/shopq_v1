import 'package:get/get.dart';

import 'package:shopq_vendor/app/routes/app_routes.dart';
import 'package:shopq_vendor/modules/home/controllers/home_controller.dart';

/// Routes a notification payload to the right vendor screen. The vendor app is a
/// home shell with an IndexedStack, so most targets switch the bottom-nav tab
/// rather than pushing a new screen.
class DeepLinkRouter {
  // IndexedStack tab order in the home shell.
  static const int _tabDashboard = 0;
  static const int _tabProducts = 1;
  static const int _tabOrders = 2;

  static void open(Map<String, dynamic> data) {
    final link = data['deeplink']?.toString();
    final type = data['type']?.toString();

    if (link != null && link.startsWith('shopq://')) {
      switch (Uri.tryParse(link)?.host) {
        case 'order':
        case 'orders':
          _goTab(_tabOrders);
          return;
        case 'product':
        case 'products':
          _goTab(_tabProducts);
          return;
        case 'dashboard':
          _goTab(_tabDashboard);
          return;
        case 'settlement':
        case 'payout':
        case 'payouts':
          Get.toNamed(AppRoutes.payouts); // no tab — standalone screen
          return;
      }
    }

    // Fallback by notification type.
    switch (type) {
      case 'new_order':
      case 'order_cancelled':
      case 'order_update':
      case 'vendor_update':
        _goTab(_tabOrders);
        return;
      case 'stock_warning':
        _goTab(_tabProducts);
        return;
      case 'settlement_update':
        Get.toNamed(AppRoutes.payouts);
        return;
      default:
        _goTab(_tabDashboard);
    }
  }

  /// Switch the home shell's bottom-nav tab, popping any screen pushed on top
  /// (e.g. the notification center) so the tab is actually visible.
  static void _goTab(int index) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().navigateTo(index);
    }
    Get.until((r) => r.settings.name == AppRoutes.home || r.isFirst);
  }
}
