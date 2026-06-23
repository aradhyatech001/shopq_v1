import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiClient.postJson(
      ApiEndpoints.VENDOR_LOGIN,
      body: {'email': email, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await ApiClient.post(ApiEndpoints.VENDOR_LOGOUT);
  }
}
