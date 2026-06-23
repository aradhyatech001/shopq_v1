import 'dart:convert';
import '../providers/api_provider.dart';
import '../models/product_model.dart';

class ProductRepository {
  final _provider = ApiProvider();

  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    final res = await _provider.getProducts(page: page, limit: limit);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List products = data['products'] ?? data ?? [];
      return products.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final res = await _provider.getProductsByCategory(categoryId);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List products = data['products'] ?? data ?? [];
      return products.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }
}
