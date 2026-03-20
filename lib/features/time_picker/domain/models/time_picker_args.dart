enum TimePickerMode {
  day,
  week,
  month,
}

class TimePickerArgs {
  const TimePickerArgs({
    required this.mode,
    this.initialDate,
  });

  final TimePickerMode mode;
  final DateTime? initialDate;
}
