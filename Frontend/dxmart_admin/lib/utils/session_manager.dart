import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for session storage keys.
class SessionManager {
  static const _keySessionId = 'admin_session_id';
  static const _keyEmail = 'admin_email';
  static const _keyName = 'admin_name';
  static const _rememberMe = 'rememberMe';
  static const _savedEmail = 'savedEmail';
  static const _savedPassword = 'savedPassword';

  // ── Save session after login ──────────────────────────────
  static Future<void> saveSession({
    required String sessionId,
    required String email,
    String name = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySessionId, sessionId);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyName, name);
  }

  // ── Save "remember me" credentials ───────────────────────
  static Future<void> saveRememberMe(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMe, true);
    await prefs.setString(_savedEmail, email);
    await prefs.setString(_savedPassword, password);
  }

  static Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMe);
    await prefs.remove(_savedEmail);
    await prefs.remove(_savedPassword);
  }

  static Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberMe) ?? false;
    if (!remember) return {};
    return {
      'email': prefs.getString(_savedEmail),
      'password': prefs.getString(_savedPassword),
    };
  }

  // ── Read ─────────────────────────────────────────────────
  /// Returns true if a session_id is stored locally.
  /// Splash screen then validates it against /admin/me.
  static Future<bool> hasLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sid = prefs.getString(_keySessionId);
    return sid != null && sid.isNotEmpty;
  }

  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySessionId);
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? 'Admin';
  }

  // ── Logout ───────────────────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
  }
}
