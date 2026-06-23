import 'package:get_storage/get_storage.dart';

class StorageService {
  static final _box = GetStorage();

  static const _keyToken  = 'vendor_token';
  static const _keyVendor = 'vendor_data';

  // Sync — no await needed anymore.
  static void saveSession(String token, Map<String, dynamic> vendor) {
    _box.write(_keyToken,  token);
    _box.write(_keyVendor, vendor);
  }

  static String? getToken() => _box.read<String>(_keyToken);

  static Map<String, dynamic>? getVendor() =>
      _box.read<Map<String, dynamic>>(_keyVendor);

  static bool isLoggedIn() {
    final t = getToken();
    return t != null && t.isNotEmpty;
  }

  static void clear() {
    _box.remove(_keyToken);
    _box.remove(_keyVendor);
  }
}

// Backward-compat alias
typedef SessionManager = StorageService;
