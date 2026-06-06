import 'package:luotopia/shared/data/database/app_database.dart';

class SyncPayloadMapper {
  const SyncPayloadMapper._();

  static Future<Map<String, dynamic>> agendaItemPayload(
    AppDatabase db,
    AgendaItemRow row,
  ) async {
    return {
      'id': row.id,
      'type': row.type,
      'title': row.title,
      'notes': row.notes,
      'location': row.location,
      'color': row.color,
      'reminder': row.reminder,
      'repeat_rule': row.repeatRule,
      'details': await _detailsPayload(db, row),
      'is_completed': row.isCompleted,
      'completed_at': row.completedAt?.toIso8601String(),
      'sort_order': row.sortOrder,
      'source_kind': row.sourceKind,
      'source_ref': row.sourceRef,
      'created_at': row.createdAt.toIso8601String(),
      'updated_at': row.updatedAt.toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> _detailsPayload(
    AppDatabase db,
    AgendaItemRow row,
  ) async {
    switch (row.type) {
      case 'schedule':
        final detail = await (db.select(db.scheduleItemDetailRows)
              ..where((table) => table.itemId.equals(row.id)))
            .getSingle();
        return {
          'start_at': detail.startAt.toIso8601String(),
          'end_at': detail.endAt.toIso8601String(),
          'is_all_day': detail.isAllDay,
          'auto_completed_once_at': detail.autoCompletedOnceAt?.toIso8601String(),
        };
      case 'task':
        final detail = await (db.select(db.taskItemDetailRows)
              ..where((table) => table.itemId.equals(row.id)))
            .getSingle();
        return {
          'deadline_at': detail.deadlineAt.toIso8601String(),
        };
      case 'course':
        final detail = await (db.select(db.courseItemDetailRows)
              ..where((table) => table.itemId.equals(row.id)))
            .getSingle();
        return {
          'start_at': detail.startAt.toIso8601String(),
          'end_at': detail.endAt.toIso8601String(),
          'is_all_day': detail.isAllDay,
          'timetable_id': detail.timetableId,
          'source_kind': detail.sourceKind,
          'source_course_id': detail.sourceCourseId,
          'course_nature': detail.courseNature,
          'instructor': detail.instructor,
          'week_meta': detail.weekMeta,
        };
      case 'memo':
        return const {};
      default:
        return const {};
    }
  }

  static Map<String, dynamic> courseTimetablePayload(CourseTimetableRow row) {
    return {
      'id': row.id,
      'name': row.name,
      'source': row.source,
      'term_label': row.termLabel,
      'created_at': row.createdAt.toIso8601String(),
      'updated_at': row.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> selectedTimetablePayload(SelectedCourseTimetableRow row) {
    return {
      'timetable_id': row.timetableId,
      'sort_order': row.sortOrder,
      'updated_at': row.updatedAt.toIso8601String(),
    };
  }
}
