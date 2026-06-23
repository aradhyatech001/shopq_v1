import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class ProductRepository {
  Future<List<dynamic>> getProducts() async {
    final res = await ApiClient.get(ApiEndpoints.VENDOR_PRODUCTS);
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true) {
      return (data['products'] as List?) ?? [];
    }
    return [];
  }

  Future<bool> deleteProduct(int id) async {
    final res = await ApiClient.postJson(
      ApiEndpoints.VENDOR_PRODUCT_DELETE,
      body: {'id': id},
    );
    final data = res.data as Map<String, dynamic>;
    return data['success'] == true;
  }

  Future<bool> toggleStock(int id, bool currentlyActive) async {
    final res = await ApiClient.postJson(
      ApiEndpoints.VENDOR_PRODUCT_STOCK,
      body: {'product_id': id, 'is_active': currentlyActive ? 0 : 1},
    );
    final data = res.data as Map<String, dynamic>;
    return data['success'] == true;
  }
}
