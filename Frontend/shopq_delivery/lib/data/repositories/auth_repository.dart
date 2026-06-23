import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/storage_service.dart';
import '../../core/services/notification_service.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String loginId, String password) async {
    final res = await ApiClient.postJson(
      ApiEndpoints.LOGIN,
      body: {'login': loginId, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await ApiClient.post(ApiEndpoints.LOGOUT, auth: true);
  }

  void saveSession(String token, Map<String, dynamic> rider) {
    StorageService.saveSession(token, rider);
    NotificationService.syncAfterLogin();
  }
}
