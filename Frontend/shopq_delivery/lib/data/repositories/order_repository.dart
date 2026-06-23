import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class OrderRepository {
  Future<List<dynamic>> getOrders({String? status}) async {
    final url = '${ApiEndpoints.ORDERS}${status != null ? "?status=$status" : ""}';
    final res = await ApiClient.get(url, auth: true);
    final data = res.data as Map<String, dynamic>;
    return data['orders'] as List? ?? [];
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final res = await ApiClient.post(
      ApiEndpoints.UPDATE_STATUS,
      body: {'vendor_order_id': orderId, 'status': status},
      auth: true,
    );
    final data = res.data as Map<String, dynamic>;
    return data['success'] == true;
  }
}
