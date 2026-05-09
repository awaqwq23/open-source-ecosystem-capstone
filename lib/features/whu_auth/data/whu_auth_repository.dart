import 'package:shared_preferences/shared_preferences.dart';

class WhuAuthRepository {
  static const _storageKey = 'whu.auth.cookieHeader';

  const WhuAuthRepository();

  String readCookie(SharedPreferences? prefs) {
    return prefs?.getString(_storageKey) ?? '';
  }

  Future<void> writeCookie(SharedPreferences? prefs, String cookie) async {
    await prefs?.setString(_storageKey, cookie);
  }

  Future<void> clearCookie(SharedPreferences? prefs) async {
    await prefs?.remove(_storageKey);
  }
}
