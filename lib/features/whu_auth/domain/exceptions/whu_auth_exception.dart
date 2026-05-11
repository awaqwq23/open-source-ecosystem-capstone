enum WhuAuthExceptionCode {
  loginRequired,
  serviceLoginFailed,
  networkFailure,
  invalidResponse,
  storageFailure,
}

class WhuAuthException implements Exception {
  const WhuAuthException(this.code, this.message);

  final WhuAuthExceptionCode code;
  final String message;

  @override
  String toString() => message;
}
