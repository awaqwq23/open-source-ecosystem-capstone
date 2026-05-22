import 'package:luotopia/features/luotopia_auth/data/luotopia_auth_repository.dart';

enum LuotopiaAuthStatus { unauthenticated, authenticated, loading }

class LuotopiaAuthState {
  final LuotopiaAuthStatus status;
  final LuotopiaUser? user;
  final String? token;
  final String? errorMessage;

  const LuotopiaAuthState({
    this.status = LuotopiaAuthStatus.unauthenticated,
    this.user,
    this.token,
    this.errorMessage,
  });

  bool get isAuthenticated => status == LuotopiaAuthStatus.authenticated;

  LuotopiaAuthState copyWith({
    LuotopiaAuthStatus? status,
    LuotopiaUser? user,
    String? token,
    String? errorMessage,
  }) {
    return LuotopiaAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
