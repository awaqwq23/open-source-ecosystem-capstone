import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/whu_auth/data/whu_auth_repository.dart';
import 'package:luotopia/features/whu_auth/domain/whu_auth_state.dart';

final whuAuthProvider =
    NotifierProvider<WhuAuthNotifier, WhuAuthState>(WhuAuthNotifier.new);

class WhuAuthNotifier extends Notifier<WhuAuthState> {
  late final WhuAuthRepository _repository;

  @override
  WhuAuthState build() {
    _repository = WhuAuthRepository();
    _restoreSession();
    return const WhuAuthState();
  }

  void _restoreSession() {
    final prefs = ref.read(sharedPreferencesProvider);
    final cookie = prefs != null ? _repository.readSessionCookie(prefs) : null;
    final sid = prefs != null ? _repository.readStudentId(prefs) : null;
    final name = prefs != null ? _repository.readStudentName(prefs) : null;
    if (cookie != null && cookie.isNotEmpty) {
      state = WhuAuthState(
        status: WhuAuthStatus.authenticated,
        studentId: sid,
        studentName: name,
        sessionCookie: cookie,
      );
    }
  }

  Future<void> onLoginSuccess({
    required String sessionCookie,
    required String studentId,
    required String studentName,
  }) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs != null) {
      await Future.wait([
        _repository.writeSessionCookie(prefs, sessionCookie),
        _repository.writeStudentId(prefs, studentId),
        _repository.writeStudentName(prefs, studentName),
      ]);
    }
    state = WhuAuthState(
      status: WhuAuthStatus.authenticated,
      studentId: studentId,
      studentName: studentName,
      sessionCookie: sessionCookie,
    );
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs != null) {
      await _repository.clearAll(prefs);
    }
    state = const WhuAuthState();
  }

  Future<http.Response> fastLogin(String serviceUrl) async {
    final cookie = state.sessionCookie;
    if (cookie == null || cookie.isEmpty) {
      throw Exception('未登录武大教务账户，请先登录。');
    }
    return http.get(
      Uri.parse(
        'https://cas.whu.edu.cn/authserver/login?service=${Uri.encodeComponent(serviceUrl)}',
      ),
      headers: {'Cookie': cookie},
    );
  }
}

/// 携带 CAS cookie 的通用 HTTP 客户端。
/// 消费者可使用此客户端对任意 WHU 服务发起已验证的请求。
class WhuSessionClient {
  WhuSessionClient({required this.sessionCookie});
  final String sessionCookie;

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? body,
    Map<String, String>? headers,
  }) async {
    final allHeaders = <String, String>{
      'Cookie': sessionCookie,
      if (headers != null) ...headers,
    };
    return http.post(url, headers: allHeaders, body: body);
  }

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final allHeaders = <String, String>{
      'Cookie': sessionCookie,
      if (headers != null) ...headers,
    };
    return http.get(url, headers: allHeaders);
  }

  /// 生成 JWGL 接口所需的反缓存 validate 参数。
  static String generateValidate() {
    final random = Random();
    return 'sl${random.nextInt(1000000000).toRadixString(36)}${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
  }
}

final whuSessionClientProvider = Provider<WhuSessionClient?>((ref) {
  final state = ref.watch(whuAuthProvider);
  final cookie = state.sessionCookie;
  if (cookie == null || cookie.isEmpty) return null;
  return WhuSessionClient(sessionCookie: cookie);
});
