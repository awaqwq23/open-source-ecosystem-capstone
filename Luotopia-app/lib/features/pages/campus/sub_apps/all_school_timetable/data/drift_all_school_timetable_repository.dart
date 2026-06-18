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

  static const _weekdayFields = [
    _WeekdayField(0, 'sun', '周日'),
    _WeekdayField(1, 'mon', '周一'),
    _WeekdayField(2, 'tue', '周二'),
    _WeekdayField(3, 'wen', '周三'),
    _WeekdayField(4, 'thu', '周四'),
    _WeekdayField(5, 'fri', '周五'),
    _WeekdayField(6, 'sat', '周六'),
  ];

  final AppDatabase _db;

  @override
  Future<void> ensureLocalDataReady() async {}

  @override
  Future<void> replaceTermFromPackageBytes({
    required List<int> bytes,
    required String sourceVersion,
  }) async {
    final decoded = gzip.decode(bytes);
    final lines = utf8.decode(decoded).split(RegExp(r'\r?\n'));
    if (lines.isEmpty || lines.first.trim().isEmpty) {
      throw const FormatException('全校课表数据包为空');
    }

    final manifest = jsonDecode(lines.first) as Map<String, dynamic>;
    final termKey = manifest['term_key'] as String? ?? '';
    final schoolYear = manifest['school_year'] as String? ?? '';
    final term = manifest['term'] as String? ?? '';
    final rows = <Map<String, String>>[];
    for (final line in lines.skip(1)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final item = jsonDecode(trimmed) as Map<String, dynamic>;
      if (item['type'] != 'row') {
        continue;
      }
      final fields = item['fields'];
      if (fields is! Map<String, dynamic>) {
        continue;
      }
      rows.add({
        for (final entry in fields.entries)
          entry.key.toString(): entry.value?.toString() ?? '',
      });
    }
    if (termKey.isEmpty) {
      throw const FormatException('全校课表包缺少 term_key');
    }
    await replaceTermFromHtmlRows(
      termKey: termKey,
      schoolYear: schoolYear,
      term: term,
      sourceVersion: sourceVersion,
      rows: rows,
    );
  }

  @override
  Future<void> replaceTermFromHtmlRows({
    required String termKey,
    required String schoolYear,
    required String term,
    required String sourceVersion,
    required List<Map<String, String>> rows,
  }) async {
    final normalizedRows = rows.map(_normalizeHtmlRow).toList(growable: false);
    for (final row in normalizedRows) {
      _validateHtmlRow(row);
    }
    final heads = _buildHeads(termKey, normalizedRows);
    final meetings = <SchoolClassMeetingRowsCompanion>[
      for (final row in normalizedRows) ..._meetingCompanions(termKey, row),
    ];
    final now = DateTime.now();

    await _db.transaction(() async {
      await (_db.delete(
        _db.schoolClassMeetingRows,
      )..where((row) => row.termKey.equals(termKey))).go();
      await (_db.delete(
        _db.schoolTimetableRawRows,
      )..where((row) => row.termKey.equals(termKey))).go();
      await (_db.delete(
        _db.schoolCourseHeadRows,
      )..where((row) => row.termKey.equals(termKey))).go();
      await (_db.delete(
        _db.schoolTimetableTermRows,
      )..where((row) => row.termKey.equals(termKey))).go();

      await _db
          .into(_db.schoolTimetableTermRows)
          .insert(
            SchoolTimetableTermRowsCompanion.insert(
              termKey: termKey,
              schoolYear: schoolYear,
              term: term,
              sourceVersion: Value(sourceVersion),
              rowCount: Value(normalizedRows.length),
              importedAt: now,
              updatedAt: now,
            ),
          );

      await _db.batch((batch) {
        batch.insertAll(
          _db.schoolCourseHeadRows,
          heads.map((head) => _headCompanion(termKey, head)).toList(),
        );
        batch.insertAll(
          _db.schoolTimetableRawRows,
          normalizedRows.map((row) => _rawRowCompanion(termKey, row)).toList(),
        );
        batch.insertAll(_db.schoolClassMeetingRows, meetings);
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
        await (_db.select(_db.schoolTimetableRawRows)
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
      _db.schoolTimetableRawRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _classFromRow(row);
  }

  @override
  Future<List<SchoolClassMeeting>> loadMeetings(String teachingClassId) async {
    final rows =
        await (_db.select(_db.schoolClassMeetingRows)
              ..where((row) => row.rawRowId.equals(teachingClassId))
              ..orderBy([
                (row) => OrderingTerm(expression: row.weekday),
                (row) => OrderingTerm(expression: row.segmentIndex),
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
          FROM school_timetable_raw_rows c
          LEFT JOIN school_class_meeting_rows m
            ON m.raw_row_id = c.id
          WHERE ${conditions.join(' AND ')}
          ''',
          variables: variables,
          readsFrom: {_db.schoolTimetableRawRows, _db.schoolClassMeetingRows},
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

  List<_HeadSeed> _buildHeads(String termKey, List<Map<String, String>> rows) {
    final grouped = <String, List<Map<String, String>>>{};
    for (final row in rows) {
      final key = _courseHeadId(termKey, row);
      grouped.putIfAbsent(key, () => []).add(row);
    }

    return [
      for (final entry in grouped.entries)
        _HeadSeed.fromRows(entry.key, entry.value),
    ];
  }

  SchoolCourseHeadRowsCompanion _headCompanion(String termKey, _HeadSeed seed) {
    return SchoolCourseHeadRowsCompanion.insert(
      id: seed.id,
      termKey: termKey,
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

  SchoolTimetableRawRowsCompanion _rawRowCompanion(
    String termKey,
    Map<String, String> row,
  ) {
    return SchoolTimetableRawRowsCompanion.insert(
      id: _rawRowId(termKey, row),
      termKey: termKey,
      courseHeadId: _courseHeadId(termKey, row),
      sourceKey: row['key']!,
      schoolYear: row['xn']!,
      term: row['xq']!,
      teachingClassName: row['jxbmc']!,
      courseNo: row['yskch']!,
      courseName: row['kcmc']!,
      openCollege: Value(row['skxy'] ?? ''),
      planCollege: Value(row['jhxy'] ?? ''),
      credits: Value(double.tryParse(row['kcxf'] ?? '')),
      courseNature: Value(row['kcxzmc'] ?? ''),
      courseCategory: Value(row['kclbmc'] ?? ''),
      openType: Value(row['kklxmc'] ?? ''),
      grade: Value(row['nj'] ?? ''),
      major: Value(row['jszy'] ?? ''),
      instructor: Value(row['jsxm'] ?? ''),
      title: Value(row['jszc'] ?? ''),
      peopleRaw: Value(row['skrs'] ?? ''),
      theoryHours: Value(int.tryParse(row['xsdm_01'] ?? '')),
      computerHours: Value(int.tryParse(row['xsdm_02'] ?? '')),
      experimentHours: Value(int.tryParse(row['xsdm_03'] ?? '')),
      practiceHours: Value(int.tryParse(row['xsdm_04'] ?? '')),
      sundayRaw: Value(row['sun'] ?? ''),
      mondayRaw: Value(row['mon'] ?? ''),
      tuesdayRaw: Value(row['tue'] ?? ''),
      wednesdayRaw: Value(row['wen'] ?? ''),
      thursdayRaw: Value(row['thu'] ?? ''),
      fridayRaw: Value(row['fri'] ?? ''),
      saturdayRaw: Value(row['sat'] ?? ''),
      remark: Value(row['xkbz'] ?? ''),
      otherTeachers: Value(row['qtjs'] ?? ''),
      textbook: Value(row['jcmc'] ?? ''),
      publisher: Value(row['cbs'] ?? ''),
      openDepartmentCode: Value(row['kkbm_id'] ?? ''),
      collegeCode: Value(row['jg_id'] ?? ''),
      majorCode: Value(row['zyh_id'] ?? ''),
      gradeCode: Value(row['njdm_id'] ?? ''),
      schoolYearCode: Value(row['xnm'] ?? ''),
      termCode: Value(row['xqm'] ?? ''),
      courseCategoryCode: Value(row['kclbdm'] ?? ''),
      conditionCode: Value(row['kkbm_id2'] ?? ''),
      openTypeCode: Value(row['kklxdm'] ?? ''),
      courseNatureCode: Value(row['kcxzdm'] ?? ''),
      note: Value(row['bz'] ?? ''),
      scheduleSummary: Value(_scheduleSummary(row)),
      weekdaySummary: Value(_weekdaySummary(row)),
      searchText: Value(_searchText(row)),
      originalFieldsJson: Value(jsonEncode(row)),
    );
  }

  List<SchoolClassMeetingRowsCompanion> _meetingCompanions(
    String termKey,
    Map<String, String> row,
  ) {
    final rawRowId = _rawRowId(termKey, row);
    final courseHeadId = _courseHeadId(termKey, row);
    final companions = <SchoolClassMeetingRowsCompanion>[];
    for (final field in _weekdayFields) {
      final rawText = row[field.code]?.trim() ?? '';
      if (rawText.isEmpty) {
        continue;
      }
      final location = _extractLocation(rawText);
      companions.add(
        SchoolClassMeetingRowsCompanion.insert(
          id: '$rawRowId:${field.weekday}:0',
          rawRowId: rawRowId,
          termKey: termKey,
          courseHeadId: courseHeadId,
          weekday: field.weekday,
          segmentIndex: 0,
          weekdayLabel: Value(field.label),
          rawText: Value(rawText),
          locationText: Value(location.locationText),
          building: Value(location.building),
          room: Value(location.room),
        ),
      );
    }
    return companions;
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

  SchoolTeachingClass _classFromRow(SchoolTimetableRawRow row) {
    return SchoolTeachingClass(
      id: row.id,
      termKey: row.termKey,
      sourceKey: row.sourceKey,
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
      originalFields: _originalFieldsFromRow(row),
    );
  }

  SchoolClassMeeting _meetingFromRow(SchoolClassMeetingRow row) {
    return SchoolClassMeeting(
      id: row.id,
      rawRowId: row.rawRowId,
      weekday: row.weekday,
      weekdayLabel: row.weekdayLabel,
      rawText: row.rawText,
      locationText: row.locationText,
      building: row.building,
      room: row.room,
    );
  }

  Map<String, String> _normalizeHtmlRow(Map<String, String> row) {
    return {
      for (final entry in row.entries) entry.key: _normalizeCell(entry.value),
    };
  }

  void _validateHtmlRow(Map<String, String> row) {
    const required = [
      'key',
      'xn',
      'xq',
      'jxbmc',
      'yskch',
      'kcmc',
      'skxy',
      'kcxf',
      'jsxm',
      'skrs',
    ];
    for (final field in required) {
      if ((row[field] ?? '').trim().isEmpty) {
        throw ArgumentError('全校课表原始行缺少必填字段 $field');
      }
    }
    final hasSchedule = _weekdayFields.any(
      (field) => (row[field.code] ?? '').trim().isNotEmpty,
    );
    if (!hasSchedule) {
      throw ArgumentError('全校课表原始行 ${row['key']} 缺少星期安排');
    }
  }

  Map<String, String> _originalFieldsFromRow(SchoolTimetableRawRow row) {
    final decoded = jsonDecode(row.originalFieldsJson);
    final extraFields = <String, String>{
      if (decoded is Map)
        for (final entry in decoded.entries)
          entry.key.toString(): entry.value?.toString() ?? '',
    };
    return {
      'xn': row.schoolYear,
      'xq': row.term,
      'jxbmc': row.teachingClassName,
      'yskch': row.courseNo,
      'kcmc': row.courseName,
      'skxy': row.openCollege,
      'jhxy': row.planCollege,
      'kcxf': row.credits?.toString() ?? '',
      'kcxzmc': row.courseNature,
      'kclbmc': row.courseCategory,
      'kklxmc': row.openType,
      'nj': row.grade,
      'jszy': row.major,
      'jsxm': row.instructor,
      'jszc': row.title,
      'skrs': row.peopleRaw,
      'xsdm_01': row.theoryHours?.toString() ?? '',
      'xsdm_02': row.computerHours?.toString() ?? '',
      'xsdm_03': row.experimentHours?.toString() ?? '',
      'xsdm_04': row.practiceHours?.toString() ?? '',
      'sun': row.sundayRaw,
      'mon': row.mondayRaw,
      'tue': row.tuesdayRaw,
      'key': row.sourceKey,
      'wen': row.wednesdayRaw,
      'thu': row.thursdayRaw,
      'kkbm_id': row.openDepartmentCode,
      'jg_id': row.collegeCode,
      'fri': row.fridayRaw,
      'sat': row.saturdayRaw,
      'zyh_id': row.majorCode,
      'xkbz': row.remark,
      'njdm_id': row.gradeCode,
      'xnm': row.schoolYearCode,
      'bz': row.note,
      'xqm': row.termCode,
      'kclbdm': row.courseCategoryCode,
      'kkbm_id2': row.conditionCode,
      'qtjs': row.otherTeachers,
      'jcmc': row.textbook,
      'cbs': row.publisher,
      'kklxdm': row.openTypeCode,
      'kcxzdm': row.courseNatureCode,
      ...extraFields,
    };
  }

  String _rawRowId(String termKey, Map<String, String> row) {
    return '$termKey:${row['key']}';
  }

  String _courseHeadId(String termKey, Map<String, String> row) {
    return '$termKey:${row['yskch']}';
  }

  String _normalizeCell(String value) {
    return value.replaceAll('\u00a0', ' ').trim();
  }

  String _scheduleSummary(Map<String, String> row) {
    return [
      for (final field in _weekdayFields)
        if ((row[field.code] ?? '').trim().isNotEmpty)
          '${field.label}${row[field.code]!.trim()}',
    ].join('；');
  }

  String _weekdaySummary(Map<String, String> row) {
    return [
      for (final field in _weekdayFields)
        if ((row[field.code] ?? '').trim().isNotEmpty) field.label,
    ].join('、');
  }

  String _searchText(Map<String, String> row) {
    return [
      row['kcmc'],
      row['yskch'],
      row['jxbmc'],
      row['skxy'],
      row['jhxy'],
      row['kcxzmc'],
      row['kclbmc'],
      row['kklxmc'],
      row['nj'],
      row['jszy'],
      row['jsxm'],
      row['jszc'],
      _scheduleSummary(row),
    ].whereType<String>().join(' ');
  }

  _PeopleCount _parsePeople(String raw) {
    final parts = raw.split(RegExp(r'[\\/／]'));
    return _PeopleCount(
      capacity: parts.isEmpty ? null : int.tryParse(parts.first.trim()),
      selected: parts.length < 2 ? null : int.tryParse(parts[1].trim()),
    );
  }

  _LocationParts _extractLocation(String rawText) {
    final match = RegExp(
      r'((?:\d区|虚拟教室)[^,，;；)]*)',
    ).allMatches(rawText).lastOrNull;
    final location = match?.group(1)?.trim() ?? '';
    if (location.isEmpty || location == '虚拟教室') {
      return _LocationParts(location, location, '');
    }
    final buildingMatch = RegExp(
      r'^(\d区[^-－]*)[-－]?(.*)$',
    ).firstMatch(location);
    if (buildingMatch == null) {
      return _LocationParts(location, location, '');
    }
    return _LocationParts(
      location,
      buildingMatch.group(1)?.trim() ?? '',
      buildingMatch.group(2)?.trim() ?? '',
    );
  }
}

class _HeadSeed {
  const _HeadSeed({
    required this.id,
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

  factory _HeadSeed.fromRows(
    String courseHeadId,
    List<Map<String, String>> rows,
  ) {
    final first = rows.first;
    final teachers = _uniqueSummary(
      rows.map((row) => row['jsxm'] ?? ''),
      suffix: '位教师',
    );
    final weekdays = _uniqueSummary(
      rows.map(_weekdaySummary),
      maxItems: 4,
      suffix: '组时间',
    );
    final searchText = [
      first['kcmc'],
      first['yskch'],
      first['skxy'],
      first['kcxzmc'],
      first['kclbmc'],
      first['kklxmc'],
      teachers,
      weekdays,
    ].whereType<String>().join(' ');
    return _HeadSeed(
      id: courseHeadId,
      courseHeadKey: first['yskch'] ?? '',
      courseNo: first['yskch'] ?? '',
      courseName: first['kcmc'] ?? '',
      openCollege: first['skxy'] ?? '',
      credits: double.tryParse(first['kcxf'] ?? ''),
      courseNature: first['kcxzmc'] ?? '',
      courseCategory: first['kclbmc'] ?? '',
      openType: first['kklxmc'] ?? '',
      teachingClassCount: rows.length,
      teacherSummary: teachers,
      weekdaySummary: weekdays,
      searchText: searchText,
    );
  }

  final String id;
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

String _weekdaySummary(Map<String, String> row) {
  return [
    for (final field in DriftAllSchoolTimetableRepository._weekdayFields)
      if ((row[field.code] ?? '').trim().isNotEmpty) field.label,
  ].join('、');
}

class _WeekdayField {
  const _WeekdayField(this.weekday, this.code, this.label);

  final int weekday;
  final String code;
  final String label;
}

class _PeopleCount {
  const _PeopleCount({required this.capacity, required this.selected});

  final int? capacity;
  final int? selected;
}

class _LocationParts {
  const _LocationParts(this.locationText, this.building, this.room);

  final String locationText;
  final String building;
  final String room;
}
