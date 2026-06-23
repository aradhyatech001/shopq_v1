import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class DashboardController extends GetxController {
  final RxMap stats = {}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.VENDOR_DASHBOARD);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        stats.value = Map<String, dynamic>.from(data['data'] ?? {});
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
