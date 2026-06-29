import 'package:get_storage/get_storage.dart';

import 'cache_service.dart';

/// Synchronous key-value store backed by GetStorage.
class StorageService {
  static final _box = GetStorage();

  // ── Auth ────────────────────────────────────────────────────
  static String get token => _box.read<String>('auth_token') ?? '';
  static set token(String v) => _box.write('auth_token', v);

  static bool get isLoggedIn => token.isNotEmpty;

  // ── User info ────────────────────────────────────────────────
  static String get userId => _box.read<String>('user_id') ?? '';
  static set userId(String v) => _box.write('user_id', v);

  static String get userName => _box.read<String>('user_name') ?? '';
  static set userName(String v) => _box.write('user_name', v);

  static String get userEmail => _box.read<String>('user_email') ?? '';
  static set userEmail(String v) => _box.write('user_email', v);

  // ── Pincode / location ───────────────────────────────────────
  static int get pincodeId =>
      int.tryParse(_box.read<String>('pincode_id') ?? '') ?? 0;
  static set pincodeId(int v) => _box.write('pincode_id', v.toString());

  static String get pincodeCode => _box.read<String>('pincode_code') ?? '';
  static set pincodeCode(String v) => _box.write('pincode_code', v);

  /// Last FCM pincode-topic we subscribed to (so we can unsubscribe on change).
  static String get subscribedPincode =>
      _box.read<String>('subscribed_pincode') ?? '';
  static set subscribedPincode(String v) =>
      _box.write('subscribed_pincode', v);

  static String get pincodeAreaName =>
      _box.read<String>('pincode_area_name') ?? '';
  static set pincodeAreaName(String v) =>
      _box.write('pincode_area_name', v);

  static String get pincodeCity => _box.read<String>('pincode_city') ?? '';
  static set pincodeCity(String v) => _box.write('pincode_city', v);

  static String get pincodeState => _box.read<String>('pincode_state') ?? '';
  static set pincodeState(String v) => _box.write('pincode_state', v);

  // ── Selected delivery address ────────────────────────────────
  static String get selectedAddressId =>
      _box.read<String>('selected_address_id') ?? '';
  static set selectedAddressId(String v) =>
      _box.write('selected_address_id', v);

  static String get selectedAddressFull =>
      _box.read<String>('selected_address_full') ?? '';
  static set selectedAddressFull(String v) =>
      _box.write('selected_address_full', v);

  // ── Clear ────────────────────────────────────────────────────
  static void clearAuth() {
    _box.remove('auth_token');
    _box.remove('user_id');
    _box.remove('user_name');
    _box.remove('user_email');
    // Drop cached API responses so the next user never sees the previous
    // user's data. Covers every logout path (all route through clearAuth).
    CacheService.clear();
  }

  static void clearAll() => _box.erase();
}

// Backward-compatibility typedef
typedef AppStorage = StorageService;
