import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class PincodeController extends GetxController {
  final RxList pincodes = [].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPincodes();
  }

  Future<void> loadPincodes() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.VENDOR_PINCODES);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        pincodes.value = data['selected_pincodes'] ?? [];
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
