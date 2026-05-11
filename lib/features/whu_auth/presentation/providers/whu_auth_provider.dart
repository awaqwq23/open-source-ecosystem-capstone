import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/app_runtime_initializer.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/whu_auth/services/education_api_service.dart';
import 'package:luotopia/features/whu_auth/auth/whu_auth_repository.dart';
import 'package:luotopia/features/whu_auth/token/whu_education_client.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_state.dart';

final whuAuthProvider = NotifierProvider<WhuAuthNotifier, WhuAuthState>(
  WhuAuthNotifier.new,
);

/// 暴露当前 WhuEducationClient 供外界（ScorePage 等）消费。
/// 只读不建，不存在创建链，不会循环依赖。
final whuEducationClientProvider = Provider.autoDispose<WhuEducationClient?>((ref) {
  return ref.watch(whuAuthProvider.notifier).client;
});

/// 暴露当前 EducationApiService 供外界消费。
final educationApiServiceProvider = Provider.autoDispose<EducationApiService?>((ref) {
  return ref.watch(whuAuthProvider.notifier).apiService;
});

class WhuAuthNotifier extends Notifier<WhuAuthState> {
  late final WhuAuthRepository _repository;
  WhuEducationClient? _client;
  EducationApiService? _apiService;
  Timer? _healthCheckTimer;

  WhuEducationClient? get client => _client;
  EducationApiService? get apiService => _apiService;

  @override
  WhuAuthState build() {
    _repository = const WhuAuthRepository();
    ref.onDispose(() {
      _healthCheckTimer?.cancel();
      _client = null;
      _apiService = null;
    });

    final prefs = ref.read(sharedPreferencesProvider);
    final cookie = _repository.readCookie(prefs).trim();
    final studentId = _repository.readStudentId(prefs);
    final studentName = _repository.readStudentName(prefs);
    final college = _repository.readCollege(prefs);

    if (cookie.isNotEmpty) {
      _initClient(cookie);
      _startPeriodicHealthCheck();
      Future.microtask(() => _checkSessionHealth());
    }

    return WhuAuthState(
      cookieHeader: cookie,
      isLoading: false,
      studentId: studentId,
      studentName: studentName,
      college: college,
    );
  }

  void _initClient(String cookieHeader) {
    _client = WhuEducationClient(
      cookieHeader: cookieHeader,
      onCookiesUpdated: (newCookie) {
        Future.microtask(() => updateCookies(newCookie));
      },
    );
    _apiService = EducationApiService(
      client: _client!,
      hotUpdateService: ref.read(hotUpdateServiceProvider),
    );
  }

  EducationApiService _api() {
    if (_apiService == null) throw StateError('未登录武大教务');
    return _apiService!;
  }

  /// 完整的登录流程：设置 cookie → 教务 SSO 登录 → 拉取用户信息
  Future<void> login(String cookieHeader) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await _repository.writeCookie(prefs, cookieHeader);

      _initClient(cookieHeader);
      state = state.copyWith(cookieHeader: cookieHeader, errorMessage: null);

      await _client!.refreshSession();
      final info = await _api().getUserInfo();

      await _repository.writeUserInfo(
        prefs,
        studentId: info.studentId,
        studentName: info.name,
        college: info.college,
      );

      state = WhuAuthState(
        cookieHeader: cookieHeader,
        studentId: info.studentId,
        studentName: info.name,
        college: info.college,
        lastVerifiedAt: DateTime.now(),
        educationSessionState: EducationSessionState.valid,
      );
    } catch (e) {
      state = WhuAuthState(
        cookieHeader: cookieHeader,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// SSO 刷新后的状态同步
  Future<void> updateCookies(String newCookie) async {
    if (newCookie != state.cookieHeader) {
      final prefs = ref.read(sharedPreferencesProvider);
      await _repository.writeCookie(prefs, newCookie);
      state = WhuAuthState(
        cookieHeader: newCookie,
        studentId: state.studentId,
        studentName: state.studentName,
        college: state.college,
        lastVerifiedAt: DateTime.now(),
        educationSessionState: EducationSessionState.valid,
      );
      return;
    }
    state = state.copyWith(
      educationSessionState: EducationSessionState.valid,
      lastVerifiedAt: DateTime.now(),
    );
  }

  /// 后台检测教务会话健康状态
  Future<void> _checkSessionHealth() async {
    if (state.cookieHeader.isEmpty) return;
    try {
      final valid = await _api().isSessionValid();
      state = state.copyWith(
        educationSessionState:
            valid ? EducationSessionState.valid : EducationSessionState.expired,
        lastVerifiedAt: DateTime.now(),
        errorMessage: null,
      );
    } catch (_) {
      // 健康检查失败不中断用户体验
    }
  }

  /// 使用已有 Cookie 刷新教务会话（SSO 重新握手）
  Future<bool> refreshEducationSession() async {
    if (state.cookieHeader.isEmpty) return false;
    if (_client == null) return false;
    try {
      await _client!.refreshSession();
      state = state.copyWith(
        educationSessionState: EducationSessionState.valid,
        lastVerifiedAt: DateTime.now(),
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        educationSessionState: EducationSessionState.expired,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 退出登录（清除所有认证数据）
  Future<void> logout() async {
    _healthCheckTimer?.cancel();
    _client = null;
    _apiService = null;
    final prefs = ref.read(sharedPreferencesProvider);
    await _repository.clearAll(prefs);
    state = const WhuAuthState();
  }

  void _startPeriodicHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkSessionHealth(),
    );
  }
}
