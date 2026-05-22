import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/luotopia_auth/data/luotopia_auth_repository.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';

final luotopiaAuthProvider =
    NotifierProvider<LuotopiaAuthNotifier, LuotopiaAuthState>(
  LuotopiaAuthNotifier.new,
);

class LuotopiaAuthNotifier extends Notifier<LuotopiaAuthState> {
  late final LuotopiaAuthRepository _repository;

  @override
  LuotopiaAuthState build() {
    _repository = LuotopiaAuthRepository();
    _restoreSession();
    return const LuotopiaAuthState();
  }

  Future<void> _restoreSession() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = _repository.readToken(prefs);
    if (token == null || token.isEmpty) {
      state = const LuotopiaAuthState();
      return;
    }

    // 优先使用缓存的用户信息
    final cachedUser = _repository.readUser(prefs);
    if (cachedUser != null) {
      state = LuotopiaAuthState(
        status: LuotopiaAuthStatus.authenticated,
        user: cachedUser,
        token: token,
      );
    }

    // 后台验证 token 有效性
    try {
      final user = await _repository.getMe(token);
      await _repository.writeUser(prefs, user);
      state = LuotopiaAuthState(
        status: LuotopiaAuthStatus.authenticated,
        user: user,
        token: token,
      );
    } catch (_) {
      // Token 失效，保持缓存状态，不主动登出
    }
  }

  Future<void> register({
    required String username,
    required String password,
    String? email,
  }) async {
    state = state.copyWith(status: LuotopiaAuthStatus.loading, errorMessage: null);
    try {
      final result = await _repository.register(
        username: username,
        password: password,
        email: email,
      );
      _onAuthSuccess(result.token, result.user);
    } catch (e) {
      state = state.copyWith(
        status: LuotopiaAuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: LuotopiaAuthStatus.loading, errorMessage: null);
    try {
      final result = await _repository.login(
        username: username,
        password: password,
      );
      _onAuthSuccess(result.token, result.user);
    } catch (e) {
      state = state.copyWith(
        status: LuotopiaAuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _onAuthSuccess(String token, LuotopiaUser user) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await Future.wait([
      _repository.writeToken(prefs, token),
      _repository.writeUser(prefs, user),
    ]);
    state = LuotopiaAuthState(
      status: LuotopiaAuthStatus.authenticated,
      user: user,
      token: token,
    );
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await _repository.clearToken(prefs);
    state = const LuotopiaAuthState();
  }
}
