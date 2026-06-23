import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>?> vendorData = Rx(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.VENDOR_PROFILE);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        vendorData.value = data['vendor'] as Map<String, dynamic>?;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() => Get.find<AuthController>().logout();
}
