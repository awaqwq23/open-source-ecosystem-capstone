import 'package:luotopia/shared/domain/value_objects/item_schedule_details.dart';

class ItemTaskDetails {
  const ItemTaskDetails({
    required this.schedule,
    required this.deadline,
  });

  final ItemScheduleDetails schedule;
  final DateTime? deadline;

  ItemTaskDetails copyWith({
    ItemScheduleDetails? schedule,
    DateTime? deadline,
    bool clearDeadline = false,
  }) {
    return ItemTaskDetails(
      schedule: schedule ?? this.schedule,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
    );
  }
}
