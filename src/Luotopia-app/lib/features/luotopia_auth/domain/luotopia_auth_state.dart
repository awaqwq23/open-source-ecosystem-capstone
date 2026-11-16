import 'package:luotopia/features/luotopia_auth/data/luotopia_auth_repository.dart';

enum LuotopiaAuthStatus { unauthenticated, authenticated, loading }

class LuotopiaAuthState {
  const LuotopiaAuthState({
    this.status = LuotopiaAuthStatus.unauthenticated,
    this.user,
    this.accessToken,
    this.errorMessage,
    this.noticeMessage,
  });

  final LuotopiaAuthStatus status;
  final LuotopiaUser? user;
  final String? accessToken;
  final String? errorMessage;
  final String? noticeMessage;

  bool get isAuthenticated => status == LuotopiaAuthStatus.authenticated;

  LuotopiaAuthState copyWith({
    LuotopiaAuthStatus? status,
    LuotopiaUser? user,
    String? accessToken,
    String? errorMessage,
    String? noticeMessage,
    bool clearUser = false,
    bool clearAccessToken = false,
    bool clearMessages = false,
  }) {
    return LuotopiaAuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      accessToken: clearAccessToken ? null : accessToken ?? this.accessToken,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      noticeMessage: clearMessages ? null : noticeMessage ?? this.noticeMessage,
    );
  }
}
