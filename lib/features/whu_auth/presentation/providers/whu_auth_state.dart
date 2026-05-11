enum EducationSessionState {
  /// 尚未进行教务登录
  none,

  /// 教务会话有效
  valid,

  /// 教务会话已过期
  expired,
}

class WhuAuthState {
  final String cookieHeader;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastVerifiedAt;
  final String studentId;
  final String studentName;
  final String college;
  final EducationSessionState educationSessionState;

  const WhuAuthState({
    this.cookieHeader = '',
    this.isLoading = false,
    this.errorMessage,
    this.lastVerifiedAt,
    this.studentId = '',
    this.studentName = '',
    this.college = '',
    this.educationSessionState = EducationSessionState.none,
  });

  bool get isAuthenticated => cookieHeader.isNotEmpty;

  bool get hasStudentInfo =>
      studentId.isNotEmpty && studentName.isNotEmpty;

  bool get isEducationSessionValid =>
      educationSessionState == EducationSessionState.valid;

  WhuAuthState copyWith({
    String? cookieHeader,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastVerifiedAt,
    String? studentId,
    String? studentName,
    String? college,
    EducationSessionState? educationSessionState,
  }) {
    return WhuAuthState(
      cookieHeader: cookieHeader ?? this.cookieHeader,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      college: college ?? this.college,
      educationSessionState: educationSessionState ?? this.educationSessionState,
    );
  }
}
