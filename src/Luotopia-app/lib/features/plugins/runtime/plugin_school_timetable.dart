import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/whu_auth/whu_auth.dart';
import 'dart:convert';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import '../domain/plugin_manifest.dart';

// shortcut: provenance is session-only; persist verified owner metadata before
// enabling legacy/synced snapshots or access after an application restart.
final schoolTimetableProvenanceProvider = Provider<SchoolTimetableProvenance>((
  ref,
) {
  final auth = ref.watch(
    whuAuthProvider.select(
      (state) => (state.isAuthenticated, state.account?.studentId),
    ),
  );
  return SchoolTimetableProvenance(auth.$1 && (auth.$2?.isNotEmpty ?? false));
});

class SchoolTimetableProvenance {
  SchoolTimetableProvenance(this.authenticated);
  final bool authenticated;
  final timetableIds = <String>{};
}

/// Read-only snapshot of courses already imported by the app's WHU login flow.
class PluginSchoolTimetable {
  PluginSchoolTimetable({
    required this.isAuthenticated,
    required this.store,
    required this.items,
    required this.ownsTimetable,
  });
  final bool Function() isAuthenticated;
  final CourseTimetableStore Function() store;
  final List<AgendaItem> Function() items;
  final bool Function(String id) ownsTimetable;

  Object read(String method, List<dynamic> args, {required bool authorized}) {
    requirePlugin(authorized, '未授权读取教务课表', 'PERMISSION_DENIED');
    requirePlugin(isAuthenticated(), '请先登录武大教务账户', 'AUTH_REQUIRED');
    final timetables = store().timetables
        .where(
          (t) => t.source == CourseTimetableSource.whuJw && ownsTimetable(t.id),
        )
        .toList();
    Object result;
    if (method == 'schoolTimetable.listTimetables') {
      requirePlugin(args.isEmpty, '课表参数不正确', 'INVALID_INPUT');
      result = timetables
          .take(100)
          .map(
            (t) => <String, dynamic>{
              'id': t.id,
              'name': t.name,
              'termLabel': t.termLabel,
            },
          )
          .toList();
    } else {
      requirePlugin(
        method == 'schoolTimetable.getCourses',
        '不支持此课表方法',
        'PERMISSION_DENIED',
      );
      requirePlugin(args.length == 1, '课表参数不正确', 'INVALID_INPUT');
      final query = pluginObject(args.single, 'INVALID_INPUT');
      pluginFields(query, {'timetableId', 'offset', 'limit'}, 'INVALID_INPUT');
      final id = pluginText(query['timetableId'], 128, 'INVALID_INPUT');
      final offset = query['offset'] ?? 0, limit = query['limit'] ?? 50;
      requirePlugin(
        offset is int &&
            offset >= 0 &&
            offset <= 100000 &&
            limit is int &&
            limit >= 1 &&
            limit <= 100,
        '分页参数不正确',
        'INVALID_INPUT',
      );
      requirePlugin(
        timetables.any((t) => t.id == id),
        '教务课表不存在',
        'INVALID_INPUT',
      );
      final courses = items()
          .where(
            (item) =>
                item.type == ItemType.course &&
                item.courseDetails.sourceKind == CourseItemSourceKind.whuJw &&
                item.courseDetails.timetableId == id,
          )
          .toList();
      result = <String, dynamic>{
        'total': courses.length,
        'items': courses
            .skip(offset as int)
            .take(limit as int)
            .map(
              (item) => <String, dynamic>{
                'id': item.id,
                'title': item.title,
                'location': item.location,
                'instructor': item.courseDetails.instructor,
                'startAt': item.timelineStartAt?.toIso8601String(),
                'endAt': item.timelineEndAt?.toIso8601String(),
              },
            )
            .toList(),
      };
    }
    requirePlugin(
      utf8.encode(jsonEncode(result)).length <= 256 * 1024,
      '课表结果过大',
      'RESOURCE_LIMIT_EXCEEDED',
    );
    return result;
  }
}
