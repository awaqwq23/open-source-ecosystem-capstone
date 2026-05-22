import 'package:luotopia/shared/domain/value_objects/item_schedule_details.dart';

class ItemTaskDetails {
  const ItemTaskDetails({
    required this.schedule,
    required this.deadline,
    this.estimatedDuration = Duration.zero,
  });

  final ItemScheduleDetails schedule;
  final DateTime? deadline;
  final Duration estimatedDuration;

  ItemTaskDetails copyWith({
    ItemScheduleDetails? schedule,
    DateTime? deadline,
    bool clearDeadline = false,
    Duration? estimatedDuration,
  }) {
    return ItemTaskDetails(
      schedule: schedule ?? this.schedule,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }
}
