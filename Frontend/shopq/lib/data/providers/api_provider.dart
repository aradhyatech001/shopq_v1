import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class ApiProvider {
  // ── Auth ──────────────────────────────────────────────────────
  Future<ApiResponse> login(String email, String password) =>
      ApiClient.post(ApiEndpoints.LOGIN, body: {'email': email, 'password': password});

  Future<ApiResponse> signup(Map<String, dynamic> data) =>
      ApiClient.post(ApiEndpoints.SIGNUP, body: data);

  Future<ApiResponse> logout() =>
      ApiClient.post(ApiEndpoints.LOGOUT, auth: true);

  // ── Products ──────────────────────────────────────────────────
  Future<ApiResponse> getProducts({int page = 1, int limit = 20}) =>
      ApiClient.get('${ApiEndpoints.VIEW_ALL_PRODUCTS}?page=$page&limit=$limit');

  Future<ApiResponse> getProductsByCategory(int categoryId) =>
      ApiClient.get('${ApiEndpoints.VIEW_ALL_PRODUCTS_BY_CATEGORY}?category_id=$categoryId');

  // ── Cart ──────────────────────────────────────────────────────
  Future<ApiResponse> getCart(String userId) =>
      ApiClient.get('${ApiEndpoints.GET_CART_ITEMS}?user_id=$userId');

  Future<ApiResponse> addToCart(Map<String, dynamic> body) =>
      ApiClient.post(ApiEndpoints.ADD_TO_CART, body: body, auth: true);

  Future<ApiResponse> removeFromCart(int cartId) =>
      ApiClient.get('${ApiEndpoints.REMOVE_CART_ITEM}?id=$cartId');

  Future<ApiResponse> updateQuantity(int cartId, int quantity) =>
      ApiClient.postJson(ApiEndpoints.UPDATE_QUANTITY, body: {'id': cartId, 'quantity': quantity}, auth: true);

  // ── Orders ────────────────────────────────────────────────────
  Future<ApiResponse> getOrders() =>
      ApiClient.post(ApiEndpoints.GET_ORDER_BY_USER, body: {}, auth: true);

  Future<ApiResponse> placeOrder(Map<String, dynamic> body) =>
      ApiClient.postJson(ApiEndpoints.PLACE_ORDER, body: body, auth: true);
}
