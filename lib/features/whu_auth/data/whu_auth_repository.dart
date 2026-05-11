import 'package:shared_preferences/shared_preferences.dart';

class WhuAuthRepository {
  static const _cookieKey = 'whu_auth.session_cookie';
  static const _studentIdKey = 'whu_auth.student_id';
  static const _studentNameKey = 'whu_auth.student_name';

  String? readSessionCookie(SharedPreferences? prefs) =>
      prefs?.getString(_cookieKey);

  Future<void> writeSessionCookie(SharedPreferences? prefs, String cookie) async {
    await prefs?.setString(_cookieKey, cookie);
  }

  String? readStudentId(SharedPreferences? prefs) =>
      prefs?.getString(_studentIdKey);

  Future<void> writeStudentId(SharedPreferences? prefs, String id) async {
    await prefs?.setString(_studentIdKey, id);
  }

  String? readStudentName(SharedPreferences? prefs) =>
      prefs?.getString(_studentNameKey);

  Future<void> writeStudentName(SharedPreferences? prefs, String name) async {
    await prefs?.setString(_studentNameKey, name);
  }

  Future<void> clearAll(SharedPreferences? prefs) async {
    await Future.wait([
      if (prefs != null) ...[
        prefs.remove(_cookieKey),
        prefs.remove(_studentIdKey),
        prefs.remove(_studentNameKey),
      ],
    ]);
  }
}
