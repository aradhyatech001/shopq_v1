import 'dart:convert';

import 'package:get/get.dart';

import 'package:shopq/app/routes/app_routes.dart';
import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/modules/product/views/product_detail_screen.dart';
import 'package:shopq/modules/product/views/products_by_type_screen.dart';
import 'package:shopq/modules/category/views/category_view_screen.dart';

/// Routes a notification's data payload to the right in-app screen.
/// Deep links use the `shopq://<target>/<id?>` scheme, e.g.:
///   shopq://product/45 · shopq://category/9 · shopq://offers ·
///   shopq://deals · shopq://order/123
class DeepLinkRouter {
  static Future<void> open(Map<String, dynamic> data) async {
    final link = data['deeplink']?.toString();
    final type = data['type']?.toString();

    if (link != null && link.startsWith('shopq://')) {
      final uri = Uri.tryParse(link);
      final target = uri?.host;
      final id = (uri?.pathSegments.isNotEmpty ?? false)
          ? uri!.pathSegments.first
          : null;

      switch (target) {
        case 'product':
          await _openProduct(id);
          return;
        case 'product_type':
          if (id != null && id.isNotEmpty) {
            Get.to(() => ProductsByTypeScreen(type: id));
          } else {
            Get.toNamed(AppRoutes.home);
          }
          return;
        case 'category':
          final cid = int.tryParse(id ?? '');
          if (cid != null) {
            Get.to(() => CategoryViewScreen(
                  categoryId: cid,
                  categoryName: data['title']?.toString() ?? 'Category',
                ));
          } else {
            Get.toNamed(AppRoutes.category);
          }
          return;
        case 'order':
          Get.toNamed(AppRoutes.orders);
          return;
        case 'coupon':
        case 'offer':
        case 'offers':
        case 'special_offer':
          Get.toNamed(AppRoutes.coupon);
          return;
        case 'wishlist':
          Get.toNamed(AppRoutes.wishlist);
          return;
        case 'refund':
          Get.toNamed(AppRoutes.refunds);
          return;
        case 'deals':
        case 'discount':
        case 'products':
        case 'new':
          Get.toNamed(AppRoutes.home); // home feed shows new / discounted products
          return;
      }
    }

    // Fallback by notification type.
    switch (type) {
      case 'order_update':
      case 'delivery_update':
      case 'payment_update':
        Get.toNamed(AppRoutes.orders);
        return;
      case 'coupon':
      case 'promotional_offer':
        Get.toNamed(AppRoutes.coupon);
        return;
      case 'flash_sale':
        Get.toNamed(AppRoutes.home);
        return;
      default:
        Get.toNamed(AppRoutes.notifications);
    }
  }

  /// Loads the product by id, then opens its detail screen.
  static Future<void> _openProduct(String? id) async {
    final pid = int.tryParse(id ?? '');
    if (pid == null) {
      Get.toNamed(AppRoutes.home);
      return;
    }
    try {
      final res =
          await ApiClient.get('${ApiEndpoints.SINGLE_PRODUCT}?product_id=$pid');
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['product'] != null) {
        Get.to(() => ProductDetailsScreen(
            product: Map<String, dynamic>.from(data['product'])));
        return;
      }
    } catch (_) {}
    Get.toNamed(AppRoutes.home);
  }
}
