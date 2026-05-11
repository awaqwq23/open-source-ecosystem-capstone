enum WhuAuthStatus { unauthenticated, authenticated, loading }

class WhuAuthState {
  final WhuAuthStatus status;
  final String? studentId;
  final String? studentName;
  final String? sessionCookie;
  final String? errorMessage;

  const WhuAuthState({
    this.status = WhuAuthStatus.unauthenticated,
    this.studentId,
    this.studentName,
    this.sessionCookie,
    this.errorMessage,
  });

  bool get isAuthenticated => status == WhuAuthStatus.authenticated;

  WhuAuthState copyWith({
    WhuAuthStatus? status,
    String? studentId,
    String? studentName,
    String? sessionCookie,
    String? errorMessage,
  }) {
    return WhuAuthState(
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      sessionCookie: sessionCookie ?? this.sessionCookie,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
