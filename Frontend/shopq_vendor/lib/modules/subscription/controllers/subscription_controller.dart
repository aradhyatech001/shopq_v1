import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class SubscriptionController extends GetxController {
  final RxList plans = [].obs;
  final RxMap currentSubscription = {}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscription();
  }

  Future<void> loadSubscription() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.VENDOR_SUBSCRIPTION);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        if (data['active'] != null) {
          currentSubscription.value = Map<String, dynamic>.from(data['active'] as Map);
        }
      }
      final pRes = await ApiClient.get(ApiEndpoints.SUBSCRIPTION_PLANS);
      final pData = pRes.data as Map<String, dynamic>;
      if (pData['success'] == true) {
        plans.value = pData['data'] ?? [];
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
