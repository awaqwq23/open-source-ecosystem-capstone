class WhuAuthState {
  final String cookieHeader;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastVerifiedAt;

  const WhuAuthState({
    this.cookieHeader = '',
    this.isLoading = false,
    this.errorMessage,
    this.lastVerifiedAt,
  });

  bool get isAuthenticated => cookieHeader.isNotEmpty;

  WhuAuthState copyWith({
    String? cookieHeader,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastVerifiedAt,
  }) {
    return WhuAuthState(
      cookieHeader: cookieHeader ?? this.cookieHeader,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }
}
