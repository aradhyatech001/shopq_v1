import 'dart:convert';
import '../providers/api_provider.dart';
import '../models/order_model.dart';

class OrderRepository {
  final _provider = ApiProvider();

  Future<List<OrderModel>> getOrders() async {
    final res = await _provider.getOrders();
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final List orders = data['orders'] ?? [];
        return orders.map((e) => OrderModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<bool> placeOrder(Map<String, dynamic> body) async {
    final res = await _provider.placeOrder(body);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] == true;
    }
    return false;
  }
}
