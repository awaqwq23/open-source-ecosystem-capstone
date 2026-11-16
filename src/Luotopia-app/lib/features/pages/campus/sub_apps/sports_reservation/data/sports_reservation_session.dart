class SportsReservationSession {
  const SportsReservationSession({
    required this.jwt,
    required this.serviceUrl,
    required this.referer,
    this.userId = '',
    this.cookieHeader = '',
  });

  final String jwt;
  final Uri serviceUrl;
  final Uri referer;
  final String userId;
  final String cookieHeader;
}
