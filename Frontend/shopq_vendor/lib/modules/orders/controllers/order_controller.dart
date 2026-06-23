import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class OrderController extends GetxController {
  final RxList orders = [].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.VENDOR_ORDERS);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        orders.value = data['orders'] ?? [];
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await ApiClient.postJson(
        ApiEndpoints.VENDOR_ORDER_UPDATE_STATUS,
        body: {'vendor_order_id': orderId, 'status': status},
      );
      await loadOrders();
    } catch (_) {}
  }
}
