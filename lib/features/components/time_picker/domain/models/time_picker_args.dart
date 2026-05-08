enum TimePickerMode {
  day,
  week,
  month,
}

class TimePickerSelection {
  const TimePickerSelection({
    required this.mode,
    required this.anchor,
  });

  final TimePickerMode mode;
  final DateTime anchor;
}

class TimePickerArgs {
  const TimePickerArgs({
    required this.mode,
    this.initialDate,
  });

  final TimePickerMode mode;
  final DateTime? initialDate;
}
