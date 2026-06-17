class SportsReservationQuery {
  const SportsReservationQuery({
    required this.sportsTypeId,
    required this.appointmentDate,
    this.venueId,
  });

  final int sportsTypeId;
  final int? venueId;
  final DateTime appointmentDate;

  SportsReservationQuery copyWith({
    int? sportsTypeId,
    int? venueId,
    DateTime? appointmentDate,
    bool clearVenue = false,
  }) {
    return SportsReservationQuery(
      sportsTypeId: sportsTypeId ?? this.sportsTypeId,
      venueId: clearVenue ? null : venueId ?? this.venueId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
    );
  }
}
