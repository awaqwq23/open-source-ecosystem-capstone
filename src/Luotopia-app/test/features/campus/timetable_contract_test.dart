import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:luotopia/app/app.dart';
import 'package:luotopia/app/router/app_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/widgets/timetable_list_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/data/drift_all_school_timetable_repository.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/viewmodels/all_school_timetable_view_model.dart';
import 'package:luotopia/shared/data/database/app_database.dart';

void main() {
  final bundle = Platform.environment['TIMETABLE_CONTRACT_BUNDLE'];
  test(
    'Go 生成的课表包可被 Flutter 导入并查询',
    () async {
      final db = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = DriftAllSchoolTimetableRepository(db);
      await repository.replaceFromBundle(
        version: 1,
        checksum: 'fixture',
        sqliteGzipFile: File(bundle!),
      );
      final term = (await repository.loadTerms()).single;
      expect(term.firstWeekMonday, '2025-09-01');
      final heads = await repository.searchCourseHeads(
        AllSchoolTimetableQuery(termKey: term.termKey, keyword: '软件工程'),
      );
      final classes = await repository.loadTeachingClasses(
        termKey: term.termKey,
        courseHeadId: heads.single.id,
      );
      final meeting = (await repository.loadMeetings(
        termKey: term.termKey,
        teachingClassId: classes.single.id,
      )).single;
      expect(meeting.weekIndexes, [1, 2]);
      expect(meeting.weekday, 5);
      expect(meeting.locationText, '3区1-101');
    },
    skip: bundle == null ? '需要 Go 生成的课表包，见 src/test/README.md' : false,
  );
  testWidgets('同步样例经数据库、搜索和详情提供完整排课', (tester) async {
    final sample =
        jsonDecode(
              File('../samples/timetable-date-export.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    const term = '2026-2027-1';
    final changes = <SchoolTimetableChange>[];
    void upsert(String type, String id, Map<String, dynamic> payload) {
      changes.add(
        SchoolTimetableChange(
          version: 1,
          sequence: changes.length + 1,
          operation: 'upsert',
          entityType: type,
          entityId: id,
          termKey: term,
          payload: payload,
        ),
      );
    }

    upsert('term', term, {'first_week_monday': sample['firstWeekMonday']});
    upsert('course', 'course', {'course_name': sample['className']});
    upsert('offering', 'class', {
      'term_key': term,
      'course_id': 'course',
      'term_course_id': 'head',
      'teaching_class_name': sample['className'],
    });
    final meetings = sample['meetings'] as List;
    for (final (index, meeting) in meetings.indexed) {
      upsert('meeting', 'meeting-$index', {
        'offering_id': 'class',
        'term_key': term,
        'weekday': meeting['weekday'],
        'section_text': meeting['sectionText'],
        'week_indexes': meeting['weekIndexes'],
        'location_text': meeting['location'],
      });
    }
    await container
        .read(allSchoolTimetableRepositoryProvider)
        .applyChanges(version: 1, checksum: 'fixture', changes: changes);
    final provider = allSchoolTimetableViewModelProvider;
    final vm = container.read(provider.notifier);
    await vm.load();
    expect(
      container.read(provider).selectedTerm?.firstWeekMonday,
      sample['firstWeekMonday'],
    );
    await vm.setKeyword('开源');
    final head = container.read(provider).courseHeads.single;
    final group = await container.read(
      courseHeadDetailProvider(
        CourseHeadDetailQuery(termKey: term, id: head.id),
      ).future,
    );
    final detail = await container.read(
      teachingClassDetailProvider(
        TeachingClassDetailQuery(termKey: term, id: group.classes.single.id),
      ).future,
    );
    expect(detail!.teachingClass.teachingClassName, sample['className']);
    expect([
      for (final meeting in detail.meetings)
        {
          'weekday': meeting.weekday,
          'sectionText': meeting.sectionText,
          'location': meeting.locationText,
          'weekIndexes': meeting.weekIndexes,
        },
    ], meetings);
    await vm.setKeyword('不存在的课程');
    expect(container.read(provider).errorMessage, isNull);
    expect(container.read(provider).courseHeads, isEmpty);
    expect(
      await container.read(
        teachingClassDetailProvider(
          const TeachingClassDetailQuery(termKey: term, id: 'missing'),
        ).future,
      ),
      isNull,
    );
    container
        .read(appRouterProvider)
        .go(AppRoutePaths.campusAllSchoolTimetable);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LuotopiaApp(),
      ),
    );
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    await tester.enterText(field, '不存在的课程');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('没有找到符合条件的课程'), findsOneWidget);
    await tester.enterText(field, '开源');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TimetableListButton));
    await tester.pumpAndSettle();
    expect(find.text('1 个教学班'), findsOneWidget);
    await tester.tap(find.byType(TimetableListButton));
    await tester.pumpAndSettle();
    expect(find.text('课程详情'), findsOneWidget);
    expect(
      find.textContaining(meetings.single['location'] as String),
      findsOneWidget,
    );
  });
}
