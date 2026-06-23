import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class DeliveryController extends GetxController {
  final RxList deliveryBoys = [].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDeliveryBoys();
  }

  Future<void> loadDeliveryBoys() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.VENDOR_DELIVERY_BOYS_MINE);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        deliveryBoys.value = data['data'] ?? [];
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
