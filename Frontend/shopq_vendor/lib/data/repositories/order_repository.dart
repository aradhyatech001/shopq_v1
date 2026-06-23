import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class OrderRepository {
  Future<List<dynamic>> getOrders() async {
    final res = await ApiClient.get(ApiEndpoints.VENDOR_ORDERS);
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return (data['orders'] as List?) ?? [];
    }
    return [];
  }

  Future<bool> updateStatus(dynamic orderId, String status) async {
    final res = await ApiClient.postJson(
      ApiEndpoints.VENDOR_ORDER_UPDATE_STATUS,
      body: {'vendor_order_id': orderId, 'status': status},
    );
    final data = res.data as Map<String, dynamic>;
    return data['success'] == true;
  }

  Future<bool> assignDelivery(dynamic orderId, int deliveryBoyId) async {
    final res = await ApiClient.postJson(
      ApiEndpoints.VENDOR_ORDER_ASSIGN_DELIVERY,
      body: {'vendor_order_id': orderId, 'delivery_boy_id': deliveryBoyId},
    );
    final data = res.data as Map<String, dynamic>;
    return data['success'] == true;
  }
}
