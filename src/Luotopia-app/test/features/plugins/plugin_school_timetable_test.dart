import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/whu_auth/whu_auth.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/value_objects/agenda_item_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/domain/plugin_error.dart';
import 'package:luotopia/features/plugins/runtime/plugin_school_timetable.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';

class TestWhuAuth extends WhuAuthNotifier {
  @override
  WhuAuthState build() => const WhuAuthState();
  void login(String id) => state = WhuAuthState(
    status: WhuAuthStatus.authenticated,
    account: WhuAccount(studentId: id, name: '', college: '', major: ''),
  );
}

void main() {
  var authenticated = true;
  final ownedIds = <String>{'whu'};
  var courses = <AgendaItem>[];
  final service = PluginSchoolTimetable(
    isAuthenticated: () => authenticated,
    store: () => CourseTimetableStore(
      timetables: [
        CourseTimetable(
          id: 'whu',
          name: '教务课表',
          source: CourseTimetableSource.whuJw,
          createdAt: DateTime(2026),
        ),
        CourseTimetable(
          id: 'private',
          name: '其他课表',
          source: CourseTimetableSource.manual,
          createdAt: DateTime(2026),
        ),
      ],
    ),
    items: () => courses,
    ownsTimetable: ownedIds.contains,
  );
  Matcher error(String code) =>
      isA<PluginException>().having((e) => e.code, 'code', code);
  test('permission and current login are checked on each read', () {
    expect(
      () =>
          service.read('schoolTimetable.listTimetables', [], authorized: false),
      throwsA(error('PERMISSION_DENIED')),
    );
    authenticated = false;
    expect(
      () =>
          service.read('schoolTimetable.listTimetables', [], authorized: true),
      throwsA(error('AUTH_REQUIRED')),
    );
    authenticated = true;
    expect(
      service.read('schoolTimetable.listTimetables', [], authorized: true),
      [
        {'id': 'whu', 'name': '教务课表', 'termLabel': ''},
      ],
    );
  });
  test(
    'rejects non-WHU ids, unknown fields, methods and invalid pagination',
    () {
      for (final query in [
        {'timetableId': 'private'},
        {'timetableId': 'whu', 'url': 'https://example.org'},
        {'timetableId': 'whu', 'limit': 101},
        {'timetableId': 'whu', 'offset': -1},
        {'timetableId': 'whu', 'limit': 1.5},
      ]) {
        expect(
          () => service.read('schoolTimetable.getCourses', [
            query,
          ], authorized: true),
          throwsA(error('INVALID_INPUT')),
        );
      }
      expect(
        () => service.read('schoolTimetable.delete', [], authorized: true),
        throwsA(error('PERMISSION_DENIED')),
      );
      expect(
        service.read('schoolTimetable.getCourses', [
          {'timetableId': 'whu'},
        ], authorized: true),
        {'total': 0, 'items': []},
      );
    },
  );
  test('returns only WHU course fields with pagination, never notes', () {
    AgendaItem course(String id, CourseItemSourceKind source) => AgendaItem(
      id: id,
      type: ItemType.course,
      title: '数学',
      notes: 'private secret',
      location: '教室',
      color: ItemColorOption.sky,
      reminder: ReminderOption.none,
      repeatRule: RepeatRule.none,
      details: CourseAgendaItemDetails(
        startAt: DateTime(2026),
        endAt: DateTime(2026, 1, 1, 1),
        isAllDay: false,
        course: ItemCourseDetails(
          timetableId: 'whu',
          sourceKind: source,
          instructor: '教师',
        ),
      ),
      isCompleted: false,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      completedAt: null,
      sortOrder: 0,
    );
    courses = [
      course('a', CourseItemSourceKind.whuJw),
      course('excluded', CourseItemSourceKind.manual),
      course('b', CourseItemSourceKind.whuJw),
    ];
    final result =
        service.read('schoolTimetable.getCourses', [
              {'timetableId': 'whu', 'offset': 1, 'limit': 1},
            ], authorized: true)
            as Map;
    expect(result['total'], 2);
    expect((result['items'] as List).single['id'], 'b');
    expect((result['items'] as List).single.keys.toSet(), {
      'id',
      'title',
      'location',
      'instructor',
      'startAt',
      'endAt',
    });
    courses = [];
  });
  test(
    'account switch or unknown legacy provenance hides cached snapshots',
    () {
      ownedIds.clear();
      expect(
        service.read('schoolTimetable.listTimetables', [], authorized: true),
        isEmpty,
      );
      expect(
        () => service.read('schoolTimetable.getCourses', [
          {'timetableId': 'whu'},
        ], authorized: true),
        throwsA(error('INVALID_INPUT')),
      );
      ownedIds.add('whu');
    },
  );
  test(
    'A to B account switch revokes provenance and never restores A cache',
    () {
      final container = ProviderContainer(
        overrides: [whuAuthProvider.overrideWith(TestWhuAuth.new)],
      );
      addTearDown(container.dispose);
      final listener = container.listen(
        schoolTimetableProvenanceProvider,
        (_, _) {},
      );
      addTearDown(listener.close);
      final auth = container.read(whuAuthProvider.notifier) as TestWhuAuth;
      auth.login('A');
      final a = container.read(schoolTimetableProvenanceProvider);
      a.timetableIds.add('whu');
      auth.login('B');
      final b = container.read(schoolTimetableProvenanceProvider);
      expect(b.timetableIds, isEmpty);
      expect(identical(a, b), false);
      auth.login('A');
      expect(
        container.read(schoolTimetableProvenanceProvider).timetableIds,
        isEmpty,
      );
    },
  );
}
