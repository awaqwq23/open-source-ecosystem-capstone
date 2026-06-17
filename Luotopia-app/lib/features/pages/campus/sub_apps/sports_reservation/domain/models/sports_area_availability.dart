import 'sports_appointment_window.dart';

class SportsAreaAvailability {
  const SportsAreaAvailability({
    required this.id,
    required this.stadiumsAreaId,
    required this.areaNo,
    required this.status,
    required this.windows,
    this.capacity,
  });

  final int id;
  final int stadiumsAreaId;
  final int areaNo;
  final int? capacity;
  final int status;
  final List<SportsAppointmentWindow> windows;

  bool get hasReservableWindow => windows.any((window) => window.canReserve);
}
