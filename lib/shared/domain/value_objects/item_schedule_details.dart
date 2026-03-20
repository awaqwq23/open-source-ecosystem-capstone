import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class ItemScheduleDetails {
  const ItemScheduleDetails({
    required this.range,
    required this.isAllDay,
  });

  final DateTimeRangeValue range;
  final bool isAllDay;

  ItemScheduleDetails copyWith({
    DateTimeRangeValue? range,
    bool? isAllDay,
  }) {
    return ItemScheduleDetails(
      range: range ?? this.range,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }
}
