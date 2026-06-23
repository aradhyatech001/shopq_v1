import 'package:get_storage/get_storage.dart';

class StorageService {
  static final _box = GetStorage();

  static const _keyToken = 'delivery_token';
  static const _keyRider = 'delivery_rider';

  // Sync — no await needed anymore.
  static void saveSession(String token, Map<String, dynamic> rider) {
    _box.write(_keyToken, token);
    _box.write(_keyRider, rider);
  }

  static String? getToken() => _box.read<String>(_keyToken);

  static Map<String, dynamic>? getRider() =>
      _box.read<Map<String, dynamic>>(_keyRider);

  static bool isLoggedIn() {
    final t = getToken();
    return t != null && t.isNotEmpty;
  }

  static void clear() {
    _box.remove(_keyToken);
    _box.remove(_keyRider);
  }
}

typedef SessionManager = StorageService;
