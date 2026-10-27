import 'package:shared_preferences/shared_preferences.dart';

/// The single place the login token is read, saved and cleared.
///
/// Read from prefs every time (no in-memory copy) so the background
/// isolate always sees the token the UI isolate saved.
class TokenStore {
  const TokenStore._();

  static const String _key = 'auth_token';

  /// Older builds saved the token under these keys.
  static const List<String> _legacyKeys = ['token', 'access_token'];

  static Future<String> read() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final current = prefs.getString(_key);
    if (current != null && current.isNotEmpty) return current;
    for (final key in _legacyKeys) {
      final legacy = prefs.getString(key);
      if (legacy != null && legacy.isNotEmpty) return legacy;
    }
    return '';
  }

  static Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
    for (final key in _legacyKeys) {
      await prefs.remove(key);
    }
  }

  /// Drops the token and the logged-in flag; other preferences stay.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    for (final key in _legacyKeys) {
      await prefs.remove(key);
    }
    await prefs.setBool('isLoggedIn', false);
  }
}
