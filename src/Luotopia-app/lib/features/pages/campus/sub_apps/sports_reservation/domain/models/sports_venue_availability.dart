import 'sports_appointment_window.dart';
import 'sports_charge_range.dart';
import 'sports_venue.dart';

class SportsVenueAvailability {
  const SportsVenueAvailability({
    required this.venue,
    required this.sportsTypeTitle,
    required this.stadiumsAreaId,
    required this.status,
    required this.chargeRange,
    required this.windows,
    required this.advanceAppointmentDayCount,
    required this.advanceAppointmentStartTime,
  });

  final SportsVenue venue;
  final String sportsTypeTitle;
  final int stadiumsAreaId;
  final int status;
  final SportsChargeRange chargeRange;
  final List<SportsAppointmentWindow> windows;
  final int advanceAppointmentDayCount;
  final String advanceAppointmentStartTime;

  bool get hasReservableWindow => windows.any((window) => window.canReserve);
}
