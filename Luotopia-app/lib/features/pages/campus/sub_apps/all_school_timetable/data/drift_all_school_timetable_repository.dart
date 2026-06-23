import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart';
import 'package:luotopia/shared/data/database/app_database.dart';

final allSchoolTimetableRepositoryProvider =
    Provider<AllSchoolTimetableRepository>((ref) {
      final repository = DriftAllSchoolTimetableRepository(
        ref.read(appDatabaseProvider),
      );
      ref.onDispose(() {
        unawaited(repository.dispose());
      });
      return repository;
    });

class DriftAllSchoolTimetableRepository
    implements AllSchoolTimetableRepository {
  DriftAllSchoolTimetableRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> ensureLocalDataReady() async {
    await _ensureMetaDefaults();
  }

  @override
  Future<void> replaceTermFromHtmlRows({
    required String termKey,
    required String schoolYear,
    required String term,
    required String sourceVersion,
    required List<Map<String, String>> rows,
  }) async {
    throw UnsupportedError('全校课表由服务端 SQLite 快照提供');
  }

  @override
  Future<int> readDatasetVersion() async {
    final row = await _db
        .customSelect(
          "SELECT value FROM school_timetable_meta WHERE key = 'dataset_version'",
        )
        .getSingleOrNull();
    return int.tryParse(row?.data['value']?.toString() ?? '') ?? 0;
  }

  @override
  Future<void> applyChanges({
    required int version,
    required String checksum,
    required List<SchoolTimetableChange> changes,
  }) async {
    await _db.transaction(() async {
      for (final change in changes) {
        if (change.operation == 'delete') {
          await _deleteEntity(change.entityType, change.entityId);
          continue;
        }
        if (change.operation == 'upsert') {
          await _upsertEntity(change);
        }
      }
      await _rebuildSearchIndex();
      await _writeMeta('dataset_version', version.toString());
      await _writeMeta('dataset_checksum', checksum);
      await _writeMeta(
        'updated_at',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    });
  }

  @override
  Future<List<SchoolTimetableTerm>> loadTerms() async {
    final rows = await _db.customSelect('''
          SELECT term_key, school_year, term, first_week_monday, source_version,
                 row_count, imported_at, updated_at
          FROM school_timetable_term_rows
          ORDER BY term_key DESC
          ''').get();
    return rows
        .map(
          (row) => SchoolTimetableTerm(
            termKey: _readString(row, 'term_key'),
            schoolYear: _readString(row, 'school_year'),
            term: _readString(row, 'term'),
            firstWeekMonday: _readString(row, 'first_week_monday'),
            sourceVersion: _readString(row, 'source_version'),
            rowCount: _readInt(row, 'row_count'),
            importedAt: _dateTimeFromMillis(row.data['imported_at']),
            updatedAt: _dateTimeFromMillis(row.data['updated_at']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<SchoolCourseHead>> searchCourseHeads(
    AllSchoolTimetableQuery query,
  ) async {
    final termKey = query.termKey;
    if (termKey == null || termKey.isEmpty) {
      return const [];
    }
    final db = await _databaseForTerm(termKey);
    if (db == null) {
      return const [];
    }
    final schema = _schemaForDb(db);
    final keyword = query.keyword.trim();
    final filterVariables = <Variable>[];
    final professionalClause = _professionalExistsClause(
      query,
      filterVariables,
      schema,
    );
    final rows = keyword.isNotEmpty
        ? await db
              .customSelect(
                '''
          SELECT c.id AS id, c.term_key, cc.id AS catalog_id, cc.course_no, cc.course_name, c.open_college,
                 cc.credits, c.course_nature, c.course_category, c.open_type,
                 c.teaching_class_count, c.teacher_summary, c.weekday_summary,
                 c.search_text
          FROM ${schema.searchTable}
          JOIN ${schema.termCourseTable} c
            ON c.id = ${schema.searchTable}.term_course_id
          JOIN ${schema.courseTable} cc
            ON cc.id = c.${schema.courseIdColumn}
          WHERE ${schema.searchTable}.term_key = ?
            AND ${schema.searchTable} MATCH ?
            $professionalClause
          ORDER BY bm25(${schema.searchTable}), c.teaching_class_count DESC
          LIMIT 80
          ''',
                variables: [
                  Variable.withString(termKey),
                  Variable.withString(_ftsQuery(keyword)),
                  ...filterVariables,
                ],
              )
              .get()
        : await db
              .customSelect(
                '''
          SELECT c.id AS id, c.term_key, cc.id AS catalog_id, cc.course_no, cc.course_name, c.open_college,
                 cc.credits, c.course_nature, c.course_category, c.open_type,
                 teaching_class_count, teacher_summary, weekday_summary,
                 search_text
          FROM ${schema.termCourseTable} c
          JOIN ${schema.courseTable} cc
            ON cc.id = c.${schema.courseIdColumn}
          WHERE c.term_key = ?
            $professionalClause
          ORDER BY teaching_class_count DESC
          LIMIT 80
          ''',
                variables: [Variable.withString(termKey), ...filterVariables],
              )
              .get();
    return rows.map(_termCourseFromRow).toList(growable: false);
  }

  @override
  Future<SchoolCourseHead?> findCourseHead({
    required String termKey,
    required String id,
  }) async {
    final db = await _databaseForTerm(termKey);
    if (db == null) {
      return null;
    }
    final schema = _schemaForDb(db);
    final row = await db
        .customSelect(
          '''
          SELECT c.id AS id, c.term_key, cc.id AS catalog_id, cc.course_no, cc.course_name, c.open_college,
                 cc.credits, c.course_nature, c.course_category, c.open_type,
                 teaching_class_count, teacher_summary, weekday_summary,
                 search_text
          FROM ${schema.termCourseTable} c
          JOIN ${schema.courseTable} cc
            ON cc.id = c.${schema.courseIdColumn}
          WHERE c.id = ?
          ''',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _termCourseFromRow(row);
  }

  @override
  Future<List<SchoolTeachingClass>> loadTeachingClasses({
    required String termKey,
    required String courseHeadId,
  }) async {
    final db = await _databaseForTerm(termKey);
    if (db == null) {
      return const [];
    }
    final schema = _schemaForDb(db);
    final rows = await db
        .customSelect(
          '''
          SELECT o.*, ${schema.detailFieldsSelect} c.id AS term_course_stable_id,
                 cc.id AS catalog_stable_id,
                 ic.id AS instructor_course_stable_id,
                 cc.course_no, cc.course_name, cc.credits, c.open_college,
                 c.course_nature, c.course_category, c.open_type,
                 COALESCE(a.grade, '') AS grade,
                 COALESCE(a.major, '') AS major,
                 COALESCE(a.plan_college, '') AS plan_college
          FROM ${schema.offeringTable} o
          JOIN ${schema.termCourseTable} c ON c.id = o.term_course_id
          JOIN ${schema.courseTable} cc ON cc.id = c.${schema.courseIdColumn}
          JOIN ${schema.instructorTable} ic ON ic.id = o.${schema.offeringInstructorIdColumn}
          LEFT JOIN (
            SELECT offering_id,
                   GROUP_CONCAT(DISTINCT grade) AS grade,
                   GROUP_CONCAT(DISTINCT major) AS major,
                   GROUP_CONCAT(DISTINCT plan_college) AS plan_college
            FROM ${schema.audienceTable}
            GROUP BY offering_id
          ) a ON a.offering_id = o.id
          WHERE c.id = ?
          ORDER BY instructor, teaching_class_name
          ''',
          variables: [Variable.withString(courseHeadId)],
        )
        .get();
    return rows.map(_offeringFromRow).toList(growable: false);
  }

  @override
  Future<SchoolTeachingClass?> findTeachingClass({
    required String termKey,
    required String id,
  }) async {
    final db = await _databaseForTerm(termKey);
    if (db == null) {
      return null;
    }
    final schema = _schemaForDb(db);
    final row = await db
        .customSelect(
          '''
          SELECT o.*, ${schema.detailFieldsSelect} c.id AS term_course_stable_id,
                 cc.id AS catalog_stable_id,
                 ic.id AS instructor_course_stable_id,
                 cc.course_no, cc.course_name, cc.credits, c.open_college,
                 c.course_nature, c.course_category, c.open_type,
                 COALESCE(a.grade, '') AS grade,
                 COALESCE(a.major, '') AS major,
                 COALESCE(a.plan_college, '') AS plan_college
          FROM ${schema.offeringTable} o
          JOIN ${schema.termCourseTable} c ON c.id = o.term_course_id
          JOIN ${schema.courseTable} cc ON cc.id = c.${schema.courseIdColumn}
          JOIN ${schema.instructorTable} ic ON ic.id = o.${schema.offeringInstructorIdColumn}
          LEFT JOIN (
            SELECT offering_id,
                   GROUP_CONCAT(DISTINCT grade) AS grade,
                   GROUP_CONCAT(DISTINCT major) AS major,
                   GROUP_CONCAT(DISTINCT plan_college) AS plan_college
            FROM ${schema.audienceTable}
            GROUP BY offering_id
          ) a ON a.offering_id = o.id
          WHERE o.id = ?
          ''',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _offeringFromRow(row);
  }

  @override
  Future<List<SchoolClassMeeting>> loadMeetings({
    required String termKey,
    required String teachingClassId,
  }) async {
    final db = await _databaseForTerm(termKey);
    if (db == null) {
      return const [];
    }
    final schema = _schemaForDb(db);
    final rows = await db
        .customSelect(
          '''
          SELECT r.*, r.id AS stable_id, o.id AS offering_stable_id
          FROM ${schema.meetingRuleTable} r
          JOIN ${schema.offeringTable} o ON o.id = r.offering_id
          WHERE o.id = ?
          ORDER BY weekday, segment_index
          ''',
          variables: [Variable.withString(teachingClassId)],
        )
        .get();
    return rows.map(_ruleFromRow).toList(growable: false);
  }

  @override
  Future<CourseEntityLink> matchPersonalCourse(
    PersonalCourseMatchQuery query,
  ) async {
    final termKey = query.termKey.trim();
    final courseNo = query.courseNo.trim();
    if (termKey.isEmpty || courseNo.isEmpty) {
      return const CourseEntityLink();
    }
    final db = await _databaseForTerm(termKey);
    if (db == null) {
      return const CourseEntityLink();
    }
    final schema = _schemaForDb(db);

    final termCourseId = await _matchTermCourse(db, query, schema);
    final weekIndex = await _weekIndexForDate(db, query);
    final offering = await _matchOffering(
      db,
      query,
      weekIndex: weekIndex,
      schema: schema,
    );
    if (offering == null) {
      return CourseEntityLink(termCourseId: termCourseId);
    }

    final instanceId = _readString(offering, 'matched_instance_id');
    final occurrenceId = instanceId.isEmpty || weekIndex == null
        ? ''
        : '$instanceId:$weekIndex';
    return CourseEntityLink(
      termCourseId: _readString(offering, 'term_course_stable_id').isNotEmpty
          ? _readString(offering, 'term_course_stable_id')
          : termCourseId,
      offeringId: _readString(offering, 'id'),
      instructorCourseId:
          _readString(offering, 'instructor_course_stable_id').isNotEmpty
          ? _readString(offering, 'instructor_course_stable_id')
          : _readString(offering, 'instructor_course_id'),
      occurrenceId: occurrenceId,
    );
  }

  Future<String> _matchTermCourse(
    GeneratedDatabase db,
    PersonalCourseMatchQuery query,
    _ArtifactSchema schema,
  ) async {
    final rows = await db
        .customSelect(
          '''
          SELECT c.id AS id, cc.course_name
          FROM ${schema.termCourseTable} c
          JOIN ${schema.courseTable} cc ON cc.id = c.${schema.courseIdColumn}
          WHERE c.term_key = ? AND cc.course_no = ?
          ''',
          variables: [
            Variable.withString(query.termKey.trim()),
            Variable.withString(query.courseNo.trim()),
          ],
        )
        .get();
    if (rows.length == 1) {
      return _readString(rows.single, 'id');
    }
    final courseName = _normalizeName(query.courseName);
    final sameName = [
      for (final row in rows)
        if (_normalizeName(_readString(row, 'course_name')) == courseName) row,
    ];
    return sameName.length == 1 ? _readString(sameName.single, 'id') : '';
  }

  Future<QueryRow?> _matchOffering(
    GeneratedDatabase db,
    PersonalCourseMatchQuery query, {
    required int? weekIndex,
    required _ArtifactSchema schema,
  }) async {
    final sectionRange = _sectionRange(query.sectionText);
    final ruleClauses = <String>[];
    final variables = <Variable>[
      Variable.withString(query.termKey.trim()),
      Variable.withString(query.courseNo.trim()),
      Variable.withInt(query.weekday),
    ];
    if (weekIndex != null) {
      ruleClauses.add('''
        EXISTS (
          SELECT 1 FROM ${schema.meetingWeekTable} iw
          WHERE iw.meeting_rule_id = r.id AND iw.week_index = ?
        )
      ''');
      variables.add(Variable.withInt(weekIndex));
    }
    if (sectionRange != null) {
      ruleClauses.add('''
        r.section_start <= ? AND r.section_end >= ?
      ''');
      variables.add(Variable.withInt(sectionRange.end));
      variables.add(Variable.withInt(sectionRange.start));
    }
    final rows = await db.customSelect('''
          SELECT o.*, ${schema.detailFieldsSelect} c.id AS term_course_stable_id,
                 ic.id AS instructor_course_stable_id,
                 cc.course_no, cc.course_name, cc.credits, c.open_college,
                 c.course_nature, c.course_category, c.open_type,
                 r.id AS matched_instance_id,
                 r.location_text AS matched_location_text
          FROM ${schema.offeringTable} o
          JOIN ${schema.termCourseTable} c
            ON c.id = o.term_course_id
          JOIN ${schema.courseTable} cc
            ON cc.id = c.${schema.courseIdColumn}
          JOIN ${schema.instructorTable} ic
            ON ic.id = o.${schema.offeringInstructorIdColumn}
          JOIN ${schema.meetingRuleTable} r
            ON r.offering_id = o.id
          WHERE o.term_key = ?
            AND cc.course_no = ?
            AND r.weekday = ?
            ${ruleClauses.isEmpty ? '' : 'AND ${ruleClauses.join(' AND ')}'}
          ''', variables: variables).get();
    if (rows.isEmpty) {
      return null;
    }

    final className = _normalizeName(query.teachingClassName);
    var candidates = rows;
    if (className.isNotEmpty) {
      candidates = [
        for (final row in candidates)
          if (_normalizeName(_readString(row, 'teaching_class_name')) ==
              className)
            row,
      ];
    }
    if (candidates.isEmpty) {
      return null;
    }

    final instructor = _normalizeName(query.instructor);
    if (instructor.isNotEmpty) {
      final teacherMatches = [
        for (final row in candidates)
          if (_teacherMatches(row, instructor)) row,
      ];
      if (teacherMatches.isNotEmpty) {
        candidates = teacherMatches;
      }
    }

    final locationMatches = [
      for (final row in candidates)
        if (_locationCompatible(
          _readString(row, 'matched_location_text'),
          query.locationText,
        ))
          row,
    ];
    if (locationMatches.length == 1) {
      return locationMatches.single;
    }

    return candidates.length == 1 && className.isNotEmpty
        ? candidates.single
        : null;
  }

  Future<int?> _weekIndexForDate(
    GeneratedDatabase db,
    PersonalCourseMatchQuery query,
  ) async {
    final row = await db
        .customSelect(
          '''
          SELECT first_week_monday
          FROM school_timetable_term_rows
          WHERE term_key = ?
          ''',
          variables: [Variable.withString(query.termKey.trim())],
        )
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final firstWeekMonday = DateTime.tryParse(
      _readString(row, 'first_week_monday'),
    );
    if (firstWeekMonday == null) {
      return null;
    }
    final queryDate = DateTime(
      query.date.year,
      query.date.month,
      query.date.day,
    );
    final firstDate = DateTime(
      firstWeekMonday.year,
      firstWeekMonday.month,
      firstWeekMonday.day,
    );
    final days = queryDate.difference(firstDate).inDays;
    if (days < 0) {
      return null;
    }
    return days ~/ 7 + 1;
  }

  String _professionalExistsClause(
    AllSchoolTimetableQuery query,
    List<Variable> variables,
    _ArtifactSchema schema,
  ) {
    if (!query.hasProfessionalFilters) {
      return '';
    }
    final conditions = <String>['o.term_course_id = c.id'];

    void addLike(String column, String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }
      conditions.add('$column LIKE ?');
      variables.add(Variable.withString('%$normalized%'));
    }

    addLike('c2.open_college', query.openCollege);
    addLike('a.grade', query.grade);
    addLike('a.major', query.major);
    if (query.weekday != null) {
      conditions.add('r.weekday = ?');
      variables.add(Variable.withInt(query.weekday!));
    }
    addLike('r.location_text', query.building);

    return '''
      AND EXISTS (
        SELECT 1
        FROM ${schema.offeringTable} o
        JOIN ${schema.termCourseTable} c2
          ON c2.id = o.term_course_id
        LEFT JOIN ${schema.audienceTable} a
          ON a.offering_id = o.id
        LEFT JOIN ${schema.meetingRuleTable} r
          ON r.offering_id = o.id
        WHERE ${conditions.join(' AND ')}
      )
    ''';
  }

  String _ftsQuery(String keyword) {
    final tokens = keyword
        .split(RegExp(r'\s+'))
        .map((part) => part.trim().replaceAll('"', '""'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (tokens.isEmpty) {
      return '""';
    }
    return tokens.map((part) => '"$part"').join(' ');
  }

  SchoolCourseHead _termCourseFromRow(QueryRow row) {
    return SchoolCourseHead(
      id: _readString(row, 'id'),
      termKey: _readString(row, 'term_key'),
      catalogId: _readString(row, 'catalog_id'),
      courseNo: _readString(row, 'course_no'),
      courseName: _readString(row, 'course_name'),
      openCollege: _readString(row, 'open_college'),
      credits: _readDoubleOrNull(row, 'credits'),
      courseNature: _readString(row, 'course_nature'),
      courseCategory: _readString(row, 'course_category'),
      openType: _readString(row, 'open_type'),
      teachingClassCount: _readInt(row, 'teaching_class_count'),
      teacherSummary: _readString(row, 'teacher_summary'),
      weekdaySummary: _readString(row, 'weekday_summary'),
    );
  }

  SchoolTeachingClass _offeringFromRow(QueryRow row) {
    return SchoolTeachingClass(
      id: _readString(row, 'id'),
      termKey: _readString(row, 'term_key'),
      sourceKey: _readString(row, 'source_key'),
      termCourseId: _readString(row, 'term_course_stable_id').isNotEmpty
          ? _readString(row, 'term_course_stable_id')
          : _readString(row, 'term_course_id'),
      catalogId: _readString(row, 'catalog_stable_id').isNotEmpty
          ? _readString(row, 'catalog_stable_id')
          : _readString(row, 'catalog_id'),
      instructorCourseId:
          _readString(row, 'instructor_course_stable_id').isNotEmpty
          ? _readString(row, 'instructor_course_stable_id')
          : _readString(row, 'instructor_course_id'),
      teachingClassName: _readString(row, 'teaching_class_name'),
      courseNo: _readString(row, 'course_no'),
      courseName: _readString(row, 'course_name'),
      openCollege: _readString(row, 'open_college'),
      planCollege: _readString(row, 'plan_college'),
      credits: _readDoubleOrNull(row, 'credits'),
      courseNature: _readString(row, 'course_nature'),
      courseCategory: _readString(row, 'course_category'),
      openType: _readString(row, 'open_type'),
      grade: _readString(row, 'grade'),
      major: _readString(row, 'major'),
      instructor: _readString(row, 'instructor'),
      title: _readString(row, 'title'),
      capacity: _readIntOrNull(row, 'capacity'),
      selectedCount: _readIntOrNull(row, 'selected_count'),
      peopleRaw: _readString(row, 'people_raw'),
      theoryHours: _readIntOrNull(row, 'theory_hours'),
      computerHours: _readIntOrNull(row, 'computer_hours'),
      experimentHours: _readIntOrNull(row, 'experiment_hours'),
      practiceHours: _readIntOrNull(row, 'practice_hours'),
      remark: _readString(row, 'remark'),
      otherTeachers: _readString(row, 'other_teachers'),
      textbook: _readString(row, 'textbook'),
      publisher: _readString(row, 'publisher'),
      scheduleSummary: _readString(row, 'schedule_summary'),
      weekdaySummary: _readString(row, 'weekday_summary'),
      originalFields: _decodeFields(_readString(row, 'detail_fields_json')),
    );
  }

  SchoolClassMeeting _ruleFromRow(QueryRow row) {
    return SchoolClassMeeting(
      id: _readString(row, 'id'),
      offeringId: _readString(row, 'offering_stable_id'),
      weekday: _readInt(row, 'weekday'),
      weekdayLabel: _readString(row, 'weekday_label'),
      rawText: _readString(row, 'raw_segment_text'),
      weekText: _readString(row, 'week_text'),
      sectionText: _readString(row, 'section_text'),
      locationText: _readString(row, 'location_text'),
      building: '',
      room: '',
    );
  }

  Future<GeneratedDatabase?> _databaseForTerm(String termKey) async {
    final row = await _db
        .customSelect(
          'SELECT 1 FROM school_timetable_term_rows WHERE term_key = ? LIMIT 1',
          variables: [Variable.withString(termKey)],
        )
        .getSingleOrNull();
    return row == null ? null : _db;
  }

  _ArtifactSchema _schemaForDb(GeneratedDatabase db) {
    return _ArtifactSchema.v7;
  }

  Future<void> dispose() async {}

  Future<void> _ensureMetaDefaults() async {
    await _writeMeta(
      'dataset_version',
      (await readDatasetVersion()).toString(),
    );
  }

  Future<void> _writeMeta(String key, String value) async {
    await _db.customStatement(
      'INSERT OR REPLACE INTO school_timetable_meta (key, value) VALUES (?, ?)',
      [key, value],
    );
  }

  Future<void> _upsertEntity(SchoolTimetableChange change) async {
    final p = change.payload;
    switch (change.entityType) {
      case 'term':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_term_rows
          (term_key, school_year, term, first_week_monday, source_version, row_count, imported_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'school_year'),
            _stringPayload(p, 'term'),
            _stringPayload(p, 'first_week_monday'),
            change.version.toString(),
            _intPayload(p, 'row_count'),
            DateTime.now().millisecondsSinceEpoch,
            DateTime.now().millisecondsSinceEpoch,
          ],
        );
      case 'course':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_courses
          (id, catalog_key, course_no, course_name, credits, search_text)
          VALUES (?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'catalog_key'),
            _stringPayload(p, 'course_no'),
            _stringPayload(p, 'course_name'),
            _stringPayload(p, 'credits'),
            _stringPayload(p, 'search_text'),
          ],
        );
      case 'term_course':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_course_terms
          (id, term_key, course_id, open_college, course_nature, course_category, open_type,
           teaching_class_count, teacher_summary, weekday_summary, search_text)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'term_key'),
            _stringPayload(p, 'catalog_id'),
            _stringPayload(p, 'open_college'),
            _stringPayload(p, 'course_nature'),
            _stringPayload(p, 'course_category'),
            _stringPayload(p, 'open_type'),
            _intPayload(p, 'teaching_class_count'),
            _stringPayload(p, 'teacher_summary'),
            _stringPayload(p, 'weekday_summary'),
            _stringPayload(p, 'search_text'),
          ],
        );
      case 'instructor_course':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_instructors
          (id, course_id, instructor_name, instructor_name_key, offering_count,
           latest_term_key, latest_open_college, latest_teaching_title, search_text)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'catalog_id'),
            _stringPayload(p, 'instructor_name'),
            _stringPayload(p, 'instructor_name_key'),
            _intPayload(p, 'offering_count'),
            _stringPayload(p, 'latest_term_key'),
            _stringPayload(p, 'latest_open_college'),
            _stringPayload(p, 'latest_teaching_title'),
            _stringPayload(p, 'search_text'),
          ],
        );
      case 'offering':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_offerings
          (id, term_key, term_course_id, course_id, instructor_id, source_key, teaching_class_name,
           instructor, title, people_raw, capacity, selected_count, theory_hours, computer_hours,
           experiment_hours, practice_hours, remark, other_teachers, textbook, publisher,
           schedule_summary, weekday_summary, detail_fields_json, search_text)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'term_key'),
            _stringPayload(p, 'term_course_id'),
            _stringPayload(p, 'catalog_id'),
            _stringPayload(p, 'instructor_course_id'),
            _stringPayload(p, 'source_key'),
            _stringPayload(p, 'teaching_class_name'),
            _stringPayload(p, 'instructor'),
            _stringPayload(p, 'title'),
            _stringPayload(p, 'people_raw'),
            _intPayload(p, 'capacity'),
            _intPayload(p, 'selected_count'),
            _stringPayload(p, 'theory_hours'),
            _stringPayload(p, 'computer_hours'),
            _stringPayload(p, 'experiment_hours'),
            _stringPayload(p, 'practice_hours'),
            _stringPayload(p, 'remark'),
            _stringPayload(p, 'other_teachers'),
            _stringPayload(p, 'textbook'),
            _stringPayload(p, 'publisher'),
            _stringPayload(p, 'schedule_summary'),
            _stringPayload(p, 'weekday_summary'),
            jsonEncode(p['fields'] is Map ? p['fields'] : const {}),
            _stringPayload(p, 'search_text'),
          ],
        );
      case 'audience':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_audiences
          (id, term_key, offering_id, grade, major, plan_college, course_nature, course_nature_code,
           course_category, course_category_code, open_type, open_type_code, condition_code)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'term_key'),
            _stringPayload(p, 'offering_id'),
            _stringPayload(p, 'grade'),
            _stringPayload(p, 'major'),
            _stringPayload(p, 'plan_college'),
            _stringPayload(p, 'course_nature'),
            _stringPayload(p, 'course_nature_code'),
            _stringPayload(p, 'course_category'),
            _stringPayload(p, 'course_category_code'),
            _stringPayload(p, 'open_type'),
            _stringPayload(p, 'open_type_code'),
            _stringPayload(p, 'condition_code'),
          ],
        );
      case 'source_row':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_source_rows
          (id, term_key, term_course_id, offering_id, source_key, package_index, source_status, raw_fields_json)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'term_key'),
            _stringPayload(p, 'term_course_id'),
            _stringPayload(p, 'offering_id'),
            _stringPayload(p, 'source_key'),
            _intPayload(p, 'package_index'),
            _stringPayload(p, 'status'),
            jsonEncode(p['fields'] is Map ? p['fields'] : const {}),
          ],
        );
      case 'meeting_rule':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_meeting_rules
          (id, offering_id, term_key, weekday, day_field, segment_index, weekday_label, raw_day_text,
           raw_segment_text, week_text, section_text, section_start, section_end, location_text, parse_status)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'offering_id'),
            _stringPayload(p, 'term_key'),
            _intPayload(p, 'weekday'),
            _stringPayload(p, 'day_field'),
            _intPayload(p, 'segment_index'),
            _stringPayload(p, 'weekday_label'),
            _stringPayload(p, 'raw_day_text'),
            _stringPayload(p, 'raw_segment_text'),
            _stringPayload(p, 'week_text'),
            _stringPayload(p, 'section_text'),
            _intPayload(p, 'section_start'),
            _intPayload(p, 'section_end'),
            _stringPayload(p, 'location_text'),
            _stringPayload(p, 'parse_status'),
          ],
        );
      case 'meeting_week':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_meeting_weeks
          (meeting_rule_id, week_index)
          VALUES (?, ?)
        ''',
          [_stringPayload(p, 'meeting_rule_id'), _intPayload(p, 'week_index')],
        );
    }
  }

  Future<void> _deleteEntity(String entityType, String entityId) async {
    switch (entityType) {
      case 'term':
        await _db.customStatement(
          'DELETE FROM school_timetable_term_rows WHERE term_key = ?',
          [entityId],
        );
      case 'course':
        await _db.customStatement(
          'DELETE FROM school_timetable_courses WHERE id = ?',
          [entityId],
        );
      case 'term_course':
        await _db.customStatement(
          'DELETE FROM school_timetable_course_terms WHERE id = ?',
          [entityId],
        );
      case 'instructor_course':
        await _db.customStatement(
          'DELETE FROM school_timetable_instructors WHERE id = ?',
          [entityId],
        );
      case 'offering':
        await _db.customStatement(
          'DELETE FROM school_timetable_offerings WHERE id = ?',
          [entityId],
        );
      case 'audience':
        await _db.customStatement(
          'DELETE FROM school_timetable_audiences WHERE id = ?',
          [entityId],
        );
      case 'source_row':
        await _db.customStatement(
          'DELETE FROM school_timetable_source_rows WHERE id = ?',
          [entityId],
        );
      case 'meeting_rule':
        await _db.customStatement(
          'DELETE FROM school_timetable_meeting_rules WHERE id = ?',
          [entityId],
        );
        await _db.customStatement(
          'DELETE FROM school_timetable_meeting_weeks WHERE meeting_rule_id = ?',
          [entityId],
        );
      case 'meeting_week':
        final separator = entityId.lastIndexOf(':');
        if (separator > 0) {
          await _db.customStatement(
            'DELETE FROM school_timetable_meeting_weeks WHERE meeting_rule_id = ? AND week_index = ?',
            [
              entityId.substring(0, separator),
              int.tryParse(entityId.substring(separator + 1)) ?? 0,
            ],
          );
        }
    }
  }

  Future<void> _rebuildSearchIndex() async {
    await _db.customStatement('DELETE FROM school_timetable_search_fts');
    await _db.customStatement('''
      INSERT INTO school_timetable_search_fts
      (term_course_id, term_key, course_name, course_no, open_college, course_nature,
       course_category, teacher_summary, weekday_summary, search_text)
      SELECT c.id, c.term_key, cc.course_name, cc.course_no, c.open_college,
             c.course_nature, c.course_category, c.teacher_summary,
             c.weekday_summary, c.search_text
      FROM school_timetable_course_terms c
      JOIN school_timetable_courses cc ON cc.id = c.course_id
    ''');
  }

  String _stringPayload(Map<String, dynamic> payload, String key) {
    return payload[key]?.toString() ?? '';
  }

  int _intPayload(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _readString(QueryRow row, String column) {
    final value = row.data[column];
    return value?.toString() ?? '';
  }

  int _readInt(QueryRow row, String column) {
    final value = row.data[column];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _readIntOrNull(QueryRow row, String column) {
    final value = row.data[column];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _readDoubleOrNull(QueryRow row, String column) {
    final value = row.data[column];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  DateTime _dateTimeFromMillis(Object? value) {
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Map<String, String> _decodeFields(String raw) {
    final decoded = jsonDecode(raw);
    return {
      if (decoded is Map)
        for (final entry in decoded.entries)
          entry.key.toString(): entry.value?.toString() ?? '',
    };
  }

  bool _teacherMatches(QueryRow row, String instructor) {
    final normalizedInstructor = _normalizeName(instructor);
    if (normalizedInstructor.isEmpty) {
      return false;
    }
    final teachers = [
      _readString(row, 'instructor'),
      _readString(row, 'title'),
      _readString(row, 'other_teachers'),
    ].expand((value) => _splitTeacherNames(value));
    return teachers.any(
      (teacher) => _normalizeName(teacher) == normalizedInstructor,
    );
  }

  Iterable<String> _splitTeacherNames(String value) {
    return value
        .split(RegExp(r'[,，;；、/\s]+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
  }

  _SectionRange? _sectionRange(String value) {
    final numbers = RegExp(r'\d+')
        .allMatches(value)
        .map((match) => int.tryParse(match.group(0) ?? ''))
        .whereType<int>()
        .toList(growable: false);
    if (numbers.isEmpty) {
      return null;
    }
    final start = numbers.first;
    final end = numbers.length >= 2 ? numbers[1] : numbers.first;
    if (start <= 0 || end < start) {
      return null;
    }
    return _SectionRange(start: start, end: end);
  }

  bool _locationCompatible(String left, String right) {
    final normalizedLeft = _normalizeLocation(left);
    final normalizedRight = _normalizeLocation(right);
    if (normalizedLeft.isEmpty || normalizedRight.isEmpty) {
      return true;
    }
    return normalizedLeft == normalizedRight ||
        normalizedLeft.contains(normalizedRight) ||
        normalizedRight.contains(normalizedLeft);
  }

  String _normalizeName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[（）()]'), '');
  }

  String _normalizeLocation(String value) {
    return _normalizeName(
      value,
    ).replaceAll('教学楼', '').replaceAll('教室', '').replaceAll('武汉大学', '');
  }
}

class _ArtifactSchema {
  const _ArtifactSchema({
    required this.courseTable,
    required this.termCourseTable,
    required this.instructorTable,
    required this.offeringTable,
    required this.audienceTable,
    required this.meetingRuleTable,
    required this.meetingWeekTable,
    required this.searchTable,
    required this.courseIdColumn,
    required this.offeringInstructorIdColumn,
    required this.detailFieldsSelect,
  });

  final String courseTable;
  final String termCourseTable;
  final String instructorTable;
  final String offeringTable;
  final String audienceTable;
  final String meetingRuleTable;
  final String meetingWeekTable;
  final String searchTable;
  final String courseIdColumn;
  final String offeringInstructorIdColumn;
  final String detailFieldsSelect;

  static const v7 = _ArtifactSchema(
    courseTable: 'school_timetable_courses',
    termCourseTable: 'school_timetable_course_terms',
    instructorTable: 'school_timetable_instructors',
    offeringTable: 'school_timetable_offerings',
    audienceTable: 'school_timetable_audiences',
    meetingRuleTable: 'school_timetable_meeting_rules',
    meetingWeekTable: 'school_timetable_meeting_weeks',
    searchTable: 'school_timetable_search_fts',
    courseIdColumn: 'course_id',
    offeringInstructorIdColumn: 'instructor_id',
    detailFieldsSelect: '\'{}\' AS detail_fields_json,',
  );
}

class _SectionRange {
  const _SectionRange({required this.start, required this.end});

  final int start;
  final int end;
}
