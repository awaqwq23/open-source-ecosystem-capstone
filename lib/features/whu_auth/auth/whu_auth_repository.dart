import 'package:shared_preferences/shared_preferences.dart';

class WhuAuthRepository {
  static const _cookieKey = 'whu.auth.cookieHeader';
  static const _studentIdKey = 'whu.auth.studentId';
  static const _studentNameKey = 'whu.auth.studentName';
  static const _collegeKey = 'whu.auth.college';

  const WhuAuthRepository();

  // -- Cookie -- //
  String readCookie(SharedPreferences? prefs) {
    return prefs?.getString(_cookieKey) ?? '';
  }

  Future<void> writeCookie(SharedPreferences? prefs, String cookie) async {
    await prefs?.setString(_cookieKey, cookie);
  }

  Future<void> clearCookie(SharedPreferences? prefs) async {
    await prefs?.remove(_cookieKey);
  }

  // -- 用户信息 -- //
  String readStudentId(SharedPreferences? prefs) {
    return prefs?.getString(_studentIdKey) ?? '';
  }

  String readStudentName(SharedPreferences? prefs) {
    return prefs?.getString(_studentNameKey) ?? '';
  }

  String readCollege(SharedPreferences? prefs) {
    return prefs?.getString(_collegeKey) ?? '';
  }

  Future<void> writeUserInfo(
    SharedPreferences? prefs, {
    required String studentId,
    required String studentName,
    required String college,
  }) async {
    await Future.wait([
      prefs?.setString(_studentIdKey, studentId) ?? Future.value(),
      prefs?.setString(_studentNameKey, studentName) ?? Future.value(),
      prefs?.setString(_collegeKey, college) ?? Future.value(),
    ]);
  }

  Future<void> clearUserInfo(SharedPreferences? prefs) async {
    await Future.wait([
      prefs?.remove(_studentIdKey) ?? Future.value(),
      prefs?.remove(_studentNameKey) ?? Future.value(),
      prefs?.remove(_collegeKey) ?? Future.value(),
    ]);
  }

  /// 清除所有 WHU 认证数据
  Future<void> clearAll(SharedPreferences? prefs) async {
    await Future.wait([
      clearCookie(prefs),
      clearUserInfo(prefs),
    ]);
  }
}
