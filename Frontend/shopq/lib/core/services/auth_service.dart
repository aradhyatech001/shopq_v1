import '../storage/storage_service.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class AuthService {
  static bool get isLoggedIn => StorageService.isLoggedIn;

  static Future<bool> logout() async {
    try {
      await ApiClient.post(ApiEndpoints.LOGOUT, auth: true);
      StorageService.clearAuth();
      return true;
    } catch (_) {
      StorageService.clearAuth();
      return false;
    }
  }
}
