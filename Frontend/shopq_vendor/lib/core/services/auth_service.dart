import '../storage/storage_service.dart';

class AuthService {
  static bool isLoggedIn() => StorageService.isLoggedIn();
  static String? getToken() => StorageService.getToken();
  static Map<String, dynamic>? getVendor() => StorageService.getVendor();
  static void saveSession(String token, Map<String, dynamic> vendor) =>
      StorageService.saveSession(token, vendor);
  static void clearSession() => StorageService.clear();
}
