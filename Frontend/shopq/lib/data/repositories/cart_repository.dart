import 'dart:convert';
import '../providers/api_provider.dart';
import '../models/cart_model.dart';

class CartRepository {
  final _provider = ApiProvider();

  Future<List<CartItemModel>> getCart(String userId) async {
    final res = await _provider.getCart(userId);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final List items = data['cart'] ?? [];
        return items.map((e) => CartItemModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<bool> addToCart(Map<String, dynamic> body) async {
    final res = await _provider.addToCart(body);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] == true;
    }
    return false;
  }

  Future<bool> removeFromCart(int cartId) async {
    final res = await _provider.removeFromCart(cartId);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] == true;
    }
    return false;
  }

  Future<bool> updateQuantity(int cartId, int quantity) async {
    final res = await _provider.updateQuantity(cartId, quantity);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] == true;
    }
    return false;
  }
}
