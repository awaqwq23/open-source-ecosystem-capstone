import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/app_runtime_initializer.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/whu_auth/data/education_api_service.dart';
import 'package:luotopia/features/whu_auth/data/whu_auth_repository.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_state.dart';

final whuAuthProvider = NotifierProvider<WhuAuthNotifier, WhuAuthState>(
  WhuAuthNotifier.new,
);

class WhuAuthNotifier extends Notifier<WhuAuthState> {
  late final WhuAuthRepository _repository;
  late final EducationApiService _educationApi;

  @override
  WhuAuthState build() {
    _repository = const WhuAuthRepository();
    _educationApi = EducationApiService(
      hotUpdateService: ref.read(hotUpdateServiceProvider),
    );
    _loadCached();
    return const WhuAuthState(isLoading: true);
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

    // 如果有 cookie，后台检查会话健康状态
    if (cookie.isNotEmpty) {
      _checkSessionHealth();
    }
  }

  /// 完整的登录流程：设置 cookie → 教务登录 → 拉取用户信息
  Future<void> login(String cookieHeader) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await _repository.writeCookie(prefs, cookieHeader);

      // 1. 教务 SSO 登录
      state = state.copyWith(
        cookieHeader: cookieHeader,
        errorMessage: null,
      );
      await _educationApi.loginEducation(casCookieHeader: cookieHeader);

      // 2. 拉取用户信息
      final info = await _educationApi.getUserInfo(
        cookieHeader: cookieHeader,
      );

      // 3. 持久化用户信息
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
      // 即使教务登录失败，也保留 cookie（用户可能只是想存 cookie 后续使用）
      // 但不设置 studentInfo
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

  /// 后台检测教务会话健康状态
  Future<void> _checkSessionHealth() async {
    if (state.cookieHeader.isEmpty) {
      return;
    }
    final valid = await _educationApi.isSessionValid(
      cookieHeader: state.cookieHeader,
    );
    if (valid && !state.isEducationSessionValid) {
      // 如果实际有效但状态不对，尝试更新
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
  }

  /// 刷新教务会话（重新执行教务 SSO）
  Future<void> refreshEducationSession() async {
    if (state.cookieHeader.isEmpty) {
      return;
    }
    try {
      await _educationApi.loginEducation(
        casCookieHeader: state.cookieHeader,
      );
      state = state.copyWith(
        educationSessionState: EducationSessionState.valid,
        lastVerifiedAt: DateTime.now(),
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        educationSessionState: EducationSessionState.expired,
        errorMessage: e.toString(),
      );
    }
  }

  /// 退出登录（清除所有认证数据）
  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await _repository.clearAll(prefs);
    state = const WhuAuthState();
  }
}
