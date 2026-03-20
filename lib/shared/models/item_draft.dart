import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';

class ItemDraft {
  const ItemDraft({
    required this.type,
    required this.title,
    required this.details,
    required this.location,
    required this.color,
    required this.isAllDay,
    required this.reminder,
    required this.repeatRule,
    required this.startAt,
    required this.endAt,
    required this.deadline,
    required this.targetDate,
    required this.estimatedDuration,
  });

  final ItemType type;
  final String title;
  final String details;
  final String location;
  final ItemColorOption color;
  final bool isAllDay;
  final ReminderOption reminder;
  final RepeatRule repeatRule;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? deadline;
  final DateTime targetDate;
  final Duration estimatedDuration;

  ItemDraft copyWith({
    ItemType? type,
    String? title,
    String? details,
    String? location,
    ItemColorOption? color,
    bool? isAllDay,
    ReminderOption? reminder,
    RepeatRule? repeatRule,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? deadline,
    bool clearDeadline = false,
    DateTime? targetDate,
    Duration? estimatedDuration,
  }) {
    return ItemDraft(
      type: type ?? this.type,
      title: title ?? this.title,
      details: details ?? this.details,
      location: location ?? this.location,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      reminder: reminder ?? this.reminder,
      repeatRule: repeatRule ?? this.repeatRule,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      targetDate: targetDate ?? this.targetDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }
}
