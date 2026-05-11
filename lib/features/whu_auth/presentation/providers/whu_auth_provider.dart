import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/app_runtime_initializer.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/whu_auth/data/education_api_service.dart';
import 'package:luotopia/features/whu_auth/data/whu_auth_repository.dart';
import 'package:luotopia/features/whu_auth/data/whu_education_client.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_state.dart';

final whuAuthProvider = NotifierProvider<WhuAuthNotifier, WhuAuthState>(
  WhuAuthNotifier.new,
);

/// 统一的武大教务 HTTP 客户端 Provider。
/// 随 cookieHeader 变化自动重建。
final whuEducationClientProvider = Provider.autoDispose<WhuEducationClient?>((ref) {
  final authState = ref.watch(whuAuthProvider.select((s) => s.cookieHeader));
  if (authState.isEmpty) return null;

  final notifier = ref.read(whuAuthProvider.notifier);

  return WhuEducationClient(
    cookieHeader: authState,
    onSessionExpired: () {
      Future.microtask(() => notifier.markSessionExpired());
    },
    refreshSession: () async {
      try {
        return await notifier.refreshEducationSession();
      } catch (_) {
        return false;
      }
    },
  );
});

/// 基于 WhuEducationClient 的教务 API 服务 Provider。
final educationApiServiceProvider = Provider.autoDispose<EducationApiService?>((ref) {
  final client = ref.watch(whuEducationClientProvider);
  if (client == null) return null;
  return EducationApiService(
    client: client,
    hotUpdateService: ref.watch(hotUpdateServiceProvider),
  );
});

class WhuAuthNotifier extends Notifier<WhuAuthState> {
  late final WhuAuthRepository _repository;
  Timer? _healthCheckTimer;

  @override
  WhuAuthState build() {
    _repository = const WhuAuthRepository();
    ref.onDispose(() => _healthCheckTimer?.cancel());
    _loadCached();
    return const WhuAuthState(isLoading: true);
  }

  EducationApiService _api() {
    final api = ref.read(educationApiServiceProvider);
    if (api == null) {
      throw StateError('未登录武大教务');
    }
    return api;
  }

  Future<void> _loadCached() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final cookie = _repository.readCookie(prefs).trim();
    final studentId = _repository.readStudentId(prefs);
    final studentName = _repository.readStudentName(prefs);
    final college = _repository.readCollege(prefs);

    state = WhuAuthState(
      cookieHeader: cookie,
      isLoading: false,
      studentId: studentId,
      studentName: studentName,
      college: college,
      educationSessionState:
          studentId.isNotEmpty
              ? EducationSessionState.valid
              : EducationSessionState.none,
    );

    if (cookie.isNotEmpty) {
      _startPeriodicHealthCheck();
      _checkSessionHealth();
    }
  }

  /// 完整的登录流程：设置 cookie → 教务登录 → 拉取用户信息
  Future<void> login(String cookieHeader) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await _repository.writeCookie(prefs, cookieHeader);

      state = state.copyWith(cookieHeader: cookieHeader, errorMessage: null);
      await _api().loginEducation();

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

  /// 重新登录（清除旧信息后触发登录流程）
  Future<void> reLogin() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await _repository.clearUserInfo(prefs);
    state = WhuAuthState(
      cookieHeader: state.cookieHeader,
      isLoading: false,
    );
    // 外部需要打开 WebView 重新获取 cookie 后调用 login()
  }

  /// 由 WhuEducationClient 回调调用，标记会话过期
  void markSessionExpired() {
    state = state.copyWith(
      educationSessionState: EducationSessionState.expired,
      errorMessage: '教务会话已过期，请刷新或重新登录。',
    );
  }

  /// 后台检测教务会话健康状态
  Future<void> _checkSessionHealth() async {
    if (state.cookieHeader.isEmpty) return;
    try {
      final valid = await _api().isSessionValid();
      if (valid && !state.isEducationSessionValid) {
        state = state.copyWith(
          educationSessionState: EducationSessionState.valid,
          lastVerifiedAt: DateTime.now(),
        );
      } else if (!valid && state.isEducationSessionValid) {
        state = state.copyWith(
          educationSessionState: EducationSessionState.expired,
          errorMessage: '教务会话已过期，请重新登录。',
        );
      }
    } catch (_) {
      // 健康检查失败不中断用户体验
    }
  }

  /// 使用已有 Cookie 刷新教务会话（SSO 重新握手）
  Future<bool> refreshEducationSession() async {
    if (state.cookieHeader.isEmpty) return false;
    try {
      await _api().loginEducation();
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
