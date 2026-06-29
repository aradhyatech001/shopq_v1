import 'dart:convert';

import 'package:get_storage/get_storage.dart';

/// Tunable freshness windows (TTLs) per data type. Central place to balance
/// "fresh data" vs "fewer API calls".
class CacheTtl {
  static const Duration realtime = Duration(minutes: 1); // delivery time
  static const Duration products = Duration(minutes: 5); // tab layout, rows
  static const Duration banners = Duration(minutes: 15); // sliders, coupons
  static const Duration catalog = Duration(minutes: 30); // categories, tabs
}

/// Lightweight response cache for GET endpoints, backed by the same GetStorage
/// box used elsewhere (keys are prefixed so they never collide with auth/config
/// and can be cleared independently). Stores the parsed JSON plus a timestamp.
class CacheService {
  CacheService._();

  static final GetStorage _box = GetStorage();
  static const String _prefix = 'cache:';

  /// Persist [data] (a JSON-decoded Map/List) under [key] with the current time.
  static void write(String key, dynamic data) {
    try {
      _box.write('$_prefix$key', jsonEncode({
        'ts': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      }));
    } catch (_) {
      // Non-serialisable payloads are simply not cached.
    }
  }

  static Map<String, dynamic>? _entry(String key) {
    final raw = _box.read<String>('$_prefix$key');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// The cached payload for [key], or null if nothing is stored (regardless of
  /// freshness — useful for serving stale data when the network fails).
  static dynamic read(String key) => _entry(key)?['data'];

  /// Whether a cached entry exists and is younger than [ttl].
  static bool isFresh(String key, Duration ttl) {
    final entry = _entry(key);
    if (entry == null) return false;
    final ts = entry['ts'] as int? ?? 0;
    return DateTime.now().millisecondsSinceEpoch - ts < ttl.inMilliseconds;
  }

  static void invalidate(String key) => _box.remove('$_prefix$key');

  /// Drop every cached response (e.g. on logout or a hard reset).
  static void clear() {
    final keys = _box
        .getKeys()
        .where((k) => k.toString().startsWith(_prefix))
        .toList();
    for (final k in keys) {
      _box.remove(k);
    }
  }
}
