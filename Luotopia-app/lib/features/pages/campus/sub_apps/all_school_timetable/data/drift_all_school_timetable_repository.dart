import 'dart:async';
import 'dart:io';
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
    throw UnsupportedError('全校课表由服务端 SQLite 数据集提供');
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
      final affectedOfferingIds = <String>{};
      final courseIdsNeedingRebuild = <String>{};
      for (final change in changes) {
        _collectAffectedOfferings(
          change,
          affectedOfferingIds,
          courseIdsNeedingRebuild,
        );
        if (change.operation == 'delete') {
          await _deleteEntity(change.entityType, change.entityId);
          continue;
        }
        if (change.operation == 'upsert') {
          await _upsertEntity(change);
        }
      }
      // 如果课程元数据变了，需要补全该课程下所有教学班的 offering_id。
      if (courseIdsNeedingRebuild.isNotEmpty) {
        final placeholders = List.filled(
          courseIdsNeedingRebuild.length,
          '?',
        ).join(',');
        final rows = await _db
            .customSelect(
              'SELECT id FROM school_timetable_offerings WHERE course_id IN ($placeholders)',
              variables: courseIdsNeedingRebuild
                  .map((id) => Variable.withString(id))
                  .toList(),
            )
            .get();
        for (final row in rows) {
          affectedOfferingIds.add(_readString(row, 'id'));
        }
      }
      await _updateSearchIndexForOfferings(affectedOfferingIds);
      await _writeMeta('dataset_version', version.toString());
      await _writeMeta('dataset_checksum', checksum);
      await _writeMeta(
        'updated_at',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    });
  }

  @override
  Future<void> replaceFromBundle({
    required int version,
    required String checksum,
    required File sqliteGzipFile,
  }) async {
    final tempDir = await sqliteGzipFile.parent.createTemp(
      'school-timetable-bundle-',
    );
    final sqliteFile = File(
      '${tempDir.path}${Platform.pathSeparator}bundle.sqlite',
    );
    try {
      final compressed = await sqliteGzipFile.readAsBytes();
      await sqliteFile.writeAsBytes(gzip.decode(compressed), flush: true);
      // 规范做法：ATTACH/DETACH 是“数据源管理”动作，须在业务事务之外执行。
      // SQLite 规定“事务活动期不允许 DETACH 仍被使用的附加库”（否则报 database bundle is locked），
      // 故只把“清表+复制+建索引+写元数据”这些纯业务写包进事务，ATTACH 与 DETACH 放事务外。
      await _db.customStatement(
        'ATTACH DATABASE ${_sqlString(sqliteFile.path)} AS bundle',
      );
      try {
        await _db.transaction(() async {
          await _clearSchoolTimetableTables();
          for (final table in _bundleCopyTables) {
            await _db.customStatement(
              'INSERT INTO $table SELECT * FROM bundle.$table',
            );
          }
          await _rebuildSearchIndex();
          await _writeMeta('dataset_version', version.toString());
          await _writeMeta('dataset_checksum', checksum);
          await _writeMeta(
            'updated_at',
            DateTime.now().millisecondsSinceEpoch.toString(),
          );
        });
      } finally {
        // 事务已提交（或回滚干净）后再取下附加库，此时无活动事务，SQLite 爽快放行。
        await _db.customStatement('DETACH DATABASE bundle');
      }
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  @override
  Future<List<SchoolTimetableTerm>> loadTerms() async {
    final rows = await _db.customSelect('''
          SELECT term_key, school_year, term, first_week_monday, source_version,
                 row_count, imported_at, updated_at
          FROM school_timetable_terms
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

  /// 课程头搜索：以 school_timetable_offerings 为主表，GROUP BY term_course_id 聚合。
  /// 使用预聚合 LEFT JOIN 替代关联子查询，避免 N² 性能问题。
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
    final keyword = query.keyword.trim();
    final teacherSub = preAggregatedTeacherSummarySubquery;
    final weekdaySub = preAggregatedWeekdaySummarySubquery;
    final advanced = _advancedExistsClause(query);
    final advancedClause = advanced.sql;
    final advancedVariables = advanced.variables;

    final rows = keyword.isNotEmpty
        ? await db.customSelect(
            '''
          SELECT o.term_course_id AS id, o.term_key, o.course_id, cc.course_no, cc.course_name,
                 o.open_college, cc.credits, o.course_nature, o.course_category, o.open_type,
                 COUNT(*) AS teaching_class_count,
                 COALESCE(t_agg.teacher_summary, '') AS teacher_summary,
                 COALESCE(m_agg.weekday_summary, '') AS weekday_summary,
                 MAX(o.search_text) AS search_text
          FROM school_timetable_offerings o
          JOIN school_timetable_courses cc ON cc.id = o.course_id
          LEFT JOIN ($teacherSub) t_agg ON t_agg.offering_id = o.id
          LEFT JOIN ($weekdaySub) m_agg ON m_agg.offering_id = o.id
          WHERE o.term_key = ?
            AND (
              o.term_course_id IN (
                SELECT term_course_id
                FROM school_timetable_search_fts
                WHERE term_key = ?
                  AND school_timetable_search_fts MATCH ?
              )
              OR cc.course_name LIKE ? ESCAPE char(92)
              OR cc.course_no LIKE ? ESCAPE char(92)
              OR o.search_text LIKE ? ESCAPE char(92)
              OR o.open_college LIKE ? ESCAPE char(92)
              OR o.course_nature LIKE ? ESCAPE char(92)
              OR o.course_category LIKE ? ESCAPE char(92)
              OR o.teaching_class_name LIKE ? ESCAPE char(92)
            )
            $advancedClause
          GROUP BY o.term_course_id
          ORDER BY
            CASE
              WHEN cc.course_name = ? OR cc.course_no = ? THEN 0
              WHEN cc.course_name LIKE ? ESCAPE char(92)
                OR cc.course_no LIKE ? ESCAPE char(92) THEN 1
              WHEN cc.course_name LIKE ? ESCAPE char(92)
                OR cc.course_no LIKE ? ESCAPE char(92)
                OR o.search_text LIKE ? ESCAPE char(92)
                OR o.open_college LIKE ? ESCAPE char(92)
                OR o.course_nature LIKE ? ESCAPE char(92)
                OR o.course_category LIKE ? ESCAPE char(92)
                OR o.teaching_class_name LIKE ? ESCAPE char(92) THEN 2
              ELSE 3
            END,
            teaching_class_count DESC,
            cc.course_name ASC
          LIMIT 80
          ''',
            variables: _courseSearchVariables(
              termKey: termKey,
              keyword: keyword,
              advancedVariables: advancedVariables,
            ),
          ).get()
        : await db.customSelect(
            '''
          SELECT o.term_course_id AS id, o.term_key, o.course_id, cc.course_no, cc.course_name,
                 o.open_college, cc.credits, o.course_nature, o.course_category, o.open_type,
                 COUNT(*) AS teaching_class_count,
                 COALESCE(t_agg.teacher_summary, '') AS teacher_summary,
                 COALESCE(m_agg.weekday_summary, '') AS weekday_summary,
                 MAX(o.search_text) AS search_text
          FROM school_timetable_offerings o
          JOIN school_timetable_courses cc ON cc.id = o.course_id
          LEFT JOIN ($teacherSub) t_agg ON t_agg.offering_id = o.id
          LEFT JOIN ($weekdaySub) m_agg ON m_agg.offering_id = o.id
          WHERE o.term_key = ?
            $advancedClause
          GROUP BY o.term_course_id
          ORDER BY teaching_class_count DESC
          LIMIT 80
          ''',
            variables: _courseSearchVariables(
              termKey: termKey,
              keyword: keyword,
              noKeyword: true,
              advancedVariables: advancedVariables,
            ),
          ).get();
    return rows.map(_courseHeadFromRow).toList(growable: false);
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
    final teacherAgg = _teacherAggregateSelect();
    final weekdayAgg = _weekdayAggregateSelect();
    final row = await db
        .customSelect(
          '''
          SELECT o.term_course_id AS id, o.term_key, o.course_id, cc.course_no, cc.course_name,
                 o.open_college, cc.credits, o.course_nature, o.course_category, o.open_type,
                 COUNT(*) AS teaching_class_count,
                 $teacherAgg AS teacher_summary,
                 $weekdayAgg AS weekday_summary,
                 MAX(o.search_text) AS search_text
          FROM school_timetable_offerings o
          JOIN school_timetable_courses cc ON cc.id = o.course_id
          WHERE o.term_course_id = ?
          GROUP BY o.term_course_id
          ''',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _courseHeadFromRow(row);
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
    // 两阶段查询：先取该课程的所有 offering_id，让后续预聚合子查询
    // 只扫描相关行（配合 offering_id 索引，避免全表聚合）。
    final idRows = await db
        .customSelect(
          'SELECT id FROM school_timetable_offerings WHERE term_course_id = ?',
          variables: [Variable.withString(courseHeadId)],
        )
        .get();
    if (idRows.isEmpty) {
      return const [];
    }
    final offeringIds = idRows.map((r) => _readString(r, 'id')).toList();
    final instructorSub = preAggregatedInstructorAndTitleSubquery(offeringIds);
    final scheduleSub = preAggregatedScheduleSummarySubquery(offeringIds);
    final weekdaySub = preAggregatedWeekdayForOfferingSubquery(offeringIds);
    final offeringIdVars = offeringIds.map(Variable.withString).toList();
    final rows = await db.customSelect('''
          SELECT o.*,
                 cc.course_no, cc.course_name, cc.credits,
                 COALESCE(
                   (SELECT GROUP_CONCAT(DISTINCT grade)
                    FROM school_timetable_audiences
                    WHERE offering_id = o.id), ''
                 ) AS grade,
                 COALESCE(
                   (SELECT GROUP_CONCAT(DISTINCT major)
                    FROM school_timetable_audiences
                    WHERE offering_id = o.id), ''
                 ) AS major,
                 COALESCE(
                   (SELECT GROUP_CONCAT(DISTINCT plan_college)
                    FROM school_timetable_audiences
                    WHERE offering_id = o.id), ''
                 ) AS plan_college,
                 COALESCE(it.instructor, '') AS instructor,
                 COALESCE(it.title, '') AS title,
                 COALESCE(sa.schedule_summary, '') AS schedule_summary,
                 COALESCE(wa.weekday_summary, '') AS weekday_summary
          FROM school_timetable_offerings o
          JOIN school_timetable_courses cc ON cc.id = o.course_id
          LEFT JOIN ($instructorSub) it ON it.offering_id = o.id
          LEFT JOIN ($scheduleSub) sa ON sa.offering_id = o.id
          LEFT JOIN ($weekdaySub) wa ON wa.offering_id = o.id
          WHERE o.id IN (${List.filled(offeringIds.length, '?').join(',')})
          ORDER BY COALESCE(it.instructor, ''), o.teaching_class_name
          ''', variables: offeringIdVars).get();
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
    final instructorSub = preAggregatedInstructorAndTitleSubquery([id]);
    final scheduleSub = preAggregatedScheduleSummarySubquery([id]);
    final weekdaySub = preAggregatedWeekdayForOfferingSubquery([id]);
    final row = await db
        .customSelect(
          '''
          SELECT o.*,
                 cc.course_no, cc.course_name, cc.credits,
                 COALESCE(
                   (SELECT GROUP_CONCAT(DISTINCT grade)
                    FROM school_timetable_audiences
                    WHERE offering_id = o.id), ''
                 ) AS grade,
                 COALESCE(
                   (SELECT GROUP_CONCAT(DISTINCT major)
                    FROM school_timetable_audiences
                    WHERE offering_id = o.id), ''
                 ) AS major,
                 COALESCE(
                   (SELECT GROUP_CONCAT(DISTINCT plan_college)
                    FROM school_timetable_audiences
                    WHERE offering_id = o.id), ''
                 ) AS plan_college,
                 COALESCE(it.instructor, '') AS instructor,
                 COALESCE(it.title, '') AS title,
                 COALESCE(sa.schedule_summary, '') AS schedule_summary,
                 COALESCE(wa.weekday_summary, '') AS weekday_summary
          FROM school_timetable_offerings o
          JOIN school_timetable_courses cc ON cc.id = o.course_id
          LEFT JOIN ($instructorSub) it ON it.offering_id = o.id
          LEFT JOIN ($scheduleSub) sa ON sa.offering_id = o.id
          LEFT JOIN ($weekdaySub) wa ON wa.offering_id = o.id
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
    final rows = await db
        .customSelect(
          '''
          SELECT m.*
          FROM school_timetable_meetings m
          WHERE m.offering_id = ?
          ORDER BY m.weekday, m.segment_index
          ''',
          variables: [Variable.withString(teachingClassId)],
        )
        .get();
    return rows.map(_meetingFromRow).toList(growable: false);
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

    final termCourseId = await _matchTermCourse(db, query);
    final weekIndex = await _weekIndexForDate(db, query);
    final offering = await _matchOffering(db, query, weekIndex: weekIndex);
    if (offering == null) {
      return CourseEntityLink(termCourseId: termCourseId);
    }

    final meetingId = _readString(offering, 'matched_meeting_id');
    final occurrenceId = meetingId.isEmpty || weekIndex == null
        ? ''
        : '$meetingId:$weekIndex';
    return CourseEntityLink(
      termCourseId: _readString(offering, 'term_course_id').isNotEmpty
          ? _readString(offering, 'term_course_id')
          : termCourseId,
      offeringId: _readString(offering, 'id'),
      teacherId: _readString(offering, 'matched_teacher_id'),
      occurrenceId: occurrenceId,
    );
  }

  Future<String> _matchTermCourse(
    GeneratedDatabase db,
    PersonalCourseMatchQuery query,
  ) async {
    final rows = await db
        .customSelect(
          '''
          SELECT DISTINCT o.term_course_id AS id, cc.course_name
          FROM school_timetable_offerings o
          JOIN school_timetable_courses cc ON cc.id = o.course_id
          WHERE o.term_key = ? AND cc.course_no = ?
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
  }) async {
    final sectionRange = _sectionRange(query.sectionText);
    final meetingClauses = <String>[];
    final variables = <Variable>[
      Variable.withString(query.termKey.trim()),
      Variable.withString(query.courseNo.trim()),
      Variable.withInt(query.weekday),
    ];
    if (weekIndex != null) {
      meetingClauses.add('m.week_indexes LIKE ?');
      variables.add(Variable.withString('%"$weekIndex"%'));
    }
    if (sectionRange != null) {
      meetingClauses.add('m.section_start <= ? AND m.section_end >= ?');
      variables.add(Variable.withInt(sectionRange.end));
      variables.add(Variable.withInt(sectionRange.start));
    }
    final rows = await db.customSelect('''
          SELECT o.*,
                 m.id AS matched_meeting_id,
                 m.location_text AS matched_location_text,
                 $teacherAggregateMain AS instructor,
                 ot.teacher_id AS matched_teacher_id
          FROM school_timetable_offerings o
          JOIN school_timetable_courses cc ON cc.id = o.course_id
          JOIN school_timetable_meetings m ON m.offering_id = o.id
          LEFT JOIN school_timetable_offering_teachers ot
            ON ot.offering_id = o.id AND ot.role = 'main' AND ot.ordinal = 0
          WHERE o.term_key = ?
            AND cc.course_no = ?
            AND m.weekday = ?
            ${meetingClauses.isEmpty ? '' : 'AND ${meetingClauses.join(' AND ')}'}
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
          if (_normalizeName(_readString(row, 'instructor')) == instructor) row,
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
          FROM school_timetable_terms
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

  /// 高级筛选：把课程头（GROUP BY 后的 term_course_id）限制到至少有一个教学班
  /// 满足课程、教师、部门、学生范围、类别、类型、性质等条件。该子查询在主 GROUP BY 的 WHERE 上叠加，
  /// 引用主查询的 o 表别名。返回 SQL 片段与对应绑定变量，由调用方显式拼接。
  ({String sql, List<Variable> variables}) _advancedExistsClause(
    AllSchoolTimetableQuery query,
  ) {
    if (!query.hasAdvancedFilters) {
      return (sql: '', variables: const <Variable>[]);
    }
    final conditions = <String>[];
    final variables = <Variable>[];

    void addLike(String column, String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }
      conditions.add('$column LIKE ?');
      variables.add(Variable.withString('%$normalized%'));
    }

    void addEquals(String column, String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }
      conditions.add('$column = ?');
      variables.add(Variable.withString(normalized));
    }

    addLike('cc_sub.course_name', query.courseName);
    addLike('t.name', query.teacher);
    addLike('sub.teaching_class_name', query.teachingClass);
    addEquals('sub.open_college', query.openDepartment);
    addEquals('aud.plan_college', query.studentCollege);
    addLike('aud.grade', query.grade);
    addLike('aud.major', query.major);
    addEquals('sub.course_category', query.courseCategory);
    final departmentOrCollege = query.departmentOrCollege.trim();
    if (departmentOrCollege.isNotEmpty) {
      conditions.add('(sub.open_college = ? OR aud.plan_college = ?)');
      variables
        ..add(Variable.withString(departmentOrCollege))
        ..add(Variable.withString(departmentOrCollege));
    }
    addEquals('sub.open_type', query.openType);
    addEquals('sub.course_nature', query.courseNature);
    if (conditions.isEmpty) {
      return (sql: '', variables: const <Variable>[]);
    }

    return (
      sql:
          '''
      AND EXISTS (
        SELECT 1
        FROM school_timetable_offerings sub
        JOIN school_timetable_courses cc_sub ON cc_sub.id = sub.course_id
        LEFT JOIN school_timetable_audiences aud ON aud.offering_id = sub.id
        LEFT JOIN school_timetable_offering_teachers ot ON ot.offering_id = sub.id
        LEFT JOIN school_timetable_teachers t ON t.id = ot.teacher_id
        WHERE sub.term_course_id = o.term_course_id
          AND ${conditions.join(' AND ')}
      )
    ''',
      variables: variables,
    );
  }

  String _teacherAggregateSelect() {
    return '''
      (SELECT GROUP_CONCAT(name, '、')
       FROM (
         SELECT DISTINCT t_inner.name
         FROM school_timetable_offering_teachers ot_inner
         JOIN school_timetable_teachers t_inner ON t_inner.id = ot_inner.teacher_id
         WHERE ot_inner.offering_id = o.id
       ))
    ''';
  }

  String _weekdayAggregateSelect() {
    return '''
      (SELECT GROUP_CONCAT(weekday_label, '、')
       FROM (
         SELECT m.weekday_label
         FROM school_timetable_meetings m
         WHERE m.offering_id IN (SELECT id FROM school_timetable_offerings WHERE term_course_id = o.term_course_id)
           AND m.weekday_label != ''
         GROUP BY m.weekday, m.weekday_label
         ORDER BY m.weekday
       ))
    ''';
  }

  String get teacherAggregateMain => '''
      (SELECT t_main.name
       FROM school_timetable_offering_teachers ot_main
       JOIN school_timetable_teachers t_main ON t_main.id = ot_main.teacher_id
       WHERE ot_main.offering_id = o.id AND ot_main.role = 'main' AND ot_main.ordinal = 0
       LIMIT 1)
  ''';

  String get teacherAggregateMainTitle => '''
      (SELECT ot_main.title
       FROM school_timetable_offering_teachers ot_main
       WHERE ot_main.offering_id = o.id AND ot_main.role = 'main' AND ot_main.ordinal = 0
       LIMIT 1)
  ''';

  String get scheduleAggregateSelect => '''
      (SELECT GROUP_CONCAT(schedule_entry, '；')
       FROM (
         SELECT m.weekday_label || ' ' || m.section_text || COALESCE(' ' || NULLIF(m.location_text, ''), '') AS schedule_entry
         FROM school_timetable_meetings m
         WHERE m.offering_id = o.id
           AND m.section_text != ''
         ORDER BY m.weekday, m.segment_index
       ))
  ''';

  String get weekdayAggregateForOffering => '''
      (SELECT GROUP_CONCAT(weekday_label, '、')
       FROM (
         SELECT m.weekday_label
         FROM school_timetable_meetings m
         WHERE m.offering_id = o.id
           AND m.weekday_label != ''
         GROUP BY m.weekday, m.weekday_label
         ORDER BY m.weekday
       ))
  ''';

  // ── 预聚合子查询片段（供 LEFT JOIN 使用，消除关联子查询的 N² 行为） ──

  String _offeringIdInClause(List<String> offeringIds) {
    if (offeringIds.length == 1) {
      return "offering_id = '${offeringIds.single.replaceAll("'", "''")}'";
    }
    return 'offering_id IN (${offeringIds.map((id) => "'${id.replaceAll("'", "''")}'").join(', ')})';
  }

  /// 按 offering_id 预聚合教师姓名（用于课程头搜索）。
  /// 返回可嵌入 LEFT JOIN 的子查询 SQL。
  String get preAggregatedTeacherSummarySubquery => '''
    SELECT ot_inner.offering_id,
           GROUP_CONCAT(t_inner.name, '、') AS teacher_summary
    FROM (
      SELECT offering_id, teacher_id
      FROM school_timetable_offering_teachers
      ORDER BY offering_id, teacher_id
      LIMIT -1 OFFSET 0
    ) ot_inner
    JOIN school_timetable_teachers t_inner ON t_inner.id = ot_inner.teacher_id
    GROUP BY ot_inner.offering_id
  ''';

  /// 按 offering_id 预聚合星期标签（用于课程头搜索）。
  /// 内层去重 + 排序，外层按 offering_id 拼接。
  String get preAggregatedWeekdaySummarySubquery => '''
    SELECT offering_id,
           GROUP_CONCAT(weekday_label, '、') AS weekday_summary
    FROM (
      SELECT offering_id, weekday, weekday_label
      FROM school_timetable_meetings
      WHERE weekday_label != ''
      GROUP BY offering_id, weekday, weekday_label
      ORDER BY offering_id, weekday
      LIMIT -1 OFFSET 0
    )
    GROUP BY offering_id
  ''';

  /// 按 offering_id 预聚合主讲教师姓名与职称（限定到指定 offering 集合）。
  String preAggregatedInstructorAndTitleSubquery(List<String> offeringIds) =>
      '''
    SELECT ot_main.offering_id,
           MAX(t_main.name) AS instructor,
           MAX(ot_main.title) AS title
    FROM school_timetable_offering_teachers ot_main
    JOIN school_timetable_teachers t_main ON t_main.id = ot_main.teacher_id
    WHERE ${_offeringIdInClause(offeringIds)}
      AND ot_main.role = 'main' AND ot_main.ordinal = 0
    GROUP BY ot_main.offering_id
  ''';

  /// 按 offering_id 预聚合课程时间表摘要（限定到指定 offering 集合）。
  /// 内层按 weekday + segment_index 排序，外层 GROUP_CONCAT 保持顺序。
  String preAggregatedScheduleSummarySubquery(List<String> offeringIds) =>
      '''
    SELECT offering_id,
           GROUP_CONCAT(schedule_entry, '；') AS schedule_summary
    FROM (
      SELECT offering_id,
             weekday_label || ' ' || section_text
               || COALESCE(' ' || NULLIF(location_text, ''), '') AS schedule_entry,
             weekday, segment_index
      FROM school_timetable_meetings
      WHERE ${_offeringIdInClause(offeringIds)}
        AND section_text != ''
      ORDER BY offering_id, weekday, segment_index
      LIMIT -1 OFFSET 0
    )
    GROUP BY offering_id
  ''';

  /// 按 offering_id 预聚合星期标签（限定到指定 offering 集合）。
  String preAggregatedWeekdayForOfferingSubquery(List<String> offeringIds) =>
      '''
    SELECT offering_id,
           GROUP_CONCAT(weekday_label, '、') AS weekday_summary
    FROM (
      SELECT offering_id, weekday, weekday_label
      FROM school_timetable_meetings
      WHERE ${_offeringIdInClause(offeringIds)}
        AND weekday_label != ''
      GROUP BY offering_id, weekday, weekday_label
      ORDER BY offering_id, weekday
      LIMIT -1 OFFSET 0
    )
    GROUP BY offering_id
  ''';

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

  List<Variable> _courseSearchVariables({
    required String termKey,
    required String keyword,
    bool noKeyword = false,
    List<Variable> advancedVariables = const [],
  }) {
    if (noKeyword) {
      return [Variable.withString(termKey), ...advancedVariables];
    }
    final containsPattern = _likePattern(keyword);
    final prefixPattern = _likePattern(keyword, suffixOnly: true);
    return [
      Variable.withString(termKey),
      Variable.withString(termKey),
      Variable.withString(_ftsQuery(keyword)),
      for (var i = 0; i < 7; i++) Variable.withString(containsPattern),
      ...advancedVariables,
      Variable.withString(keyword),
      Variable.withString(keyword),
      Variable.withString(prefixPattern),
      Variable.withString(prefixPattern),
      for (var i = 0; i < 7; i++) Variable.withString(containsPattern),
    ];
  }

  String _likePattern(String keyword, {bool suffixOnly = false}) {
    final escaped = keyword
        .replaceAll('\\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    return suffixOnly ? '$escaped%' : '%$escaped%';
  }

  SchoolCourseHead _courseHeadFromRow(QueryRow row) {
    return SchoolCourseHead(
      id: _readString(row, 'id'),
      termKey: _readString(row, 'term_key'),
      courseId: _readString(row, 'course_id'),
      courseNo: _readString(row, 'course_no'),
      courseName: _readString(row, 'course_name'),
      openCollege: _readString(row, 'open_college'),
      credits: _readDoubleOrString(row, 'credits'),
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
      termCourseId: _readString(row, 'term_course_id'),
      courseId: _readString(row, 'course_id'),
      teachingClassName: _readString(row, 'teaching_class_name'),
      courseNo: _readString(row, 'course_no'),
      courseName: _readString(row, 'course_name'),
      openCollege: _readString(row, 'open_college'),
      planCollege: _readString(row, 'plan_college'),
      credits: _readDoubleOrString(row, 'credits'),
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
      theoryHours: _intHoursOrString(row, 'theory_hours'),
      computerHours: _intHoursOrString(row, 'computer_hours'),
      experimentHours: _intHoursOrString(row, 'experiment_hours'),
      practiceHours: _intHoursOrString(row, 'practice_hours'),
      remark: _readString(row, 'remark'),
      note: _readString(row, 'note'),
      otherTeachers: _readString(row, 'other_teachers'),
      textbook: _readString(row, 'textbook'),
      publisher: _readString(row, 'publisher'),
      scheduleSummary: _readString(row, 'schedule_summary'),
      weekdaySummary: _readString(row, 'weekday_summary'),
    );
  }

  SchoolClassMeeting _meetingFromRow(QueryRow row) {
    return SchoolClassMeeting(
      id: _readString(row, 'id'),
      offeringId: _readString(row, 'offering_id'),
      weekday: _readInt(row, 'weekday'),
      weekdayLabel: _readString(row, 'weekday_label'),
      rawText: _readString(row, 'raw_segment_text'),
      weekText: _readString(row, 'week_text'),
      sectionText: _readString(row, 'section_text'),
      locationText: _readString(row, 'location_text'),
      weekIndexes: _decodeIntList(_readString(row, 'week_indexes')),
    );
  }

  Future<GeneratedDatabase?> _databaseForTerm(String termKey) async {
    final row = await _db
        .customSelect(
          'SELECT 1 FROM school_timetable_terms WHERE term_key = ? LIMIT 1',
          variables: [Variable.withString(termKey)],
        )
        .getSingleOrNull();
    return row == null ? null : _db;
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

  Future<void> _clearSchoolTimetableTables() async {
    for (final table in _bundleCopyTables.reversed) {
      await _db.customStatement('DELETE FROM $table');
    }
  }

  Future<void> _upsertEntity(SchoolTimetableChange change) async {
    final p = change.payload;
    switch (change.entityType) {
      case 'term':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_terms
          (term_key, school_year, term, school_year_code, term_code, first_week_monday,
           source_version, row_count, imported_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'school_year'),
            _stringPayload(p, 'term'),
            _stringPayload(p, 'school_year_code'),
            _stringPayload(p, 'term_code'),
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
          (id, course_no, course_name, credits)
          VALUES (?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'course_no'),
            _stringPayload(p, 'course_name'),
            _stringPayload(p, 'credits'),
          ],
        );
      case 'teacher':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_teachers
          (id, name, name_key, seq)
          VALUES (?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'name'),
            _stringPayload(p, 'name_key'),
            _intPayload(p, 'seq'),
          ],
        );
      case 'offering':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_offerings
          (id, term_key, course_id, term_course_id, source_key, teaching_class_name,
           open_college, college_id, open_dept_id, course_nature, course_category, open_type,
           people_raw, capacity, selected_count, theory_hours, computer_hours,
           experiment_hours, practice_hours, remark, note, other_teachers,
           textbook, publisher, search_text)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'term_key'),
            _stringPayload(p, 'course_id'),
            _stringPayload(p, 'term_course_id'),
            _stringPayload(p, 'source_key'),
            _stringPayload(p, 'teaching_class_name'),
            _stringPayload(p, 'open_college'),
            _stringPayload(p, 'college_id'),
            _stringPayload(p, 'open_dept_id'),
            _stringPayload(p, 'course_nature'),
            _stringPayload(p, 'course_category'),
            _stringPayload(p, 'open_type'),
            _stringPayload(p, 'people_raw'),
            _intPayload(p, 'capacity'),
            _intPayload(p, 'selected_count'),
            _stringPayload(p, 'theory_hours'),
            _stringPayload(p, 'computer_hours'),
            _stringPayload(p, 'experiment_hours'),
            _stringPayload(p, 'practice_hours'),
            _stringPayload(p, 'remark'),
            _stringPayload(p, 'note'),
            _stringPayload(p, 'other_teachers'),
            _stringPayload(p, 'textbook'),
            _stringPayload(p, 'publisher'),
            _stringPayload(p, 'search_text'),
          ],
        );
      case 'offering_teacher':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_offering_teachers
          (id, offering_id, teacher_id, role, title, ordinal)
          VALUES (?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'offering_id'),
            _stringPayload(p, 'teacher_id'),
            _stringPayload(p, 'role'),
            _stringPayload(p, 'title'),
            _intPayload(p, 'ordinal'),
          ],
        );
      case 'audience':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_audiences
          (id, term_key, offering_id, grade, grade_code, major, major_code, plan_college,
           course_nature_code, course_category_code, open_type_code, condition_code)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            change.entityId,
            _stringPayload(p, 'term_key'),
            _stringPayload(p, 'offering_id'),
            _stringPayload(p, 'grade'),
            _stringPayload(p, 'grade_code'),
            _stringPayload(p, 'major'),
            _stringPayload(p, 'major_code'),
            _stringPayload(p, 'plan_college'),
            _stringPayload(p, 'course_nature_code'),
            _stringPayload(p, 'course_category_code'),
            _stringPayload(p, 'open_type_code'),
            _stringPayload(p, 'condition_code'),
          ],
        );
      case 'meeting':
        await _db.customStatement(
          '''
          INSERT OR REPLACE INTO school_timetable_meetings
          (id, offering_id, term_key, weekday, day_field, segment_index, weekday_label,
           raw_day_text, raw_segment_text, week_text, section_text, section_start,
           section_end, location_text, week_indexes, parse_status)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
            jsonEncode(
              p['week_indexes'] is List ? p['week_indexes'] : const [],
            ),
            _stringPayload(p, 'parse_status'),
          ],
        );
    }
  }

  Future<void> _deleteEntity(String entityType, String entityId) async {
    switch (entityType) {
      case 'term':
        await _db.customStatement(
          'DELETE FROM school_timetable_terms WHERE term_key = ?',
          [entityId],
        );
      case 'course':
        await _db.customStatement(
          'DELETE FROM school_timetable_courses WHERE id = ?',
          [entityId],
        );
      case 'teacher':
        await _db.customStatement(
          'DELETE FROM school_timetable_teachers WHERE id = ?',
          [entityId],
        );
      case 'offering':
        await _db.customStatement(
          'DELETE FROM school_timetable_offerings WHERE id = ?',
          [entityId],
        );
      case 'offering_teacher':
        await _db.customStatement(
          'DELETE FROM school_timetable_offering_teachers WHERE id = ?',
          [entityId],
        );
      case 'audience':
        await _db.customStatement(
          'DELETE FROM school_timetable_audiences WHERE id = ?',
          [entityId],
        );
      case 'meeting':
        await _db.customStatement(
          'DELETE FROM school_timetable_meetings WHERE id = ?',
          [entityId],
        );
    }
  }

  Future<void> _rebuildSearchIndex() async {
    await _db.customStatement('DELETE FROM school_timetable_search_fts');
    await _db.customStatement('''
      INSERT INTO school_timetable_search_fts
      (offering_id, term_key, term_course_id, course_name, course_no, open_college,
       teaching_class_name, search_text)
      SELECT o.id, o.term_key, o.term_course_id, c.course_name, c.course_no,
             o.open_college, o.teaching_class_name, o.search_text
      FROM school_timetable_offerings o
      JOIN school_timetable_courses c ON c.id = o.course_id
    ''');
  }

  /// 收集单次变更影响到的 offering_id（用于增量 FTS 更新）。
  void _collectAffectedOfferings(
    SchoolTimetableChange change,
    Set<String> offeringIds,
    Set<String> courseIdsNeedingRebuild,
  ) {
    final p = change.payload;
    switch (change.entityType) {
      case 'offering':
        offeringIds.add(change.entityId);
      case 'offering_teacher':
      case 'audience':
      case 'meeting':
        final oid = p['offering_id']?.toString();
        if (oid != null && oid.isNotEmpty) {
          offeringIds.add(oid);
        }
      case 'course':
        // 课程名称变更 → 需要重建该课程下所有教学班的 FTS 行。
        courseIdsNeedingRebuild.add(change.entityId);
    }
  }

  /// 仅对受影响的 offering 增量更新 FTS 索引（先删后插）。
  Future<void> _updateSearchIndexForOfferings(Set<String> offeringIds) async {
    if (offeringIds.isEmpty) return;
    final ids = offeringIds.toList();
    final placeholders = List.filled(ids.length, '?').join(',');
    final args = ids.cast<dynamic>();
    await _db.customStatement(
      'DELETE FROM school_timetable_search_fts WHERE offering_id IN ($placeholders)',
      args,
    );
    await _db.customStatement('''
      INSERT INTO school_timetable_search_fts
      (offering_id, term_key, term_course_id, course_name, course_no, open_college,
       teaching_class_name, search_text)
      SELECT o.id, o.term_key, o.term_course_id, c.course_name, c.course_no,
             o.open_college, o.teaching_class_name, o.search_text
      FROM school_timetable_offerings o
      JOIN school_timetable_courses c ON c.id = o.course_id
      WHERE o.id IN ($placeholders)
      ''', args);
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

  double? _readDoubleOrString(QueryRow row, String column) {
    final value = row.data[column];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? _intHoursOrString(QueryRow row, String column) {
    final value = row.data[column];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
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

  List<int> _decodeIntList(String raw) {
    if (raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .map((item) => item is int ? item : int.tryParse('$item') ?? 0)
        .whereType<int>()
        .toList(growable: false);
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

class _SectionRange {
  const _SectionRange({required this.start, required this.end});

  final int start;
  final int end;
}

const _bundleCopyTables = [
  'school_timetable_terms',
  'school_timetable_courses',
  'school_timetable_teachers',
  'school_timetable_offerings',
  'school_timetable_offering_teachers',
  'school_timetable_audiences',
  'school_timetable_meetings',
];

String _sqlString(String value) {
  return "'${value.replaceAll("'", "''")}'";
}
