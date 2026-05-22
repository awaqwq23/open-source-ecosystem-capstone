import 'package:luotopia/features/whu_auth/domain/models/whu_account.dart';

enum WhuAuthStatus {
  unauthenticated,
  restoring,
  authenticated,
  loading,
}

class WhuAuthState {
  const WhuAuthState({
    this.status = WhuAuthStatus.unauthenticated,
    this.account,
    this.lastAuthenticatedAt,
    this.lastVerifiedAt,
    this.errorMessage,
  });

  final WhuAuthStatus status;
  final WhuAccount? account;
  final DateTime? lastAuthenticatedAt;
  final DateTime? lastVerifiedAt;
  final String? errorMessage;

  bool get isAuthenticated => status == WhuAuthStatus.authenticated;

  bool get isExpired {
    final authenticatedAt = lastAuthenticatedAt;
    if (authenticatedAt == null) {
      return true;
    }
    return DateTime.now().difference(authenticatedAt) > const Duration(days: 14);
  }

  WhuAuthState copyWith({
    WhuAuthStatus? status,
    WhuAccount? account,
    DateTime? lastAuthenticatedAt,
    DateTime? lastVerifiedAt,
    String? errorMessage,
    bool clearAccount = false,
    bool clearError = false,
  }) {
    return WhuAuthState(
      status: status ?? this.status,
      account: clearAccount ? null : account ?? this.account,
      lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
