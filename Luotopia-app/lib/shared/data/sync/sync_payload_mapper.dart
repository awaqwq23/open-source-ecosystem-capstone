import 'package:luotopia/shared/data/database/app_database.dart';

class SyncPayloadMapper {
  const SyncPayloadMapper._();

  static Map<String, dynamic> agendaItemPayload(AgendaItemRow row) {
    return {
      'id': row.id,
      'type': row.type,
      'title': row.title,
      'notes': row.notes,
      'location': row.location,
      'color': row.color,
      'reminder': row.reminder,
      'repeat_rule': row.repeatRule,
      'start_at': row.startAt.toIso8601String(),
      'end_at': row.endAt.toIso8601String(),
      'is_all_day': row.isAllDay,
      'deadline': row.deadline?.toIso8601String(),
      'estimated_duration_minutes': row.estimatedDurationMinutes,
      'is_completed': row.isCompleted,
      'completed_at': row.completedAt?.toIso8601String(),
      'sort_order': row.sortOrder,
      'source_kind': row.sourceKind,
      'source_ref': row.sourceRef,
      'course_timetable_id': row.courseTimetableId,
      'course_source_kind': row.courseSourceKind,
      'course_source_course_id': row.courseSourceCourseId,
      'course_nature': row.courseNature,
      'instructor': row.instructor,
      'week_meta': row.weekMeta,
      'created_at': row.createdAt.toIso8601String(),
      'updated_at': row.updatedAt.toIso8601String(),
    };
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
}
