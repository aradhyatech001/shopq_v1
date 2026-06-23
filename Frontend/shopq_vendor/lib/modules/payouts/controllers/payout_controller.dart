import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class PayoutController extends GetxController {
  final RxList payouts = [].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPayouts();
  }

  Future<void> loadPayouts() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.VENDOR_PAYOUTS);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        payouts.value = data['payouts'] ?? [];
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
