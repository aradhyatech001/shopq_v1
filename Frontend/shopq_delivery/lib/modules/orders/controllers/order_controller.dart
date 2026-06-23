import 'package:get/get.dart';
import '../../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final _repo = OrderRepository();
  final RxList orders = [].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders({String? status}) async {
    isLoading.value = true;
    try {
      final result = await _repo.getOrders(status: status == 'all' ? null : status);
      orders.assignAll(result);
    } catch (_) {
      orders.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    final success = await _repo.updateOrderStatus(orderId, status);
    if (success) loadOrders(status: selectedStatus.value);
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    loadOrders(status: status);
  }
}
