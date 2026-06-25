import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

@DriftDatabase(
  tables: [
    AgendaItemRows,
    ScheduleItemDetailRows,
    TaskItemDetailRows,
    CourseItemDetailRows,
    CourseTimetableRows,
    SelectedCourseTimetableRows,
    SyncTombstoneRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _ensureSchoolTimetableTables();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(
          selectedCourseTimetableRows,
          selectedCourseTimetableRows.revision,
        );
        await m.addColumn(
          selectedCourseTimetableRows,
          selectedCourseTimetableRows.dirty,
        );
        await m.addColumn(
          selectedCourseTimetableRows,
          selectedCourseTimetableRows.deletedAt,
        );
        await m.addColumn(
          selectedCourseTimetableRows,
          selectedCourseTimetableRows.lastSyncedAt,
        );
      }
      if (from < 3) {
        await customStatement(
          'ALTER TABLE agenda_item_rows RENAME TO agenda_item_rows_old',
        );
        await m.createTable(agendaItemRows);
        await m.createTable(scheduleItemDetailRows);
        await m.createTable(taskItemDetailRows);
        await m.createTable(courseItemDetailRows);
        await customStatement('''
              INSERT INTO agenda_item_rows (
                id, type, title, notes, location, color, reminder, repeat_rule,
                is_completed, completed_at, sort_order, source_kind, source_ref,
                remote_id, revision, dirty, deleted_at, last_synced_at,
                created_at, updated_at
              )
              SELECT
                id, type, title, notes, location, color, reminder, repeat_rule,
                is_completed, completed_at, sort_order, source_kind, source_ref,
                remote_id, revision, dirty, deleted_at, last_synced_at,
                created_at, updated_at
              FROM agenda_item_rows_old
            ''');
        await customStatement('''
              INSERT INTO schedule_item_detail_rows (
                item_id, start_at, end_at, is_all_day, countdown_enabled,
                auto_completed_once_at
              )
              SELECT id, start_at, end_at, is_all_day, FALSE, NULL
              FROM agenda_item_rows_old
              WHERE type = 'schedule'
            ''');
        await customStatement('''
              INSERT INTO task_item_detail_rows (item_id, deadline_at)
              SELECT id, COALESCE(deadline, end_at)
              FROM agenda_item_rows_old
              WHERE type = 'task'
            ''');
        await customStatement('''
              INSERT INTO course_item_detail_rows (
                item_id, start_at, end_at, is_all_day, timetable_id,
                source_kind, source_course_id, course_nature, instructor, week_meta
              )
              SELECT
                id, start_at, end_at, is_all_day, course_timetable_id,
                course_source_kind, course_source_course_id, course_nature,
                instructor, week_meta
              FROM agenda_item_rows_old
              WHERE type = 'course'
            ''');
        await customStatement('DROP TABLE agenda_item_rows_old');
      }
      if (from >= 3 && from < 4) {
        await m.addColumn(
          scheduleItemDetailRows,
          scheduleItemDetailRows.countdownEnabled,
        );
      }
      if (from < 10) {
        await _ensureCourseItemDetailEntityColumns();
      }
      if (from < 11) {
        await _ensureSchoolTimetableTables();
      }
      if (from < 12) {
        // 全校课表重塑为教学班核心模型：旧表整体丢弃（数据由服务端公共缓存重拉），
        // 再按新 schema 重建。个人课程桥接列 instructor_course_id 改名 teacher_id
        // （语义改为存教师 ID），用 RENAME COLUMN 保留本地个人课程数据。
        await _dropLegacySchoolTimetableTables();
        await _ensureSchoolTimetableTables();
        await _renameColumnIfPresent(
          'course_item_detail_rows',
          'instructor_course_id',
          'teacher_id',
        );
      }
    },
  );

  Future<void> _ensureSchoolTimetableTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_timetable_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_timetable_terms (
        term_key TEXT PRIMARY KEY,
        school_year TEXT NOT NULL,
        term TEXT NOT NULL,
        school_year_code TEXT NOT NULL DEFAULT '',
        term_code TEXT NOT NULL DEFAULT '',
        first_week_monday TEXT NOT NULL,
        source_version TEXT NOT NULL,
        row_count INTEGER NOT NULL,
        imported_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_timetable_courses (
        id TEXT PRIMARY KEY,
        course_no TEXT NOT NULL DEFAULT '',
        course_name TEXT NOT NULL DEFAULT '',
        credits TEXT NOT NULL DEFAULT ''
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_timetable_teachers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        name_key TEXT NOT NULL DEFAULT '',
        seq INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_timetable_offerings (
        id TEXT PRIMARY KEY,
        term_key TEXT NOT NULL,
        course_id TEXT NOT NULL,
        term_course_id TEXT NOT NULL,
        source_key TEXT NOT NULL DEFAULT '',
        teaching_class_name TEXT NOT NULL DEFAULT '',
        open_college TEXT NOT NULL DEFAULT '',
        college_id TEXT NOT NULL DEFAULT '',
        open_dept_id TEXT NOT NULL DEFAULT '',
        course_nature TEXT NOT NULL DEFAULT '',
        course_category TEXT NOT NULL DEFAULT '',
        open_type TEXT NOT NULL DEFAULT '',
        people_raw TEXT NOT NULL DEFAULT '',
        capacity INTEGER NOT NULL DEFAULT 0,
        selected_count INTEGER NOT NULL DEFAULT 0,
        theory_hours TEXT NOT NULL DEFAULT '',
        computer_hours TEXT NOT NULL DEFAULT '',
        experiment_hours TEXT NOT NULL DEFAULT '',
        practice_hours TEXT NOT NULL DEFAULT '',
        remark TEXT NOT NULL DEFAULT '',
        note TEXT NOT NULL DEFAULT '',
        other_teachers TEXT NOT NULL DEFAULT '',
        textbook TEXT NOT NULL DEFAULT '',
        publisher TEXT NOT NULL DEFAULT '',
        search_text TEXT NOT NULL DEFAULT ''
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_timetable_offering_teachers (
        id TEXT PRIMARY KEY,
        offering_id TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'main',
        title TEXT NOT NULL DEFAULT '',
        ordinal INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_timetable_audiences (
        id TEXT PRIMARY KEY,
        term_key TEXT NOT NULL,
        offering_id TEXT NOT NULL,
        grade TEXT NOT NULL DEFAULT '',
        grade_code TEXT NOT NULL DEFAULT '',
        major TEXT NOT NULL DEFAULT '',
        major_code TEXT NOT NULL DEFAULT '',
        plan_college TEXT NOT NULL DEFAULT '',
        course_nature_code TEXT NOT NULL DEFAULT '',
        course_category_code TEXT NOT NULL DEFAULT '',
        open_type_code TEXT NOT NULL DEFAULT '',
        condition_code TEXT NOT NULL DEFAULT ''
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_timetable_meetings (
        id TEXT PRIMARY KEY,
        offering_id TEXT NOT NULL,
        term_key TEXT NOT NULL,
        weekday INTEGER NOT NULL DEFAULT 0,
        day_field TEXT NOT NULL DEFAULT '',
        segment_index INTEGER NOT NULL DEFAULT 0,
        weekday_label TEXT NOT NULL DEFAULT '',
        raw_day_text TEXT NOT NULL DEFAULT '',
        raw_segment_text TEXT NOT NULL DEFAULT '',
        week_text TEXT NOT NULL DEFAULT '',
        section_text TEXT NOT NULL DEFAULT '',
        section_start INTEGER NOT NULL DEFAULT 0,
        section_end INTEGER NOT NULL DEFAULT 0,
        location_text TEXT NOT NULL DEFAULT '',
        week_indexes TEXT NOT NULL DEFAULT '[]',
        parse_status TEXT NOT NULL DEFAULT ''
      )
    ''');
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS school_timetable_search_fts USING fts5(
        offering_id UNINDEXED,
        term_key UNINDEXED,
        term_course_id UNINDEXED,
        course_name,
        course_no,
        open_college,
        teaching_class_name,
        search_text
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_school_timetable_offerings_term ON school_timetable_offerings(term_key)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_school_timetable_offerings_term_course ON school_timetable_offerings(term_course_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_school_timetable_offering_teachers_offering ON school_timetable_offering_teachers(offering_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_school_timetable_offering_teachers_teacher ON school_timetable_offering_teachers(teacher_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_school_timetable_audiences_filter ON school_timetable_audiences(term_key, grade, major, plan_college)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_school_timetable_meetings_filter ON school_timetable_meetings(term_key, weekday, section_start, section_end)',
    );
  }

  Future<void> _dropLegacySchoolTimetableTables() async {
    const legacy = [
      'school_timetable_search_fts',
      'school_timetable_meeting_weeks',
      'school_timetable_meeting_rules',
      'school_timetable_source_rows',
      'school_timetable_audiences',
      'school_timetable_offerings',
      'school_timetable_instructors',
      'school_timetable_course_terms',
      'school_timetable_courses',
      'school_timetable_term_rows',
    ];
    for (final table in legacy) {
      await customStatement('DROP TABLE IF EXISTS $table');
    }
  }

  Future<void> _renameColumnIfPresent(
    String table,
    String oldColumn,
    String newColumn,
  ) async {
    final columns = await customSelect(
      'PRAGMA table_info(${_sqlIdentifier(table)})',
    ).get();
    final hasOld = columns.any((row) => row.data['name'] == oldColumn);
    final hasNew = columns.any((row) => row.data['name'] == newColumn);
    if (hasOld && !hasNew) {
      await customStatement(
        'ALTER TABLE ${_sqlIdentifier(table)} RENAME COLUMN '
        '${_sqlIdentifier(oldColumn)} TO ${_sqlIdentifier(newColumn)}',
      );
    }
  }

  Future<void> _ensureCourseItemDetailEntityColumns() async {
    await _addTextColumnIfMissing('course_item_detail_rows', 'term_course_id');
    await _addTextColumnIfMissing('course_item_detail_rows', 'offering_id');
    await _addTextColumnIfMissing('course_item_detail_rows', 'teacher_id');
    await _addTextColumnIfMissing('course_item_detail_rows', 'occurrence_id');
  }

  Future<void> _addTextColumnIfMissing(String table, String column) async {
    final columns = await customSelect(
      'PRAGMA table_info(${_sqlIdentifier(table)})',
    ).get();
    final exists = columns.any((row) => row.data['name'] == column);
    if (exists) {
      return;
    }
    await customStatement(
      'ALTER TABLE ${_sqlIdentifier(table)} '
      'ADD COLUMN ${_sqlIdentifier(column)} TEXT NOT NULL DEFAULT \'\'',
    );
  }

  String _sqlIdentifier(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'luotopia');
}

class AgendaItemRows extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get location => text().withDefault(const Constant(''))();
  TextColumn get color => text()();
  TextColumn get reminder => text()();
  TextColumn get repeatRule => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  TextColumn get sourceKind => text().withDefault(const Constant('manual'))();
  TextColumn get sourceRef => text().withDefault(const Constant(''))();
  TextColumn get remoteId => text().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ScheduleItemDetailRows extends Table {
  TextColumn get itemId => text().references(AgendaItemRows, #id)();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  BoolColumn get countdownEnabled =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get autoCompletedOnceAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

class TaskItemDetailRows extends Table {
  TextColumn get itemId => text().references(AgendaItemRows, #id)();
  DateTimeColumn get deadlineAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

class CourseItemDetailRows extends Table {
  TextColumn get itemId => text().references(AgendaItemRows, #id)();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  TextColumn get timetableId => text().withDefault(const Constant(''))();
  TextColumn get sourceKind => text().withDefault(const Constant('manual'))();
  TextColumn get sourceCourseId => text().withDefault(const Constant(''))();
  TextColumn get courseNature => text().withDefault(const Constant(''))();
  TextColumn get instructor => text().withDefault(const Constant(''))();
  TextColumn get weekMeta => text().withDefault(const Constant(''))();
  TextColumn get termCourseId => text().withDefault(const Constant(''))();
  TextColumn get offeringId => text().withDefault(const Constant(''))();
  TextColumn get teacherId => text().withDefault(const Constant(''))();
  TextColumn get occurrenceId => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

class CourseTimetableRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get source => text()();
  TextColumn get termLabel => text().withDefault(const Constant(''))();
  TextColumn get remoteId => text().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SelectedCourseTimetableRows extends Table {
  TextColumn get timetableId => text().references(CourseTimetableRows, #id)();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {timetableId};
}

class SyncTombstoneRows extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId};
}
