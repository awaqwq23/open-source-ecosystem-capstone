import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_memo_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_schedule_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_task_details.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';

class AgendaItemStorageMapper {
  const AgendaItemStorageMapper._();

  static Map<String, dynamic> toJson(AgendaItem item) {
    return {
      'id': item.id,
      'type': item.type.name,
      'title': item.title,
      'details': item.details,
      'location': item.location,
      'color': item.color.name,
      'reminder': item.reminder.name,
      'repeatRule': item.repeatRule.name,
      'scheduleDetails': _scheduleToJson(item.scheduleDetails),
      'taskDetails': _taskToJson(item.taskDetails),
      'memoDetails': _memoToJson(item.memoDetails),
      'isCompleted': item.isCompleted,
      'isImportant': item.isImportant,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt?.toIso8601String(),
      'completedAt': item.completedAt?.toIso8601String(),
      'manualOrder': item.manualOrder,
      'syncState': item.syncState.name,
      'sourceId': item.sourceId,
    };
  }

  static AgendaItem? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final title = json['title'] as String?;
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (id == null || id.isEmpty || title == null || createdAt == null) {
      return null;
    }

    final scheduleDetails = _scheduleFromJson(json['scheduleDetails']);
    final taskDetails = _taskFromJson(json['taskDetails']);
    final memoDetails = _memoFromJson(json['memoDetails']);
    if (scheduleDetails == null || taskDetails == null || memoDetails == null) {
      return null;
    }

    return AgendaItem(
      id: id,
      type: _enumByName(ItemType.values, json['type'] as String?) ?? ItemType.task,
      title: title,
      details: json['details'] as String? ?? '',
      location: json['location'] as String? ?? '',
      color: _enumByName(ItemColorOption.values, json['color'] as String?) ??
          ItemColorOption.sky,
      reminder: _enumByName(ReminderOption.values, json['reminder'] as String?) ??
          ReminderOption.none,
      repeatRule: _enumByName(RepeatRule.values, json['repeatRule'] as String?) ??
          RepeatRule.none,
      scheduleDetails: scheduleDetails,
      taskDetails: taskDetails,
      memoDetails: memoDetails,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      manualOrder: (json['manualOrder'] as num?)?.toDouble() ?? 0,
      syncState: _enumByName(
            AgendaItemSyncState.values,
            json['syncState'] as String?,
          ) ??
          AgendaItemSyncState.localOnly,
      sourceId: json['sourceId'] as String?,
    );
  }

  static Map<String, dynamic> _scheduleToJson(ItemScheduleDetails details) {
    return {
      'start': details.range.start.toIso8601String(),
      'end': details.range.end.toIso8601String(),
      'isAllDay': details.isAllDay,
    };
  }

  static ItemScheduleDetails? _scheduleFromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final start = DateTime.tryParse(value['start'] as String? ?? '');
    final end = DateTime.tryParse(value['end'] as String? ?? '');
    if (start == null || end == null) {
      return null;
    }
    return ItemScheduleDetails(
      range: DateTimeRangeValue(start: start, end: end),
      isAllDay: value['isAllDay'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _taskToJson(ItemTaskDetails details) {
    return {
      'schedule': _scheduleToJson(details.schedule),
      'deadline': details.deadline?.toIso8601String(),
    };
  }

  static ItemTaskDetails? _taskFromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final schedule = _scheduleFromJson(value['schedule']);
    if (schedule == null) {
      return null;
    }
    return ItemTaskDetails(
      schedule: schedule,
      deadline: DateTime.tryParse(value['deadline'] as String? ?? ''),
    );
  }

  static Map<String, dynamic> _memoToJson(ItemMemoDetails details) {
    return {
      'targetDate': details.targetDate.toIso8601String(),
      'estimatedDurationMinutes': details.estimatedDuration.inMinutes,
    };
  }

  static ItemMemoDetails? _memoFromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final targetDate = DateTime.tryParse(value['targetDate'] as String? ?? '');
    if (targetDate == null) {
      return null;
    }
    return ItemMemoDetails(
      targetDate: targetDate,
      estimatedDuration: Duration(
        minutes: value['estimatedDurationMinutes'] as int? ?? 0,
      ),
    );
  }

  static T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}
