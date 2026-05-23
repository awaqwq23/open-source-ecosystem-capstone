import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class AgendaItemStorageMapper {
  const AgendaItemStorageMapper._();

  static Map<String, dynamic> toJson(AgendaItem item) {
    return {
      'id': item.id,
      'type': item.type.name,
      'title': item.title,
      'notes': item.notes,
      'location': item.location,
      'color': item.color.name,
      'reminder': item.reminder.name,
      'repeatRule': item.repeatRule.name,
      'startAt': item.startAt.toIso8601String(),
      'endAt': item.endAt.toIso8601String(),
      'isAllDay': item.isAllDay,
      'deadline': item.deadline?.toIso8601String(),
      'estimatedDurationMinutes': item.estimatedDuration.inMinutes,
      'courseDetails': _courseToJson(item.courseDetails),
      'isCompleted': item.isCompleted,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
      'completedAt': item.completedAt?.toIso8601String(),
      'sortOrder': item.sortOrder,
      'sourceKind': item.sourceKind.name,
      'sourceRef': item.sourceRef,
    };
  }

  static AgendaItem? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final title = json['title'] as String?;
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    final startAt = DateTime.tryParse(json['startAt'] as String? ?? '');
    final endAt = DateTime.tryParse(json['endAt'] as String? ?? '');
    if (id == null ||
        id.isEmpty ||
        title == null ||
        createdAt == null ||
        startAt == null ||
        endAt == null) {
      return null;
    }

    return AgendaItem(
      id: id,
      type: _enumByName(ItemType.values, json['type'] as String?) ?? ItemType.task,
      title: title,
      notes: json['notes'] as String? ?? '',
      location: json['location'] as String? ?? '',
      color: _enumByName(ItemColorOption.values, json['color'] as String?) ??
          ItemColorOption.sky,
      reminder: _enumByName(ReminderOption.values, json['reminder'] as String?) ??
          ReminderOption.none,
      repeatRule: _enumByName(RepeatRule.values, json['repeatRule'] as String?) ??
          RepeatRule.none,
      startAt: startAt,
      endAt: endAt,
      isAllDay: json['isAllDay'] as bool? ?? false,
      taskDetails: ItemTaskDetails(
        deadline: DateTime.tryParse(json['deadline'] as String? ?? ''),
        estimatedDuration: Duration(
          minutes: json['estimatedDurationMinutes'] as int? ?? 0,
        ),
      ),
      courseDetails: _courseFromJson(json['courseDetails']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? createdAt,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      sortOrder: (json['sortOrder'] as num?)?.toDouble() ?? 0,
      sourceKind:
          _enumByName(AgendaItemSourceKind.values, json['sourceKind'] as String?) ??
              AgendaItemSourceKind.manual,
      sourceRef: json['sourceRef'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _courseToJson(ItemCourseDetails details) {
    return {
      'timetableId': details.timetableId,
      'sourceKind': details.sourceKind.name,
      'sourceCourseId': details.sourceCourseId,
      'courseNature': details.courseNature,
      'instructor': details.instructor,
      'weekMeta': details.weekMeta,
    };
  }

  static ItemCourseDetails _courseFromJson(Object? value) {
    if (value is! Map) {
      return const ItemCourseDetails();
    }
    return ItemCourseDetails(
      timetableId: value['timetableId'] as String? ?? '',
      sourceKind: _enumByName(
            CourseItemSourceKind.values,
            value['sourceKind'] as String?,
          ) ??
          CourseItemSourceKind.manual,
      sourceCourseId: value['sourceCourseId'] as String? ?? '',
      courseNature: value['courseNature'] as String? ?? '',
      instructor: value['instructor'] as String? ?? '',
      weekMeta: value['weekMeta'] as String? ?? '',
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
