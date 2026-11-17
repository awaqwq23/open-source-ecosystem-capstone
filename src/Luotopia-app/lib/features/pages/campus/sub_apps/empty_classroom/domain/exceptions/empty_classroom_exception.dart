enum EmptyClassroomExceptionCode {
  authExpired,
  networkFailure,
  serverRejected,
  invalidResponse,
}

class EmptyClassroomException implements Exception {
  const EmptyClassroomException(this.code, this.message);

  final EmptyClassroomExceptionCode code;
  final String message;

  @override
  String toString() => message;
}
