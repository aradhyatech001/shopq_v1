import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyToken = 'delivery_token';
  static const _keyRider = 'delivery_rider';

  static Future<void> saveSession(String token, Map<String, dynamic> rider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRider, jsonEncode(rider));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<Map<String, dynamic>?> getRider() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyRider);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRider);
  }
}
