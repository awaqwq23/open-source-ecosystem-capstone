import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
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

  static const _activePathKey = 'school_timetable.artifact.active_path';
  static const _activeChecksumKey = 'school_timetable.artifact.checksum';

  final SharedPreferences? _preferences;
  AppDatabase? _activeDb;
  String? _activePath;

  @override
  Future<void> ensureLocalDataReady() async {
    await _database();
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
      _validateArtifact(
        tempDb,
        termKey: termKey,
        version: version,
        rowCount: rowCount,
      );
      if (target.path != tempDb.path && await target.exists()) {
        await target.delete();
      }
      await tempDb.rename(target.path);
      await _closeActiveDb();
      await _preferences?.setString(_activePathKey, target.path);
      await _preferences?.setString(_activeChecksumKey, checksum);
      _activePath = null;
    } catch (_) {
      if (await tempDb.exists()) {
        await tempDb.delete();
      }
      rethrow;
    }
  }

  @override
  Future<List<SchoolTimetableTerm>> loadTerms() async {
    final db = await _database();
    if (db == null) {
      return const [];
    }
    final rows = await db.customSelect('''
          SELECT term_key, school_year, term, first_week_monday, source_version,
                 row_count, imported_at, updated_at
          FROM school_timetable_term_rows
          ORDER BY term_key DESC
          ''').get();
    return rows.map(_termFromRow).toList(growable: false);
  }

  @override
  Future<List<SchoolCourseHead>> searchCourseHeads(
    AllSchoolTimetableQuery query,
  ) async {
    final db = await _database();
    final termKey = query.termKey;
    if (db == null || termKey == null || termKey.isEmpty) {
      return const [];
    }
    final keyword = query.keyword.trim();
    final filterVariables = <Variable>[];
    final professionalClause = _professionalExistsClause(query, filterVariables);
    final rows = keyword.isNotEmpty
        ? await db.customSelect('''
          SELECT c.id, c.term_key, c.catalog_id, c.course_no, c.course_name, c.open_college,
                 c.credits, c.course_nature, c.course_category, c.open_type,
                 c.teaching_class_count, c.teacher_summary, c.weekday_summary,
                 c.search_text
          FROM course_search_fts
          JOIN course_term_course_rows c
            ON c.id = course_search_fts.term_course_id
          WHERE course_search_fts.term_key = ?
            AND course_search_fts MATCH ?
            $professionalClause
          ORDER BY bm25(course_search_fts), c.teaching_class_count DESC
          LIMIT 80
          ''', variables: [
              Variable.withString(termKey),
              Variable.withString(_ftsQuery(keyword)),
              ...filterVariables,
            ]).get()
        : await db.customSelect('''
          SELECT id, term_key, catalog_id, course_no, course_name, open_college,
                 credits, course_nature, course_category, open_type,
                 teaching_class_count, teacher_summary, weekday_summary,
                 search_text
          FROM course_term_course_rows c
          WHERE c.term_key = ?
            $professionalClause
          ORDER BY teaching_class_count DESC
          LIMIT 80
          ''', variables: [
              Variable.withString(termKey),
              ...filterVariables,
            ]).get();
    return rows.map(_termCourseFromRow).toList(growable: false);
  }

  @override
  Future<SchoolCourseHead?> findCourseHead(String id) async {
    final db = await _database();
    if (db == null) {
      return null;
    }
    final row = await db
        .customSelect(
          '''
          SELECT id, term_key, catalog_id, course_no, course_name, open_college,
                 credits, course_nature, course_category, open_type,
                 teaching_class_count, teacher_summary, weekday_summary,
                 search_text
          FROM course_term_course_rows
          WHERE id = ?
          ''',
          variables: [_idVariable(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _termCourseFromRow(row);
  }

  @override
  Future<List<SchoolTeachingClass>> loadTeachingClasses(
    String courseHeadId,
  ) async {
    final db = await _database();
    if (db == null) {
      return const [];
    }
    final rows = await db
        .customSelect(
          '''
          SELECT *
          FROM course_offering_rows
          WHERE term_course_id = ?
          ORDER BY instructor, teaching_class_name
          ''',
          variables: [_idVariable(courseHeadId)],
        )
        .get();
    return rows.map(_offeringFromRow).toList(growable: false);
  }

  @override
  Future<SchoolTeachingClass?> findTeachingClass(String id) async {
    final db = await _database();
    if (db == null) {
      return null;
    }
    final row = await db
        .customSelect(
          'SELECT * FROM course_offering_rows WHERE id = ?',
          variables: [_idVariable(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _offeringFromRow(row);
  }

  @override
  Future<List<SchoolClassMeeting>> loadMeetings(String teachingClassId) async {
    final db = await _database();
    if (db == null) {
      return const [];
    }
    final rows = await db
        .customSelect(
          '''
          SELECT *
          FROM course_instance_rows
          WHERE offering_id = ?
          ORDER BY weekday, segment_index
          ''',
          variables: [_idVariable(teachingClassId)],
        )
        .get();
    return rows.map(_ruleFromRow).toList(growable: false);
  }

  @override
  Future<CourseEntityLink> matchPersonalCourse(
    PersonalCourseMatchQuery query,
  ) async {
    final db = await _database();
    final termKey = query.termKey.trim();
    final courseNo = query.courseNo.trim();
    if (db == null || termKey.isEmpty || courseNo.isEmpty) {
      return const CourseEntityLink();
    }

    final termCourseId = await _matchTermCourse(db, query);
    final weekIndex = await _weekIndexForDate(db, query);
    final offering = await _matchOffering(db, query, weekIndex: weekIndex);
    if (offering == null) {
      return CourseEntityLink(termCourseId: termCourseId);
    }

    final instanceId = _readString(offering, 'matched_instance_id');
    final occurrenceId = instanceId.isEmpty || weekIndex == null
        ? ''
        : '$instanceId:$weekIndex';
    return CourseEntityLink(
      termCourseId: _readString(offering, 'term_course_id').isNotEmpty
          ? _readString(offering, 'term_course_id')
          : termCourseId,
      offeringId: _readString(offering, 'id'),
      instructorCourseId: _readString(offering, 'instructor_course_id'),
      occurrenceId: occurrenceId,
    );
  }

  Future<String> _matchTermCourse(
    AppDatabase db,
    PersonalCourseMatchQuery query,
  ) async {
    final rows = await db
        .customSelect(
          '''
          SELECT id, course_name
          FROM course_term_course_rows
          WHERE term_key = ? AND course_no = ?
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
    AppDatabase db,
    PersonalCourseMatchQuery query, {
    required int? weekIndex,
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
          SELECT 1 FROM course_instance_week_rows iw
          WHERE iw.instance_id = r.id AND iw.week_index = ?
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
    final rows = await db
        .customSelect(
          '''
          SELECT o.*, r.id AS matched_instance_id, r.location_text AS matched_location_text
          FROM course_offering_rows o
          JOIN course_instance_rows r
            ON r.offering_id = o.id
          WHERE o.term_key = ?
            AND o.course_no = ?
            AND r.weekday = ?
            ${ruleClauses.isEmpty ? '' : 'AND ${ruleClauses.join(' AND ')}'}
          ''',
          variables: variables,
        )
        .get();
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
    AppDatabase db,
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
    final queryDate = DateTime(query.date.year, query.date.month, query.date.day);
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

    addLike('o.open_college', query.openCollege);
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
        FROM course_offering_rows o
        LEFT JOIN course_audience_rows a
          ON a.offering_id = o.id
        LEFT JOIN course_instance_rows r
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

  SchoolTimetableTerm _termFromRow(QueryRow row) {
    return SchoolTimetableTerm(
      termKey: _readString(row, 'term_key'),
      schoolYear: _readString(row, 'school_year'),
      term: _readString(row, 'term'),
      firstWeekMonday: _readString(row, 'first_week_monday'),
      sourceVersion: _readString(row, 'source_version'),
      rowCount: _readInt(row, 'row_count'),
      importedAt: _readDateTime(row, 'imported_at'),
      updatedAt: _readDateTime(row, 'updated_at'),
    );
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
      termCourseId: _readString(row, 'term_course_id'),
      catalogId: _readString(row, 'catalog_id'),
      instructorCourseId: _readString(row, 'instructor_course_id'),
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
      offeringId: _readString(row, 'offering_id'),
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

  Future<AppDatabase?> _database() async {
    final path = _preferences?.getString(_activePathKey) ?? '';
    if (path.isEmpty || !await File(path).exists()) {
      await _closeActiveDb();
      return null;
    }
    if (_activeDb != null && _activePath == path) {
      return _activeDb;
    }
    await _closeActiveDb();
    _activePath = path;
    _activeDb = AppDatabase.withExecutor(
      NativeDatabase.createInBackground(
        File(path),
        enableMigrations: false,
        setup: (db) {
          db.execute('PRAGMA query_only = ON;');
        },
      ),
    );
    return _activeDb;
  }

  Future<void> _closeActiveDb() async {
    final db = _activeDb;
    _activeDb = null;
    _activePath = null;
    await db?.close();
  }

  Future<void> dispose() async {
    await _closeActiveDb();
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

  void _validateArtifact(
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
      if (meta['schema_version'] != '4' ||
          meta['artifact_type'] != 'school_timetable_sqlite_gzip' ||
          meta['term_key'] != termKey ||
          meta['version'] != version.toString()) {
        throw const FormatException('全校课表 SQLite 快照元信息不匹配');
      }
      final termRows = db.select(
        'SELECT row_count FROM school_timetable_term_rows WHERE term_key = ?',
        [termKey],
      );
      if (termRows.length != 1 || termRows.first['row_count'] != rowCount) {
        throw const FormatException('全校课表 SQLite 快照课表统计不匹配');
      }
      for (final table in const [
        'course_catalog_rows',
        'course_term_course_rows',
        'course_instructor_course_rows',
        'course_offering_rows',
        'course_audience_rows',
        'course_source_rows',
        'course_instance_rows',
        'course_instance_week_rows',
        'course_search_fts',
      ]) {
        db.select('SELECT 1 FROM $table LIMIT 1');
      }
    } finally {
      db.dispose();
    }
  }

  String _readString(QueryRow row, String column) {
    final value = row.data[column];
    return value?.toString() ?? '';
  }

  Variable _idVariable(String id) {
    final parsed = int.tryParse(id);
    return parsed == null ? Variable.withString(id) : Variable.withInt(parsed);
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

  DateTime _readDateTime(QueryRow row, String column) {
    final value = row.data[column];
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

class _SectionRange {
  const _SectionRange({required this.start, required this.end});

  final int start;
  final int end;
}
