class SportsReservationException implements Exception {
  const SportsReservationException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class SportsReservationAuthException extends SportsReservationException {
  const SportsReservationAuthException(super.message, {super.cause});
}

class SportsReservationApiException extends SportsReservationException {
  const SportsReservationApiException(
    super.message, {
    this.statusCode,
    super.cause,
  });

  final int? statusCode;
}
