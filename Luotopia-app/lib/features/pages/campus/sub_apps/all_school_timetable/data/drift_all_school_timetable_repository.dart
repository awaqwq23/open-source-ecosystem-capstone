import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

final allSchoolTimetableRepositoryProvider =
    Provider<AllSchoolTimetableRepository>((ref) {
      final repository = DriftAllSchoolTimetableRepository(
        ref.read(sharedPreferencesProvider),
      );
      ref.onDispose(() {
        unawaited(repository.dispose());
      });
      return repository;
    });

class DriftAllSchoolTimetableRepository
    implements AllSchoolTimetableRepository {
  DriftAllSchoolTimetableRepository(this._preferences);

  static const _artifactIndexKey = 'school_timetable.artifact.index';

  final SharedPreferences? _preferences;
  final Map<String, _SchoolTimetableArtifactDatabase> _openDbs = {};
  final Map<String, String> _openPaths = {};

  @override
  Future<void> ensureLocalDataReady() async {
    _readArtifactIndex();
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
  Future<void> replaceTermFromArtifactFile({
    required File gzipFile,
    required String termKey,
    required int version,
    required String checksum,
    required int rowCount,
  }) async {
    final dir = await _artifactDirectory();
    final tempDb = File('${dir.path}${Platform.pathSeparator}incoming.sqlite');
    final target = File(
      '${dir.path}${Platform.pathSeparator}${_safeName(termKey)}-v$version.sqlite',
    );
    if (await tempDb.exists()) {
      await tempDb.delete();
    }
    await gzipFile.openRead().transform(gzip.decoder).pipe(tempDb.openWrite());
    try {
      final entry = _validateArtifact(
        tempDb,
        termKey: termKey,
        version: version,
        rowCount: rowCount,
      );
      if (target.path != tempDb.path && await target.exists()) {
        await target.delete();
      }
      await tempDb.rename(target.path);
      await _closeDbForTerm(termKey);
      final index = _readArtifactIndex();
      index[termKey] = entry.copyWith(path: target.path, checksum: checksum);
      await _writeArtifactIndex(index);
    } catch (_) {
      if (await tempDb.exists()) {
        await tempDb.delete();
      }
      rethrow;
    }
  }

  @override
  Future<void> retainActiveTerms(Set<String> termKeys) async {
    final index = _readArtifactIndex();
    final removed = [
      for (final entry in index.entries)
        if (!termKeys.contains(entry.key)) entry,
    ];
    if (removed.isEmpty) {
      return;
    }
    for (final entry in removed) {
      await _closeDbForTerm(entry.key);
      final file = File(entry.value.path);
      if (await file.exists()) {
        await file.delete();
      }
      index.remove(entry.key);
    }
    await _writeArtifactIndex(index);
  }

  @override
  Future<List<SchoolTimetableTerm>> loadTerms() async {
    final entries = _readArtifactIndex().values.toList(growable: false)
      ..sort((a, b) => b.termKey.compareTo(a.termKey));
    return [
      for (final entry in entries)
        SchoolTimetableTerm(
          termKey: entry.termKey,
          schoolYear: entry.schoolYear,
          term: entry.term,
          firstWeekMonday: entry.firstWeekMonday,
          sourceVersion: entry.version.toString(),
          rowCount: entry.rowCount,
          importedAt: entry.updatedAt,
          updatedAt: entry.updatedAt,
        ),
    ];
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
    _SchoolTimetableArtifactDatabase db,
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
    _SchoolTimetableArtifactDatabase db,
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
    _SchoolTimetableArtifactDatabase db,
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

  Future<_SchoolTimetableArtifactDatabase?> _databaseForTerm(
    String termKey,
  ) async {
    final entry = _readArtifactIndex()[termKey];
    final path = entry?.path ?? '';
    if (path.isEmpty || !await File(path).exists()) {
      await _closeDbForTerm(termKey);
      return null;
    }
    final existing = _openDbs[termKey];
    if (existing != null && _openPaths[termKey] == path) {
      return existing;
    }
    await _closeDbForTerm(termKey);
    _openPaths[termKey] = path;
    final db = _SchoolTimetableArtifactDatabase(
      NativeDatabase.createInBackground(
        File(path),
        enableMigrations: false,
        setup: (db) {
          db.execute('PRAGMA query_only = ON;');
        },
      ),
    );
    _openDbs[termKey] = db;
    return db;
  }

  _ArtifactSchema _schemaForDb(_SchoolTimetableArtifactDatabase db) {
    return _ArtifactSchema.v7;
  }

  Future<void> _closeDbForTerm(String termKey) async {
    final db = _openDbs.remove(termKey);
    _openPaths.remove(termKey);
    await db?.close();
  }

  Future<void> dispose() async {
    final dbs = List<_SchoolTimetableArtifactDatabase>.from(_openDbs.values);
    _openDbs.clear();
    _openPaths.clear();
    for (final db in dbs) {
      await db.close();
    }
  }

  Future<Directory> _artifactDirectory() async {
    final root = await getApplicationSupportDirectory();
    final dir = Directory(
      '${root.path}${Platform.pathSeparator}school_timetable_artifacts',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Map<String, _ArtifactEntry> _readArtifactIndex() {
    final raw = _preferences?.getString(_artifactIndexKey);
    if (raw == null || raw.isEmpty) {
      return const {};
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          entry.key: _ArtifactEntry.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      };
    } catch (_) {
      return const {};
    }
  }

  Future<void> _writeArtifactIndex(Map<String, _ArtifactEntry> index) async {
    await _preferences?.setString(
      _artifactIndexKey,
      jsonEncode({
        for (final entry in index.entries) entry.key: entry.value.toJson(),
      }),
    );
  }

  _ArtifactEntry _validateArtifact(
    File file, {
    required String termKey,
    required int version,
    required int rowCount,
  }) {
    final db = sqlite.sqlite3.open(file.path, mode: sqlite.OpenMode.readOnly);
    try {
      final meta = <String, String>{};
      for (final row in db.select(
        'SELECT key, value FROM school_timetable_meta',
      )) {
        meta[row['key'] as String] = row['value'].toString();
      }
      final schemaVersion = int.tryParse(meta['schema_version'] ?? '') ?? 0;
      if (schemaVersion != 7 ||
          meta['artifact_type'] != 'school_timetable_sqlite_gzip' ||
          meta['term_key'] != termKey ||
          meta['version'] != version.toString()) {
        throw const FormatException('全校课表 SQLite 快照元信息不匹配');
      }
      final termRows = db.select(
        '''
        SELECT term_key, school_year, term, first_week_monday, source_version,
               row_count, imported_at, updated_at
        FROM school_timetable_term_rows
        WHERE term_key = ?
        ''',
        [termKey],
      );
      if (termRows.length != 1 || termRows.first['row_count'] != rowCount) {
        throw const FormatException('全校课表 SQLite 快照课表统计不匹配');
      }
      for (final table in const [
        'school_timetable_courses',
        'school_timetable_course_terms',
        'school_timetable_instructors',
        'school_timetable_offerings',
        'school_timetable_audiences',
        'school_timetable_source_rows',
        'school_timetable_meeting_rules',
        'school_timetable_meeting_weeks',
        'school_timetable_search_fts',
      ]) {
        db.select('SELECT 1 FROM $table LIMIT 1');
      }
      final term = termRows.first;
      return _ArtifactEntry(
        termKey: termKey,
        path: file.path,
        version: version,
        checksum: '',
        schemaVersion: schemaVersion,
        schoolYear: term['school_year']?.toString() ?? '',
        term: term['term']?.toString() ?? '',
        firstWeekMonday: term['first_week_monday']?.toString() ?? '',
        rowCount: rowCount,
        updatedAt: _dateTimeFromMillis(term['updated_at']),
      );
    } finally {
      db.dispose();
    }
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

  String _safeName(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return sanitized.isEmpty ? 'unknown' : sanitized;
  }
}

class _ArtifactEntry {
  const _ArtifactEntry({
    required this.termKey,
    required this.path,
    required this.version,
    required this.checksum,
    required this.schemaVersion,
    required this.schoolYear,
    required this.term,
    required this.firstWeekMonday,
    required this.rowCount,
    required this.updatedAt,
  });

  final String termKey;
  final String path;
  final int version;
  final String checksum;
  final int schemaVersion;
  final String schoolYear;
  final String term;
  final String firstWeekMonday;
  final int rowCount;
  final DateTime updatedAt;

  _ArtifactEntry copyWith({String? path, String? checksum}) {
    return _ArtifactEntry(
      termKey: termKey,
      path: path ?? this.path,
      version: version,
      checksum: checksum ?? this.checksum,
      schemaVersion: schemaVersion,
      schoolYear: schoolYear,
      term: term,
      firstWeekMonday: firstWeekMonday,
      rowCount: rowCount,
      updatedAt: updatedAt,
    );
  }

  factory _ArtifactEntry.fromJson(Map<String, dynamic> json) {
    return _ArtifactEntry(
      termKey: json['term_key'] as String? ?? '',
      path: json['path'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      checksum: json['checksum'] as String? ?? '',
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 0,
      schoolYear: json['school_year'] as String? ?? '',
      term: json['term'] as String? ?? '',
      firstWeekMonday: json['first_week_monday'] as String? ?? '',
      rowCount: (json['row_count'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updated_at'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term_key': termKey,
      'path': path,
      'version': version,
      'checksum': checksum,
      'schema_version': schemaVersion,
      'school_year': schoolYear,
      'term': term,
      'first_week_monday': firstWeekMonday,
      'row_count': rowCount,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
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

class _SchoolTimetableArtifactDatabase extends GeneratedDatabase {
  _SchoolTimetableArtifactDatabase(super.executor);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  int get schemaVersion => 1;
}

class _SectionRange {
  const _SectionRange({required this.start, required this.end});

  final int start;
  final int end;
}
