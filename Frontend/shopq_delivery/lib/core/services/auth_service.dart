import '../storage/storage_service.dart';

class AuthService {
  static bool get isLoggedIn => StorageService.isLoggedIn();
}
