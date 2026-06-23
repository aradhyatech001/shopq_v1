import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class ProductController extends GetxController {
  final RxList products = [].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.VENDOR_PRODUCTS);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        products.value = data['products'] ?? [];
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
