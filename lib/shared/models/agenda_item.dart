import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';

class AgendaItem {
  const AgendaItem({
    required this.id,
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
    required this.isCompleted,
    required this.isImportant,
    required this.createdAt,
    required this.completedAt,
    required this.manualOrder,
  });

  final String id;
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
  final bool isCompleted;
  final bool isImportant;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double manualOrder;

  AgendaItem copyWith({
    String? id,
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
    bool? isCompleted,
    bool? isImportant,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    double? manualOrder,
  }) {
    return AgendaItem(
      id: id ?? this.id,
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
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      manualOrder: manualOrder ?? this.manualOrder,
    );
  }

  ItemDraft toDraft() {
    return ItemDraft(
      type: type,
      title: title,
      details: details,
      location: location,
      color: color,
      isAllDay: isAllDay,
      reminder: reminder,
      repeatRule: repeatRule,
      startAt: startAt,
      endAt: endAt,
      deadline: deadline,
      targetDate: targetDate,
      estimatedDuration: estimatedDuration,
    );
  }

  static AgendaItem fromDraft({
    required String id,
    required ItemDraft draft,
    required DateTime createdAt,
    required double manualOrder,
    bool isCompleted = false,
    bool isImportant = false,
    DateTime? completedAt,
  }) {
    return AgendaItem(
      id: id,
      type: draft.type,
      title: draft.title.trim(),
      details: draft.details.trim(),
      location: draft.location.trim(),
      color: draft.color,
      isAllDay: draft.isAllDay,
      reminder: draft.reminder,
      repeatRule: draft.repeatRule,
      startAt: draft.startAt,
      endAt: draft.endAt,
      deadline: draft.deadline,
      targetDate: draft.targetDate,
      estimatedDuration: draft.estimatedDuration,
      isCompleted: isCompleted,
      isImportant: isImportant,
      createdAt: createdAt,
      completedAt: completedAt,
      manualOrder: manualOrder,
    );
  }
}
