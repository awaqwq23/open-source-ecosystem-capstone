import 'sports_appointment_window.dart';
import 'sports_area_availability.dart';
import 'sports_venue.dart';
import 'sports_venue_availability.dart';

class SportsCheckoutArgs {
  const SportsCheckoutArgs({
    required this.appointmentDate,
    required this.availability,
    required this.area,
    required this.window,
  });

  final DateTime appointmentDate;
  final SportsVenueAvailability availability;
  final SportsAreaAvailability area;
  final SportsAppointmentWindow window;

  SportsVenue get venue => availability.venue;

  int get stadiumsAreaId => availability.stadiumsAreaId;

  int get stadiumsAreaNo => area.areaNo;

  String get sportsTypeTitle => availability.sportsTypeTitle;

  DateTime get dateOnly {
    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
    );
  }

  DateTime? get startsAt => _timeOnDate(dateOnly, window.startTime);

  DateTime? get endsAt {
    final start = startsAt;
    final end = _timeOnDate(dateOnly, window.endTime);
    if (start == null || end == null) {
      return end;
    }
    return end.isAfter(start) ? end : end.add(const Duration(days: 1));
  }

  Duration? get duration {
    final start = startsAt;
    final end = endsAt;
    if (start == null || end == null) {
      return null;
    }
    return end.difference(start);
  }

  bool get canStartCheckout => window.canReserve && isAreaReservable;

  bool get isAreaReservable {
    for (final areaWindow in area.windows) {
      if (areaWindow.canReserve && _sameWindow(areaWindow, window)) {
        return true;
      }
    }
    return false;
  }

  String get venueTitle => venue.title;

  String get areaLabel => '$stadiumsAreaNo号场';

  String get timeRangeLabel => '${window.startTime}-${window.endTime}';
}

DateTime? _timeOnDate(DateTime date, String value) {
  final parts = value.split(':');
  if (parts.length < 2) {
    return null;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return null;
  }
  return DateTime(date.year, date.month, date.day, hour, minute);
}

bool _sameWindow(SportsAppointmentWindow left, SportsAppointmentWindow right) {
  return left.startTime == right.startTime && left.endTime == right.endTime;
}
