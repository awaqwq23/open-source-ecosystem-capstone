import 'sports_venue_availability.dart';

class SportsAppointmentListResult {
  const SportsAppointmentListResult({
    required this.advanceAppointmentDayCount,
    required this.advanceAppointmentStartTime,
    required this.items,
  });

  final int advanceAppointmentDayCount;
  final String advanceAppointmentStartTime;
  final List<SportsVenueAvailability> items;

  bool get hasReservableWindow => items.any((item) => item.hasReservableWindow);
}
