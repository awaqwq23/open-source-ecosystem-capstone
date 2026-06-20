import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
    final entityRows = normalizedRows.where(_canBuildEntity).toList();
    final offerings = _buildOfferings(termKey, entityRows);
    final heads = _buildHeads(termKey, entityRows, offerings);
    final audiences = _buildAudiences(termKey, offerings);
    final sourceOrdinals = <String, int>{};
    final sourceRows = <SchoolTimetableSourceRowsCompanion>[
      for (var index = 0; index < normalizedRows.length; index++)
        _sourceRowCompanion(
          termKey,
          index + 1,
          normalizedRows[index],
          sourceOrdinals,
        ),
    ];
    final meetings = <SchoolClassMeetingRowsCompanion>[
      for (final offering in offerings) ..._meetingCompanions(termKey, offering),
    ];
    final now = DateTime.now();

    await _db.transaction(() async {
      await (_db.delete(
        _db.schoolClassMeetingRows,
      )..where((row) => row.termKey.equals(termKey))).go();
      await (_db.delete(
        _db.schoolTimetableSourceRows,
      )..where((row) => row.termKey.equals(termKey))).go();
      await (_db.delete(
        _db.schoolTimetableAudienceRows,
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
          offerings
              .map((offering) => _rawRowCompanion(termKey, offering))
              .toList(),
        );
        batch.insertAll(_db.schoolTimetableAudienceRows, audiences);
        batch.insertAll(_db.schoolTimetableSourceRows, sourceRows);
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
    addLike('a.grade', query.grade);
    addLike('a.major', query.major);
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
          LEFT JOIN school_timetable_audience_rows a
            ON a.teaching_class_id = c.id
          LEFT JOIN school_class_meeting_rows m
            ON m.raw_row_id = c.id
          WHERE ${conditions.join(' AND ')}
          ''',
          variables: variables,
          readsFrom: {
            _db.schoolTimetableRawRows,
            _db.schoolTimetableAudienceRows,
            _db.schoolClassMeetingRows,
          },
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

  List<_HeadSeed> _buildHeads(
    String termKey,
    List<Map<String, String>> rows,
    List<_OfferingSeed> offerings,
  ) {
    final groupedRows = <String, List<Map<String, String>>>{};
    final groupedOfferings = <String, List<_OfferingSeed>>{};
    for (final row in rows) {
      final key = _courseHeadId(termKey, row);
      groupedRows.putIfAbsent(key, () => []).add(row);
    }
    for (final offering in offerings) {
      groupedOfferings
          .putIfAbsent(offering.courseHeadId, () => [])
          .add(offering);
    }

    return [
      for (final entry in groupedRows.entries)
        _HeadSeed.fromRows(
          entry.key,
          entry.value,
          groupedOfferings[entry.key] ?? const [],
        ),
    ];
  }

  List<_OfferingSeed> _buildOfferings(
    String termKey,
    List<Map<String, String>> rows,
  ) {
    final grouped = <String, List<Map<String, String>>>{};
    for (final row in rows) {
      final key = _offeringId(termKey, row);
      grouped.putIfAbsent(key, () => []).add(row);
    }
    return [
      for (final entry in grouped.entries)
        _OfferingSeed.fromRows(entry.key, termKey, entry.value),
    ];
  }

  List<SchoolTimetableAudienceRowsCompanion> _buildAudiences(
    String termKey,
    List<_OfferingSeed> offerings,
  ) {
    final byId = <String, SchoolTimetableAudienceRowsCompanion>{};
    for (final offering in offerings) {
      for (final row in offering.rows) {
        final id = _audienceId(termKey, offering.id, row);
        byId[id] = SchoolTimetableAudienceRowsCompanion.insert(
          id: id,
          termKey: termKey,
          teachingClassId: offering.id,
          courseHeadId: offering.courseHeadId,
          grade: Value(row['nj'] ?? ''),
          major: Value(row['jszy'] ?? ''),
          planCollege: Value(row['jhxy'] ?? ''),
          courseNature: Value(row['kcxzmc'] ?? ''),
          courseNatureCode: Value(row['kcxzdm'] ?? ''),
          courseCategory: Value(row['kclbmc'] ?? ''),
          courseCategoryCode: Value(row['kclbdm'] ?? ''),
          openType: Value(row['kklxmc'] ?? ''),
          openTypeCode: Value(row['kklxdm'] ?? ''),
          conditionCode: Value(row['kkbm_id2'] ?? ''),
        );
      }
    }
    return byId.values.toList(growable: false);
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
    _OfferingSeed seed,
  ) {
    final row = seed.row;
    return SchoolTimetableRawRowsCompanion.insert(
      id: seed.id,
      termKey: termKey,
      courseHeadId: seed.courseHeadId,
      sourceKey: row['key'] ?? '',
      packageIndex: Value(int.tryParse(row['_source_package_index'] ?? '') ?? 0),
      sourceStatus: const Value('active'),
      schoolYear: row['xn']!,
      term: row['xq']!,
      teachingClassName: row['jxbmc']!,
      courseNo: row['yskch']!,
      courseName: row['kcmc']!,
      openCollege: Value(row['skxy'] ?? ''),
      planCollege: Value(seed.audienceSummary),
      credits: Value(double.tryParse(row['kcxf'] ?? '')),
      courseNature: Value(row['kcxzmc'] ?? ''),
      courseCategory: Value(row['kclbmc'] ?? ''),
      openType: Value(row['kklxmc'] ?? ''),
      grade: Value(seed.gradeSummary),
      major: Value(seed.majorSummary),
      instructor: Value(seed.instructorSummary),
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
      originalFieldsJson: Value(jsonEncode(seed.originalFields)),
    );
  }

  SchoolTimetableSourceRowsCompanion _sourceRowCompanion(
    String termKey,
    int packageIndex,
    Map<String, String> row,
    Map<String, int> sourceOrdinals,
  ) {
    final active = _canBuildEntity(row);
    final canonical = _canonicalSourceRow(row);
    final ordinal = (sourceOrdinals[canonical] ?? 0) + 1;
    sourceOrdinals[canonical] = ordinal;
    return SchoolTimetableSourceRowsCompanion.insert(
      id: _stableId(['source', termKey, canonical, ordinal.toString()]),
      termKey: termKey,
      teachingClassId: Value(active ? _offeringId(termKey, row) : ''),
      courseHeadId: Value(active ? _courseHeadId(termKey, row) : ''),
      sourceKey: Value(row['key'] ?? ''),
      packageIndex: Value(packageIndex),
      sourceStatus: Value(active ? 'active' : 'incomplete'),
      originalFieldsJson: Value(jsonEncode(row)),
    );
  }

  List<SchoolClassMeetingRowsCompanion> _meetingCompanions(
    String termKey,
    _OfferingSeed seed,
  ) {
    final row = seed.row;
    final rawRowId = seed.id;
    final courseHeadId = seed.courseHeadId;
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

  bool _canBuildEntity(Map<String, String> row) {
    const required = [
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
    return required.every((field) => (row[field] ?? '').trim().isNotEmpty);
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

  String _courseHeadId(String termKey, Map<String, String> row) {
    return _stableId(['head', termKey, row['yskch'] ?? '']);
  }

  String _offeringId(String termKey, Map<String, String> row) {
    return _stableId([
      'offering',
      termKey,
      row['jxbmc'] ?? '',
      row['jsxm'] ?? '',
      _scheduleSignature(row),
    ]);
  }

  String _audienceId(
    String termKey,
    String offeringId,
    Map<String, String> row,
  ) {
    return _stableId([
      'audience',
      termKey,
      offeringId,
      row['nj'] ?? '',
      row['jszy'] ?? '',
      row['jhxy'] ?? '',
      row['kcxzdm'] ?? '',
      row['kclbdm'] ?? '',
      row['kklxdm'] ?? '',
      row['kkbm_id2'] ?? '',
    ]);
  }

  String _stableId(List<String> parts) {
    final normalized = parts
        .map(
          (part) => part
              .trim()
              .split(RegExp(r'\s+'))
              .where((item) => item.isNotEmpty)
              .join(' '),
        )
        .join('\x1f');
    return sha256.convert(utf8.encode(normalized)).toString().substring(0, 32);
  }

  String _canonicalSourceRow(Map<String, String> row) {
    final ordered = {
      for (final key in row.keys.where((key) => !key.startsWith('_source_')).toList()
        ..sort())
        key: row[key] ?? '',
    };
    return jsonEncode(ordered);
  }

  String _scheduleSignature(Map<String, String> row) {
    return [
      for (final field in _weekdayFields)
        '${field.code}=${(row[field.code] ?? '').trim()}',
    ].join('|');
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
    List<_OfferingSeed> offerings,
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
      teachingClassCount: offerings.length,
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

class _OfferingSeed {
  const _OfferingSeed({
    required this.id,
    required this.termKey,
    required this.courseHeadId,
    required this.row,
    required this.rows,
    required this.instructorSummary,
    required this.gradeSummary,
    required this.majorSummary,
    required this.audienceSummary,
    required this.originalFields,
  });

  factory _OfferingSeed.fromRows(
    String id,
    String termKey,
    List<Map<String, String>> rows,
  ) {
    final first = rows.first;
    final grades = _uniqueSummary(rows.map((row) => row['nj'] ?? ''));
    final majors = _uniqueSummary(rows.map((row) => row['jszy'] ?? ''));
    final audienceSummary = [
      grades,
      majors,
    ].where((item) => item.isNotEmpty).join(' / ');
    return _OfferingSeed(
      id: id,
      termKey: termKey,
      courseHeadId: _stableCourseHeadId(termKey, first),
      row: first,
      rows: rows,
      instructorSummary: _uniqueSummary(rows.map((row) => row['jsxm'] ?? '')),
      gradeSummary: grades,
      majorSummary: majors,
      audienceSummary: audienceSummary,
      originalFields: {
        ...first,
        '_audience_summary': audienceSummary,
        '_source_row_count': rows.length.toString(),
      },
    );
  }

  final String id;
  final String termKey;
  final String courseHeadId;
  final Map<String, String> row;
  final List<Map<String, String>> rows;
  final String instructorSummary;
  final String gradeSummary;
  final String majorSummary;
  final String audienceSummary;
  final Map<String, String> originalFields;
}

String _weekdaySummary(Map<String, String> row) {
  return [
    for (final field in DriftAllSchoolTimetableRepository._weekdayFields)
      if ((row[field.code] ?? '').trim().isNotEmpty) field.label,
  ].join('、');
}

String _stableCourseHeadId(String termKey, Map<String, String> row) {
  final normalized = ['head', termKey, row['yskch'] ?? '']
      .map(
        (part) => part
            .trim()
            .split(RegExp(r'\s+'))
            .where((item) => item.isNotEmpty)
            .join(' '),
      )
      .join('\x1f');
  return sha256.convert(utf8.encode(normalized)).toString().substring(0, 32);
}

String _uniqueSummary(Iterable<String> values, {int maxItems = 3}) {
  final unique = <String>[];
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isNotEmpty && !unique.contains(normalized)) {
      unique.add(normalized);
    }
  }
  if (unique.length <= maxItems) {
    return unique.join('、');
  }
  return '${unique.take(maxItems).join('、')}等 ${unique.length} 项';
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
