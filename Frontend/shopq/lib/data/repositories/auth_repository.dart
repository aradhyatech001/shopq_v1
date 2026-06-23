import 'dart:convert';
import '../providers/api_provider.dart';
import '../../core/storage/storage_service.dart';
import '../../data/models/user_model.dart';

class AuthRepository {
  final _provider = ApiProvider();

  Future<UserModel?> login(String email, String password) async {
    final res = await _provider.login(email, password);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final token = data['token']?.toString() ?? '';
        if (token.isNotEmpty) {
          StorageService.token = token;
          final user = data['user'] ?? {};
          StorageService.userId = user['id']?.toString() ?? '';
          StorageService.userName = user['name']?.toString() ?? '';
          StorageService.userEmail = user['email']?.toString() ?? '';
          return UserModel.fromJson(user);
        }
      }
    }
    return null;
  }

  Future<bool> logout() async {
    final res = await _provider.logout();
    StorageService.clearAuth();
    return res.statusCode == 200;
  }
}
