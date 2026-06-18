import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart';
import 'package:luotopia/shared/data/database/app_database.dart';

final allSchoolTimetableRepositoryProvider =
    Provider<AllSchoolTimetableRepository>((ref) {
      return DriftAllSchoolTimetableRepository(ref.read(appDatabaseProvider));
    });

class DriftAllSchoolTimetableRepository
    implements AllSchoolTimetableRepository {
  const DriftAllSchoolTimetableRepository(this._db);

  static const _mockAsset = 'assets/all_school_timetable/2025_2026_1.json';

  final AppDatabase _db;

  @override
  Future<void> ensureMockDataLoaded() async {
    final existing = await (_db.select(
      _db.schoolTimetableTermRows,
    )..where((row) => row.termKey.equals('2025-2026-1'))).getSingleOrNull();
    if (existing != null && existing.rowCount > 0) {
      return;
    }

    final raw = await rootBundle.loadString(_mockAsset);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final term = decoded['term'] as Map<String, dynamic>;
    final classes = (decoded['teachingClasses'] as List)
        .cast<Map<String, dynamic>>();
    final meetings = (decoded['meetings'] as List).cast<Map<String, dynamic>>();
    final now = DateTime.now();
    final heads = _buildHeads(classes);
    final meetingRows = <SchoolClassMeetingRowsCompanion>[
      for (var i = 0; i < meetings.length; i++)
        _meetingCompanion(meetings[i], i),
    ];

    await _db.transaction(() async {
      await (_db.delete(_db.schoolClassMeetingRows)).go();
      await (_db.delete(_db.schoolTeachingClassRows)).go();
      await (_db.delete(_db.schoolCourseHeadRows)).go();
      await (_db.delete(_db.schoolTimetableTermRows)).go();

      await _db
          .into(_db.schoolTimetableTermRows)
          .insert(
            SchoolTimetableTermRowsCompanion.insert(
              termKey: term['termKey'] as String,
              schoolYear: term['schoolYear'] as String,
              term: term['term'] as String,
              sourceVersion: Value(decoded['source'] as String? ?? _mockAsset),
              rowCount: Value(classes.length),
              importedAt: now,
              updatedAt: now,
            ),
          );

      await _db.batch((batch) {
        batch.insertAll(
          _db.schoolCourseHeadRows,
          heads.entries.map(_headCompanion).toList(growable: false),
        );
        batch.insertAll(
          _db.schoolTeachingClassRows,
          classes.map(_classCompanion).toList(growable: false),
        );
        batch.insertAll(_db.schoolClassMeetingRows, meetingRows);
      });
    });
  }

  @override
  Future<List<SchoolTimetableTerm>> loadTerms() async {
    final rows =
        await (_db.select(_db.schoolTimetableTermRows)..orderBy([
              (row) => OrderingTerm(
                expression: row.termKey,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    return rows.map(_termFromRow).toList(growable: false);
  }

  @override
  Future<List<SchoolCourseHead>> searchCourseHeads(
    AllSchoolTimetableQuery query,
  ) async {
    final termKey = query.termKey;
    if (termKey == null || termKey.isEmpty) {
      return const [];
    }

    final allowedHeadIds = query.hasProfessionalFilters
        ? await _matchingCourseHeadIds(query)
        : null;
    if (allowedHeadIds != null && allowedHeadIds.isEmpty) {
      return const [];
    }

    final selector = _db.select(_db.schoolCourseHeadRows)
      ..where((row) => row.termKey.equals(termKey));
    final keyword = query.keyword.trim();
    if (keyword.isNotEmpty) {
      final pattern = '%$keyword%';
      selector.where(
        (row) =>
            row.searchText.like(pattern) |
            row.courseName.like(pattern) |
            row.courseNo.like(pattern),
      );
    }
    if (allowedHeadIds != null) {
      selector.where((row) => row.id.isIn(allowedHeadIds));
    }

    final rows = await selector.get();
    rows.sort(
      (a, b) =>
          _relevanceScore(b, keyword).compareTo(_relevanceScore(a, keyword)),
    );
    return rows.take(80).map(_headFromRow).toList(growable: false);
  }

  @override
  Future<SchoolCourseHead?> findCourseHead(String id) async {
    final row = await (_db.select(
      _db.schoolCourseHeadRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _headFromRow(row);
  }

  @override
  Future<List<SchoolTeachingClass>> loadTeachingClasses(
    String courseHeadId,
  ) async {
    final rows =
        await (_db.select(_db.schoolTeachingClassRows)
              ..where((row) => row.courseHeadId.equals(courseHeadId))
              ..orderBy([
                (row) => OrderingTerm(expression: row.instructor),
                (row) => OrderingTerm(expression: row.teachingClassName),
              ]))
            .get();
    return rows.map(_classFromRow).toList(growable: false);
  }

  @override
  Future<SchoolTeachingClass?> findTeachingClass(String id) async {
    final row = await (_db.select(
      _db.schoolTeachingClassRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _classFromRow(row);
  }

  @override
  Future<List<SchoolClassMeeting>> loadMeetings(String teachingClassId) async {
    final rows =
        await (_db.select(_db.schoolClassMeetingRows)
              ..where((row) => row.teachingClassId.equals(teachingClassId))
              ..orderBy([
                (row) => OrderingTerm(expression: row.weekday),
                (row) => OrderingTerm(expression: row.rawText),
              ]))
            .get();
    return rows.map(_meetingFromRow).toList(growable: false);
  }

  Future<Set<String>> _matchingCourseHeadIds(
    AllSchoolTimetableQuery query,
  ) async {
    final conditions = <String>['c.term_key = ?'];
    final variables = <Variable>[Variable.withString(query.termKey!)];

    void addLike(String column, String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }
      conditions.add('$column LIKE ?');
      variables.add(Variable.withString('%$normalized%'));
    }

    addLike('c.open_college', query.openCollege);
    addLike('c.grade', query.grade);
    addLike('c.major', query.major);
    if (query.weekday != null) {
      conditions.add('m.weekday = ?');
      variables.add(Variable.withInt(query.weekday!));
    }
    addLike('m.building', query.building);

    final rows = await _db
        .customSelect(
          '''
          SELECT DISTINCT c.course_head_id
          FROM school_teaching_class_rows c
          LEFT JOIN school_class_meeting_rows m
            ON m.teaching_class_id = c.id
          WHERE ${conditions.join(' AND ')}
          ''',
          variables: variables,
          readsFrom: {_db.schoolTeachingClassRows, _db.schoolClassMeetingRows},
        )
        .get();
    return rows.map((row) => row.read<String>('course_head_id')).toSet();
  }

  int _relevanceScore(SchoolCourseHeadRow row, String keyword) {
    if (keyword.isEmpty) {
      return row.teachingClassCount;
    }
    var score = 0;
    if (row.courseName == keyword) score += 1000;
    if (row.courseNo == keyword) score += 900;
    if (row.courseName.startsWith(keyword)) score += 600;
    if (row.courseNo.startsWith(keyword)) score += 500;
    if (row.teacherSummary.contains(keyword)) score += 240;
    if (row.openCollege.contains(keyword)) score += 160;
    if (row.searchText.contains(keyword)) score += 80;
    return score + row.teachingClassCount;
  }

  Map<String, _HeadSeed> _buildHeads(List<Map<String, dynamic>> classes) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in classes) {
      final key = item['courseHeadKey'] as String;
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return {
      for (final entry in grouped.entries)
        entry.key: _HeadSeed.fromClasses(entry.key, entry.value),
    };
  }

  SchoolCourseHeadRowsCompanion _headCompanion(
    MapEntry<String, _HeadSeed> item,
  ) {
    final seed = item.value;
    return SchoolCourseHeadRowsCompanion.insert(
      id: seed.id,
      termKey: seed.termKey,
      courseHeadKey: seed.courseHeadKey,
      courseNo: seed.courseNo,
      courseName: seed.courseName,
      openCollege: Value(seed.openCollege),
      credits: Value(seed.credits),
      courseNature: Value(seed.courseNature),
      courseCategory: Value(seed.courseCategory),
      openType: Value(seed.openType),
      teachingClassCount: Value(seed.teachingClassCount),
      teacherSummary: Value(seed.teacherSummary),
      weekdaySummary: Value(seed.weekdaySummary),
      searchText: Value(seed.searchText),
    );
  }

  SchoolTeachingClassRowsCompanion _classCompanion(Map<String, dynamic> item) {
    return SchoolTeachingClassRowsCompanion.insert(
      id: item['id'] as String,
      termKey: item['termKey'] as String,
      courseHeadId: item['courseHeadKey'] as String,
      teachingClassName: item['teachingClassName'] as String,
      courseNo: item['courseNo'] as String,
      courseName: item['courseName'] as String,
      openCollege: Value(item['openCollege'] as String? ?? ''),
      planCollege: Value(item['planCollege'] as String? ?? ''),
      credits: Value((item['credits'] as num?)?.toDouble()),
      courseNature: Value(item['courseNature'] as String? ?? ''),
      courseCategory: Value(item['courseCategory'] as String? ?? ''),
      openType: Value(item['openType'] as String? ?? ''),
      grade: Value(item['grade'] as String? ?? ''),
      major: Value(item['major'] as String? ?? ''),
      instructor: Value(item['instructor'] as String? ?? ''),
      title: Value(item['title'] as String? ?? ''),
      capacity: Value((item['capacity'] as num?)?.toInt()),
      selectedCount: Value((item['selectedCount'] as num?)?.toInt()),
      peopleRaw: Value(item['peopleRaw'] as String? ?? ''),
      theoryHours: Value((item['theoryHours'] as num?)?.toInt()),
      computerHours: Value((item['computerHours'] as num?)?.toInt()),
      experimentHours: Value((item['experimentHours'] as num?)?.toInt()),
      practiceHours: Value((item['practiceHours'] as num?)?.toInt()),
      remark: Value(item['remark'] as String? ?? ''),
      otherTeachers: Value(item['otherTeachers'] as String? ?? ''),
      textbook: Value(item['textbook'] as String? ?? ''),
      publisher: Value(item['publisher'] as String? ?? ''),
      scheduleSummary: Value(item['scheduleSummary'] as String? ?? ''),
      weekdaySummary: Value(item['weekdaySummary'] as String? ?? ''),
      searchText: Value(item['searchText'] as String? ?? ''),
      originalFieldsJson: Value(jsonEncode(item['originalFields'] ?? {})),
    );
  }

  SchoolClassMeetingRowsCompanion _meetingCompanion(
    Map<String, dynamic> item,
    int importIndex,
  ) {
    return SchoolClassMeetingRowsCompanion.insert(
      id: '${item['id']}_$importIndex',
      teachingClassId: item['teachingClassId'] as String,
      weekday: item['weekday'] as int,
      weekdayLabel: Value(item['weekdayLabel'] as String? ?? ''),
      rawText: Value(item['rawText'] as String? ?? ''),
      locationText: Value(item['locationText'] as String? ?? ''),
      building: Value(item['building'] as String? ?? ''),
      room: Value(item['room'] as String? ?? ''),
    );
  }

  SchoolTimetableTerm _termFromRow(SchoolTimetableTermRow row) {
    return SchoolTimetableTerm(
      termKey: row.termKey,
      schoolYear: row.schoolYear,
      term: row.term,
      sourceVersion: row.sourceVersion,
      rowCount: row.rowCount,
      importedAt: row.importedAt,
      updatedAt: row.updatedAt,
    );
  }

  SchoolCourseHead _headFromRow(SchoolCourseHeadRow row) {
    return SchoolCourseHead(
      id: row.id,
      termKey: row.termKey,
      courseHeadKey: row.courseHeadKey,
      courseNo: row.courseNo,
      courseName: row.courseName,
      openCollege: row.openCollege,
      credits: row.credits,
      courseNature: row.courseNature,
      courseCategory: row.courseCategory,
      openType: row.openType,
      teachingClassCount: row.teachingClassCount,
      teacherSummary: row.teacherSummary,
      weekdaySummary: row.weekdaySummary,
    );
  }

  SchoolTeachingClass _classFromRow(SchoolTeachingClassRow row) {
    final decoded = jsonDecode(row.originalFieldsJson);
    final fields = <String, String>{
      if (decoded is Map)
        for (final entry in decoded.entries)
          entry.key.toString(): entry.value?.toString() ?? '',
    };
    return SchoolTeachingClass(
      id: row.id,
      termKey: row.termKey,
      courseHeadId: row.courseHeadId,
      teachingClassName: row.teachingClassName,
      courseNo: row.courseNo,
      courseName: row.courseName,
      openCollege: row.openCollege,
      planCollege: row.planCollege,
      credits: row.credits,
      courseNature: row.courseNature,
      courseCategory: row.courseCategory,
      openType: row.openType,
      grade: row.grade,
      major: row.major,
      instructor: row.instructor,
      title: row.title,
      capacity: row.capacity,
      selectedCount: row.selectedCount,
      peopleRaw: row.peopleRaw,
      theoryHours: row.theoryHours,
      computerHours: row.computerHours,
      experimentHours: row.experimentHours,
      practiceHours: row.practiceHours,
      remark: row.remark,
      otherTeachers: row.otherTeachers,
      textbook: row.textbook,
      publisher: row.publisher,
      scheduleSummary: row.scheduleSummary,
      weekdaySummary: row.weekdaySummary,
      originalFields: fields,
    );
  }

  SchoolClassMeeting _meetingFromRow(SchoolClassMeetingRow row) {
    return SchoolClassMeeting(
      id: row.id,
      teachingClassId: row.teachingClassId,
      weekday: row.weekday,
      weekdayLabel: row.weekdayLabel,
      rawText: row.rawText,
      locationText: row.locationText,
      building: row.building,
      room: row.room,
    );
  }
}

class _HeadSeed {
  const _HeadSeed({
    required this.id,
    required this.termKey,
    required this.courseHeadKey,
    required this.courseNo,
    required this.courseName,
    required this.openCollege,
    required this.credits,
    required this.courseNature,
    required this.courseCategory,
    required this.openType,
    required this.teachingClassCount,
    required this.teacherSummary,
    required this.weekdaySummary,
    required this.searchText,
  });

  factory _HeadSeed.fromClasses(
    String courseHeadKey,
    List<Map<String, dynamic>> classes,
  ) {
    final first = classes.first;
    final teachers = _uniqueSummary(
      classes.map((item) => item['instructor'] as String? ?? ''),
      suffix: '位教师',
    );
    final weekdays = _uniqueSummary(
      classes.map((item) => item['weekdaySummary'] as String? ?? ''),
      maxItems: 4,
      suffix: '组时间',
    );
    final searchText = [
      first['courseName'],
      first['courseNo'],
      first['openCollege'],
      first['courseNature'],
      first['courseCategory'],
      first['openType'],
      teachers,
      weekdays,
    ].whereType<String>().join(' ');
    return _HeadSeed(
      id: courseHeadKey,
      termKey: first['termKey'] as String,
      courseHeadKey: courseHeadKey,
      courseNo: first['courseNo'] as String,
      courseName: first['courseName'] as String,
      openCollege: first['openCollege'] as String? ?? '',
      credits: (first['credits'] as num?)?.toDouble(),
      courseNature: first['courseNature'] as String? ?? '',
      courseCategory: first['courseCategory'] as String? ?? '',
      openType: first['openType'] as String? ?? '',
      teachingClassCount: classes.length,
      teacherSummary: teachers,
      weekdaySummary: weekdays,
      searchText: searchText,
    );
  }

  final String id;
  final String termKey;
  final String courseHeadKey;
  final String courseNo;
  final String courseName;
  final String openCollege;
  final double? credits;
  final String courseNature;
  final String courseCategory;
  final String openType;
  final int teachingClassCount;
  final String teacherSummary;
  final String weekdaySummary;
  final String searchText;

  static String _uniqueSummary(
    Iterable<String> values, {
    int maxItems = 3,
    required String suffix,
  }) {
    final unique = <String>[];
    for (final value in values) {
      final normalized = value.trim();
      if (normalized.isNotEmpty && !unique.contains(normalized)) {
        unique.add(normalized);
      }
    }
    if (unique.isEmpty) {
      return '';
    }
    if (unique.length <= maxItems) {
      return unique.join('、');
    }
    return '${unique.take(maxItems).join('、')}等 ${unique.length} $suffix';
  }
}
