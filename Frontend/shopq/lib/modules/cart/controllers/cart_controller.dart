import 'package:get/get.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class CartController extends GetxController {
  final Map<String, Map<String, int>> _quantities = {};
  final Map<String, Map<String, int>> _ids = {};

  String _key(String productId, String variantId) => '$productId-$variantId';

  // ── Read ─────────────────────────────────────────────────────

  int getQuantity(String userId, String productId, String variantId) {
    if (userId.isEmpty) return 0;
    return _quantities[userId]?[_key(productId, variantId)] ?? 0;
  }

  int getCartId(String userId, String productId, String variantId) {
    if (userId.isEmpty) return 0;
    return _ids[userId]?[_key(productId, variantId)] ?? 0;
  }

  int getTotalCartItems(String userId) {
    if (userId.isEmpty) return 0;
    return _quantities[userId]?.values.fold(0, (sum, q) => sum! + q) ?? 0;
  }

  int getUniqueItemsCount(String userId) {
    if (userId.isEmpty) return 0;
    return _quantities[userId]?.length ?? 0;
  }

  bool isInCart(String userId, String productId, String variantId) {
    if (userId.isEmpty) return false;
    return (_quantities[userId]?[_key(productId, variantId)] ?? 0) > 0;
  }

  bool isCartEmpty(String userId) {
    if (userId.isEmpty) return true;
    return _quantities[userId]?.isEmpty ?? true;
  }

  int getProductTotalQuantity(String userId, String productId) {
    if (userId.isEmpty) return 0;
    return _quantities[userId]
            ?.entries
            .where((e) => e.key.startsWith('$productId-'))
            .fold(0, (sum, e) => sum! + e.value) ??
        0;
  }

  List<String> getProductIdsInCart(String userId) {
    if (userId.isEmpty) return [];
    final ids = <String>{};
    for (final k in (_quantities[userId]?.keys ?? <String>[])) {
      ids.add(k.split('-').first);
    }
    return ids.toList();
  }

  List<Map<String, dynamic>> getCartItemsAsList(String userId) {
    if (userId.isEmpty) return [];
    final items = <Map<String, dynamic>>[];
    _quantities[userId]?.forEach((k, qty) {
      final parts = k.split('-');
      if (parts.length >= 2) {
        items.add({
          'product_id': parts[0],
          'variant_id': parts[1],
          'quantity': qty,
          'cart_id': _ids[userId]?[k] ?? 0,
        });
      }
    });
    return items;
  }

  Map<String, Map<String, dynamic>> getCartItemsAsMap(String userId) {
    if (userId.isEmpty) return {};
    final map = <String, Map<String, dynamic>>{};
    _quantities[userId]?.forEach((k, qty) {
      final parts = k.split('-');
      if (parts.length >= 2) {
        map[k] = {
          'product_id': parts[0],
          'variant_id': parts[1],
          'quantity': qty,
          'cart_id': _ids[userId]?[k] ?? 0,
        };
      }
    });
    return map;
  }

  // ── Write ────────────────────────────────────────────────────

  void updateCartQuantities(
    String userId,
    String productId,
    String variantId,
    int quantity,
    int cartId,
  ) {
    if (userId.isEmpty) return;
    _quantities.putIfAbsent(userId, () => {});
    _ids.putIfAbsent(userId, () => {});
    final k = _key(productId, variantId);
    _quantities[userId]![k] = quantity;
    _ids[userId]![k] = cartId;
    update();
  }

  void removeCartItem(String userId, String productId, String variantId) {
    if (userId.isEmpty) return;
    final k = _key(productId, variantId);
    _quantities[userId]?.remove(k);
    _ids[userId]?.remove(k);
    update();
  }

  void clearCart(String userId) {
    if (userId.isEmpty) return;
    _quantities.remove(userId);
    _ids.remove(userId);
    update();
  }

  void clearAllCartData() {
    _quantities.clear();
    _ids.clear();
    update();
  }

  // kept for legacy call sites that pass userId
  void clearCartData(String userId) => clearCart(userId);

  // ── API refresh ──────────────────────────────────────────────

  Future<bool> refreshCartData(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final response = await ApiClient.instance
          .get('${ApiEndpoints.GET_CART_ITEMS}?user_id=$userId');
      if (response.statusCode != 200) return false;
      final data = response.data;
      if (data['success'] != true) return false;

      final List<dynamic> cartItems =
          data['cart'] ?? data['data'] ?? [];

      _quantities.remove(userId);
      _ids.remove(userId);
      _quantities[userId] = {};
      _ids[userId] = {};

      for (final item in cartItems) {
        final productId = item['product_id']?.toString() ?? '';
        final variantId = item['variant_id']?.toString() ?? '';
        final qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
        final cartId = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
        if (productId.isNotEmpty && variantId.isNotEmpty) {
          final k = _key(productId, variantId);
          _quantities[userId]![k] = qty;
          _ids[userId]![k] = cartId;
        }
      }
      update();
      return true;
    } catch (_) {
      return false;
    }
  }
}
