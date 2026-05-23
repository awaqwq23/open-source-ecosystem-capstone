import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/luotopia_auth/data/luotopia_auth_repository.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';

final luotopiaAuthRepositoryProvider = Provider<LuotopiaAuthRepository>((ref) {
  return LuotopiaAuthRepository();
});

final luotopiaAuthProvider =
    NotifierProvider<LuotopiaAuthNotifier, LuotopiaAuthState>(
  LuotopiaAuthNotifier.new,
);

class LuotopiaAuthNotifier extends Notifier<LuotopiaAuthState> {
  late final LuotopiaAuthRepository _repository;

  @override
  LuotopiaAuthState build() {
    _repository = ref.read(luotopiaAuthRepositoryProvider);
    _restoreSession();
    return const LuotopiaAuthState();
  }

  Future<void> _restoreSession() async {
    final refreshToken = await _repository.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      state = const LuotopiaAuthState();
      return;
    }
    try {
      final result = await _repository.refresh(refreshToken);
      await _onAuthSuccess(result);
    } catch (_) {
      await _repository.clearTokens();
      state = const LuotopiaAuthState();
    }
  }

  Future<void> sendLoginCode({
    required String targetType,
    required String target,
  }) async {
    state = state.copyWith(status: LuotopiaAuthStatus.loading, clearMessages: true);
    try {
      await _repository.sendVerificationCode(
        targetType: targetType,
        target: target,
        purpose: 'login',
      );
      state = state.copyWith(
        status: LuotopiaAuthStatus.unauthenticated,
        noticeMessage: '验证码已发送',
      );
    } catch (error) {
      state = state.copyWith(
        status: LuotopiaAuthStatus.unauthenticated,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loginWithCode({
    required String targetType,
    required String target,
    required String code,
  }) async {
    state = state.copyWith(status: LuotopiaAuthStatus.loading, clearMessages: true);
    try {
      final result = await _repository.loginWithVerificationCode(
        targetType: targetType,
        target: target,
        code: code,
      );
      await _onAuthSuccess(result);
    } catch (error) {
      state = state.copyWith(
        status: LuotopiaAuthStatus.unauthenticated,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(status: LuotopiaAuthStatus.loading, clearMessages: true);
    try {
      final result = await _repository.loginWithPassword(
        identifier: identifier,
        password: password,
      );
      await _onAuthSuccess(result);
    } catch (error) {
      state = state.copyWith(
        status: LuotopiaAuthStatus.unauthenticated,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> setPassword(String password) async {
    final accessToken = state.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }
    state = state.copyWith(status: LuotopiaAuthStatus.loading, clearMessages: true);
    try {
      await _repository.setPassword(accessToken: accessToken, password: password);
      state = state.copyWith(
        status: LuotopiaAuthStatus.authenticated,
        noticeMessage: '密码已更新',
      );
    } catch (error) {
      state = state.copyWith(
        status: LuotopiaAuthStatus.authenticated,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> sendEmailBindCode(String email) async {
    final wasAuthenticated = state.isAuthenticated;
    state = state.copyWith(status: LuotopiaAuthStatus.loading, clearMessages: true);
    try {
      await _repository.sendVerificationCode(
        targetType: 'email',
        target: email,
        purpose: 'bind',
      );
      state = state.copyWith(
        status: LuotopiaAuthStatus.authenticated,
        noticeMessage: '邮箱验证码已发送',
      );
    } catch (error) {
      state = state.copyWith(
        status: wasAuthenticated
            ? LuotopiaAuthStatus.authenticated
            : LuotopiaAuthStatus.unauthenticated,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> bindEmail({required String email, required String code}) async {
    final accessToken = state.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }
    state = state.copyWith(status: LuotopiaAuthStatus.loading, clearMessages: true);
    try {
      await _repository.bindEmail(
        accessToken: accessToken,
        email: email,
        code: code,
      );
      state = state.copyWith(
        status: LuotopiaAuthStatus.authenticated,
        noticeMessage: '邮箱已绑定',
      );
    } catch (error) {
      state = state.copyWith(
        status: LuotopiaAuthStatus.authenticated,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> logout() async {
    final refreshToken = await _repository.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _repository.logout(refreshToken);
    }
    await _repository.clearTokens();
    state = const LuotopiaAuthState();
  }

  Future<void> logoutAll() async {
    final accessToken = state.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      await _repository.logoutAll(accessToken);
    }
    await _repository.clearTokens();
    state = const LuotopiaAuthState();
  }

  Future<void> _onAuthSuccess(LuotopiaAuthResult result) async {
    await _repository.saveRefreshToken(result.tokens.refreshToken);
    state = LuotopiaAuthState(
      status: LuotopiaAuthStatus.authenticated,
      user: result.user,
      accessToken: result.tokens.accessToken,
    );
  }
}
