import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
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

  final AppDatabase _db;

  @override
  Future<void> ensureLocalDataReady() async {}

  @override
  Future<void> replaceTermFromHtmlRows({
    required String termKey,
    required String schoolYear,
    required String term,
    required String sourceVersion,
    required List<Map<String, String>> rows,
  }) async {
    throw UnsupportedError('全校课表由服务端统一课程实体快照提供');
  }

  @override
  Future<void> replaceTermFromPackageBytes({
    required List<int> bytes,
    required String sourceVersion,
  }) async {
    final decoded = utf8.decode(gzip.decode(bytes));
    final snapshot = jsonDecode(decoded) as Map<String, dynamic>;
    final manifest = snapshot['manifest'] as Map<String, dynamic>? ?? {};
    final termKey = manifest['term_key'] as String? ?? '';
    final schoolYear = manifest['school_year'] as String? ?? '';
    final term = manifest['term'] as String? ?? '';
    final firstWeekMonday = manifest['first_week_monday'] as String? ?? '';
    if (termKey.isEmpty || firstWeekMonday.isEmpty) {
      throw const FormatException('统一课程快照缺少学期或第一周周一');
    }
    final now = DateTime.now();
    await _db.transaction(() async {
      await _deleteTerm(termKey);
      await _db
          .into(_db.schoolTimetableTermRows)
          .insert(
            SchoolTimetableTermRowsCompanion.insert(
              termKey: termKey,
              schoolYear: schoolYear,
              term: term,
              firstWeekMonday: firstWeekMonday,
              sourceVersion: Value(sourceVersion),
              rowCount: Value((manifest['row_count'] as num?)?.toInt() ?? 0),
              importedAt: now,
              updatedAt: now,
            ),
          );

      await _db.batch((batch) {
        batch.insertAll(
          _db.courseCatalogRows,
          _catalogs(snapshot['catalogs']),
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          _db.courseTermCourseRows,
          _termCourses(snapshot['term_courses']),
        );
        batch.insertAll(
          _db.courseInstructorCourseRows,
          _instructorCourses(snapshot['instructor_courses']),
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          _db.courseOfferingRows,
          _offerings(snapshot['offerings']),
        );
        batch.insertAll(
          _db.courseAudienceRows,
          _audiences(snapshot['audiences']),
        );
        batch.insertAll(
          _db.courseSourceRows,
          _sourceRows(snapshot['source_rows']),
        );
        batch.insertAll(
          _db.courseMeetingRuleRows,
          _meetingRules(snapshot['meeting_rules']),
        );
        batch.insertAll(
          _db.courseOccurrenceRows,
          _occurrences(snapshot['occurrences']),
        );
      });
    });
  }

  Future<void> _deleteTerm(String termKey) async {
    await (_db.delete(
      _db.courseOccurrenceRows,
    )..where((row) => row.termKey.equals(termKey))).go();
    await (_db.delete(
      _db.courseMeetingRuleRows,
    )..where((row) => row.termKey.equals(termKey))).go();
    await (_db.delete(
      _db.courseSourceRows,
    )..where((row) => row.termKey.equals(termKey))).go();
    await (_db.delete(
      _db.courseAudienceRows,
    )..where((row) => row.termKey.equals(termKey))).go();
    await (_db.delete(
      _db.courseOfferingRows,
    )..where((row) => row.termKey.equals(termKey))).go();
    await (_db.delete(
      _db.courseTermCourseRows,
    )..where((row) => row.termKey.equals(termKey))).go();
    await (_db.delete(
      _db.schoolTimetableTermRows,
    )..where((row) => row.termKey.equals(termKey))).go();
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
    final allowedTermCourseIds = query.hasProfessionalFilters
        ? await _matchingTermCourseIds(query)
        : null;
    if (allowedTermCourseIds != null && allowedTermCourseIds.isEmpty) {
      return const [];
    }
    final selector = _db.select(_db.courseTermCourseRows)
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
    if (allowedTermCourseIds != null) {
      selector.where((row) => row.id.isIn(allowedTermCourseIds));
    }
    final rows = await selector.get();
    rows.sort(
      (a, b) =>
          _relevanceScore(b, keyword).compareTo(_relevanceScore(a, keyword)),
    );
    return rows.take(80).map(_termCourseFromRow).toList(growable: false);
  }

  @override
  Future<SchoolCourseHead?> findCourseHead(String id) async {
    final row = await (_db.select(
      _db.courseTermCourseRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _termCourseFromRow(row);
  }

  @override
  Future<List<SchoolTeachingClass>> loadTeachingClasses(
    String courseHeadId,
  ) async {
    final rows =
        await (_db.select(_db.courseOfferingRows)
              ..where((row) => row.termCourseId.equals(courseHeadId))
              ..orderBy([
                (row) => OrderingTerm(expression: row.instructor),
                (row) => OrderingTerm(expression: row.teachingClassName),
              ]))
            .get();
    return rows.map(_offeringFromRow).toList(growable: false);
  }

  @override
  Future<SchoolTeachingClass?> findTeachingClass(String id) async {
    final row = await (_db.select(
      _db.courseOfferingRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _offeringFromRow(row);
  }

  @override
  Future<List<SchoolClassMeeting>> loadMeetings(String teachingClassId) async {
    final rows =
        await (_db.select(_db.courseMeetingRuleRows)
              ..where((row) => row.offeringId.equals(teachingClassId))
              ..orderBy([
                (row) => OrderingTerm(expression: row.weekday),
                (row) => OrderingTerm(expression: row.segmentIndex),
              ]))
            .get();
    return rows.map(_ruleFromRow).toList(growable: false);
  }

  Future<Set<String>> _matchingTermCourseIds(
    AllSchoolTimetableQuery query,
  ) async {
    final conditions = <String>['o.term_key = ?'];
    final variables = <Variable>[Variable.withString(query.termKey!)];

    void addLike(String column, String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }
      conditions.add('$column LIKE ?');
      variables.add(Variable.withString('%$normalized%'));
    }

    addLike('o.open_college', query.openCollege);
    addLike('a.grade', query.grade);
    addLike('a.major', query.major);
    if (query.weekday != null) {
      conditions.add('r.weekday = ?');
      variables.add(Variable.withInt(query.weekday!));
    }
    addLike('r.building', query.building);

    final rows = await _db
        .customSelect(
          '''
          SELECT DISTINCT o.term_course_id
          FROM course_offering_rows o
          LEFT JOIN course_audience_rows a
            ON a.offering_id = o.id
          LEFT JOIN course_meeting_rule_rows r
            ON r.offering_id = o.id
          WHERE ${conditions.join(' AND ')}
          ''',
          variables: variables,
          readsFrom: {
            _db.courseOfferingRows,
            _db.courseAudienceRows,
            _db.courseMeetingRuleRows,
          },
        )
        .get();
    return rows.map((row) => row.read<String>('term_course_id')).toSet();
  }

  int _relevanceScore(CourseTermCourseRow row, String keyword) {
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

  SchoolTimetableTerm _termFromRow(SchoolTimetableTermRow row) {
    return SchoolTimetableTerm(
      termKey: row.termKey,
      schoolYear: row.schoolYear,
      term: row.term,
      firstWeekMonday: row.firstWeekMonday,
      sourceVersion: row.sourceVersion,
      rowCount: row.rowCount,
      importedAt: row.importedAt,
      updatedAt: row.updatedAt,
    );
  }

  SchoolCourseHead _termCourseFromRow(CourseTermCourseRow row) {
    return SchoolCourseHead(
      id: row.id,
      termKey: row.termKey,
      catalogId: row.catalogId,
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

  SchoolTeachingClass _offeringFromRow(CourseOfferingRow row) {
    return SchoolTeachingClass(
      id: row.id,
      termKey: row.termKey,
      sourceKey: row.sourceKey,
      termCourseId: row.termCourseId,
      catalogId: row.catalogId,
      instructorCourseId: row.instructorCourseId,
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
      capacity: _parsePeople(row.peopleRaw).capacity,
      selectedCount: _parsePeople(row.peopleRaw).selected,
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
      originalFields: _decodeFields(row.originalFieldsJson),
    );
  }

  SchoolClassMeeting _ruleFromRow(CourseMeetingRuleRow row) {
    return SchoolClassMeeting(
      id: row.id,
      offeringId: row.offeringId,
      weekday: row.weekday,
      weekdayLabel: row.weekdayLabel,
      rawText: row.rawText,
      weekText: row.weekText,
      sectionText: row.sectionText,
      locationText: row.locationText,
      building: row.building,
      room: row.room,
    );
  }

  List<CourseCatalogRowsCompanion> _catalogs(Object? raw) {
    return _items(raw)
        .map(
          (item) => CourseCatalogRowsCompanion.insert(
            id: _string(item, 'id'),
            catalogKey: _string(item, 'catalog_key'),
            courseNo: _string(item, 'course_no'),
            courseName: _string(item, 'course_name'),
            credits: Value(_doubleOrNull(item, 'credits')),
            searchText: Value(_string(item, 'search_text')),
          ),
        )
        .toList(growable: false);
  }

  List<CourseTermCourseRowsCompanion> _termCourses(Object? raw) {
    return _items(raw)
        .map(
          (item) => CourseTermCourseRowsCompanion.insert(
            id: _string(item, 'id'),
            termKey: _string(item, 'term_key'),
            catalogId: _string(item, 'catalog_id'),
            courseNo: _string(item, 'course_no'),
            courseName: _string(item, 'course_name'),
            openCollege: Value(_string(item, 'open_college')),
            credits: Value(_doubleOrNull(item, 'credits')),
            courseNature: Value(_string(item, 'course_nature')),
            courseCategory: Value(_string(item, 'course_category')),
            openType: Value(_string(item, 'open_type')),
            teachingClassCount: Value(_int(item, 'teaching_class_count')),
            teacherSummary: Value(_string(item, 'teacher_summary')),
            weekdaySummary: Value(_string(item, 'weekday_summary')),
            searchText: Value(_string(item, 'search_text')),
          ),
        )
        .toList(growable: false);
  }

  List<CourseInstructorCourseRowsCompanion> _instructorCourses(Object? raw) {
    return _items(raw)
        .map(
          (item) => CourseInstructorCourseRowsCompanion.insert(
            id: _string(item, 'id'),
            catalogId: _string(item, 'catalog_id'),
            courseNo: _string(item, 'course_no'),
            courseName: _string(item, 'course_name'),
            credits: Value(_doubleOrNull(item, 'credits')),
            instructorName: Value(_string(item, 'instructor_name')),
            instructorNameKey: Value(_string(item, 'instructor_name_key')),
            offeringCount: Value(_int(item, 'offering_count')),
            latestTermKey: Value(_string(item, 'latest_term_key')),
            latestOpenCollege: Value(_string(item, 'latest_open_college')),
            latestTeachingTitle: Value(_string(item, 'latest_teaching_title')),
            searchText: Value(_string(item, 'search_text')),
          ),
        )
        .toList(growable: false);
  }

  List<CourseOfferingRowsCompanion> _offerings(Object? raw) {
    return _items(raw)
        .map(
          (item) => CourseOfferingRowsCompanion.insert(
            id: _string(item, 'id'),
            termKey: _string(item, 'term_key'),
            termCourseId: _string(item, 'term_course_id'),
            catalogId: _string(item, 'catalog_id'),
            instructorCourseId: _string(item, 'instructor_course_id'),
            sourceKey: _string(item, 'source_key'),
            schoolYear: _string(item, 'school_year'),
            term: _string(item, 'term'),
            teachingClassName: _string(item, 'teaching_class_name'),
            courseNo: _string(item, 'course_no'),
            courseName: _string(item, 'course_name'),
            openCollege: Value(_string(item, 'open_college')),
            planCollege: Value(_string(item, 'audience_summary')),
            credits: Value(_doubleOrNull(item, 'credits')),
            courseNature: Value(_string(item, 'course_nature')),
            courseCategory: Value(_string(item, 'course_category')),
            openType: Value(_string(item, 'open_type')),
            grade: Value(''),
            major: Value(''),
            instructor: Value(_string(item, 'instructor')),
            title: Value(_string(item, 'title')),
            peopleRaw: Value(_string(item, 'people_raw')),
            theoryHours: Value(_intOrNull(item, 'theory_hours')),
            computerHours: Value(_intOrNull(item, 'computer_hours')),
            experimentHours: Value(_intOrNull(item, 'experiment_hours')),
            practiceHours: Value(_intOrNull(item, 'practice_hours')),
            remark: Value(_string(item, 'remark')),
            otherTeachers: Value(_string(item, 'other_teachers')),
            textbook: Value(_string(item, 'textbook')),
            publisher: Value(_string(item, 'publisher')),
            scheduleSummary: Value(_string(item, 'schedule_summary')),
            weekdaySummary: Value(_string(item, 'weekday_summary')),
            searchText: Value(_string(item, 'search_text')),
            originalFieldsJson: Value(jsonEncode(item['fields'] ?? const {})),
          ),
        )
        .toList(growable: false);
  }

  List<CourseAudienceRowsCompanion> _audiences(Object? raw) {
    return _items(raw)
        .map(
          (item) => CourseAudienceRowsCompanion.insert(
            id: _string(item, 'id'),
            termKey: _string(item, 'term_key'),
            offeringId: _string(item, 'offering_id'),
            termCourseId: _string(item, 'term_course_id'),
            catalogId: _string(item, 'catalog_id'),
            grade: Value(_string(item, 'grade')),
            major: Value(_string(item, 'major')),
            planCollege: Value(_string(item, 'plan_college')),
            courseNature: Value(_string(item, 'course_nature')),
            courseNatureCode: Value(_string(item, 'course_nature_code')),
            courseCategory: Value(_string(item, 'course_category')),
            courseCategoryCode: Value(_string(item, 'course_category_code')),
            openType: Value(_string(item, 'open_type')),
            openTypeCode: Value(_string(item, 'open_type_code')),
            conditionCode: Value(_string(item, 'condition_code')),
          ),
        )
        .toList(growable: false);
  }

  List<CourseSourceRowsCompanion> _sourceRows(Object? raw) {
    return _items(raw)
        .map(
          (item) => CourseSourceRowsCompanion.insert(
            id: _string(item, 'id'),
            termKey: _string(item, 'term_key'),
            termCourseId: Value(_string(item, 'term_course_id')),
            offeringId: Value(_string(item, 'offering_id')),
            sourceKey: Value(_string(item, 'source_key')),
            packageIndex: Value(_int(item, 'package_index')),
            sourceStatus: Value(_string(item, 'status')),
            originalFieldsJson: Value(jsonEncode(item['fields'] ?? const {})),
          ),
        )
        .toList(growable: false);
  }

  List<CourseMeetingRuleRowsCompanion> _meetingRules(Object? raw) {
    return _items(raw)
        .map(
          (item) => CourseMeetingRuleRowsCompanion.insert(
            id: _string(item, 'id'),
            offeringId: _string(item, 'offering_id'),
            termKey: _string(item, 'term_key'),
            termCourseId: _string(item, 'term_course_id'),
            catalogId: _string(item, 'catalog_id'),
            weekday: _int(item, 'weekday'),
            segmentIndex: _int(item, 'segment_index'),
            weekdayLabel: Value(_string(item, 'weekday_label')),
            rawText: Value(_string(item, 'raw_text')),
            weekText: Value(_string(item, 'week_text')),
            sectionText: Value(_string(item, 'section_text')),
            locationText: Value(_string(item, 'location_text')),
            building: Value(_string(item, 'building')),
            room: Value(_string(item, 'room')),
          ),
        )
        .toList(growable: false);
  }

  List<CourseOccurrenceRowsCompanion> _occurrences(Object? raw) {
    return _items(raw)
        .map(
          (item) => CourseOccurrenceRowsCompanion.insert(
            id: _string(item, 'id'),
            ruleId: _string(item, 'rule_id'),
            offeringId: _string(item, 'offering_id'),
            termKey: _string(item, 'term_key'),
            termCourseId: _string(item, 'term_course_id'),
            catalogId: _string(item, 'catalog_id'),
            date: _string(item, 'date'),
            weekIndex: _int(item, 'week_index'),
            weekday: _int(item, 'weekday'),
            sectionText: Value(_string(item, 'section_text')),
            locationText: Value(_string(item, 'location_text')),
            building: Value(_string(item, 'building')),
            room: Value(_string(item, 'room')),
          ),
        )
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _items(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) item,
    ];
  }

  String _string(Map<String, dynamic> item, String key) {
    return item[key]?.toString() ?? '';
  }

  int _int(Map<String, dynamic> item, String key) {
    return (item[key] as num?)?.toInt() ??
        int.tryParse(_string(item, key)) ??
        0;
  }

  int? _intOrNull(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return null;
    return (value as num?)?.toInt() ?? int.tryParse(value.toString());
  }

  double? _doubleOrNull(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return null;
    return (value as num?)?.toDouble() ?? double.tryParse(value.toString());
  }

  Map<String, String> _decodeFields(String raw) {
    final decoded = jsonDecode(raw);
    return {
      if (decoded is Map)
        for (final entry in decoded.entries)
          entry.key.toString(): entry.value?.toString() ?? '',
    };
  }

  _PeopleCount _parsePeople(String raw) {
    final parts = raw.split(RegExp(r'[\\/／]'));
    return _PeopleCount(
      capacity: parts.isEmpty ? null : int.tryParse(parts.first.trim()),
      selected: parts.length < 2 ? null : int.tryParse(parts[1].trim()),
    );
  }
}

class _PeopleCount {
  const _PeopleCount({required this.capacity, required this.selected});

  final int? capacity;
  final int? selected;
}
