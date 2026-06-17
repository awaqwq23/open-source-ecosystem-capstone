class SportsAppointmentWindow {
  const SportsAppointmentWindow({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.canReserve,
    required this.durationMinutes,
  });

  final String title;
  final String startTime;
  final String endTime;
  final bool canReserve;
  final int durationMinutes;
}
