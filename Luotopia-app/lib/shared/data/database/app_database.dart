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
    SchoolTimetableTermRows,
    CourseCatalogRows,
    CourseTermCourseRows,
    CourseInstructorCourseRows,
    CourseOfferingRows,
    CourseAudienceRows,
    CourseSourceRows,
    CourseMeetingRuleRows,
    CourseOccurrenceRows,
    SyncTombstoneRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createCourseInstanceTables();
      await _createSchoolTimetableIndexes();
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
      if (from < 8) {
        await _dropSchoolTimetableTables();
        await m.createTable(schoolTimetableTermRows);
        await m.createTable(courseCatalogRows);
        await m.createTable(courseTermCourseRows);
        await m.createTable(courseInstructorCourseRows);
        await m.createTable(courseOfferingRows);
        await m.createTable(courseAudienceRows);
        await m.createTable(courseSourceRows);
        await m.createTable(courseMeetingRuleRows);
        await m.createTable(courseOccurrenceRows);
        await _createCourseInstanceTables();
        await _createSchoolTimetableIndexes();
      }
      if (from < 9) {
        await _createCourseInstanceTables();
        await _createSchoolTimetableIndexes();
      }
      if (from < 10) {
        await _ensureCourseItemDetailEntityColumns();
      }
    },
    beforeOpen: (details) async {
      await _createSchoolTimetableIndexes();
    },
  );

  Future<void> _dropSchoolTimetableTables() async {
    await customStatement('DROP TABLE IF EXISTS course_occurrence_rows');
    await customStatement('DROP TABLE IF EXISTS course_meeting_rule_rows');
    await customStatement('DROP TABLE IF EXISTS course_instance_week_rows');
    await customStatement('DROP TABLE IF EXISTS course_instance_rows');
    await customStatement('DROP TABLE IF EXISTS course_source_rows');
    await customStatement('DROP TABLE IF EXISTS course_audience_rows');
    await customStatement('DROP TABLE IF EXISTS course_offering_rows');
    await customStatement('DROP TABLE IF EXISTS course_instructor_course_rows');
    await customStatement('DROP TABLE IF EXISTS course_term_course_rows');
    await customStatement('DROP TABLE IF EXISTS course_catalog_rows');
    await customStatement('DROP TABLE IF EXISTS school_class_meeting_rows');
    await customStatement('DROP TABLE IF EXISTS school_timetable_source_rows');
    await customStatement(
      'DROP TABLE IF EXISTS school_timetable_audience_rows',
    );
    await customStatement('DROP TABLE IF EXISTS school_teaching_class_rows');
    await customStatement('DROP TABLE IF EXISTS school_timetable_raw_rows');
    await customStatement('DROP TABLE IF EXISTS school_course_head_rows');
    await customStatement('DROP TABLE IF EXISTS school_timetable_term_rows');
  }

  Future<void> _createSchoolTimetableIndexes() async {
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_term_courses_term
      ON course_term_course_rows(term_key)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_term_courses_course_no
      ON course_term_course_rows(course_no)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_term_courses_open_college
      ON course_term_course_rows(open_college)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_offerings_term_course
      ON course_offering_rows(term_course_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_offerings_instructor
      ON course_offering_rows(instructor_course_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_offerings_course_no
      ON course_offering_rows(course_no)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_offerings_instructor_name
      ON course_offering_rows(instructor)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_audiences_filter
      ON course_audience_rows(term_key, grade, major, plan_college)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_source_rows_term_status
      ON course_source_rows(term_key, source_status)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_instances_offering
      ON course_instance_rows(offering_id, weekday, segment_index)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_instances_filter
      ON course_instance_rows(term_key, weekday, section_start, section_end)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_course_instance_weeks_week
      ON course_instance_week_rows(week_index, instance_id)
    ''');
  }

  Future<void> _createCourseInstanceTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS course_instance_rows (
        id TEXT PRIMARY KEY,
        stable_id TEXT NOT NULL DEFAULT '',
        offering_id TEXT NOT NULL,
        term_key TEXT NOT NULL,
        term_course_id TEXT NOT NULL,
        catalog_id TEXT NOT NULL,
        weekday INTEGER NOT NULL,
        day_field TEXT NOT NULL DEFAULT '',
        segment_index INTEGER NOT NULL,
        weekday_label TEXT NOT NULL DEFAULT '',
        raw_day_text TEXT NOT NULL DEFAULT '',
        raw_segment_text TEXT NOT NULL DEFAULT '',
        week_text TEXT NOT NULL DEFAULT '',
        section_text TEXT NOT NULL DEFAULT '',
        section_start INTEGER,
        section_end INTEGER,
        location_text TEXT NOT NULL DEFAULT '',
        parse_status TEXT NOT NULL DEFAULT 'parsed'
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS course_instance_week_rows (
        instance_id TEXT NOT NULL,
        week_index INTEGER NOT NULL,
        PRIMARY KEY(instance_id, week_index)
      )
    ''');
  }

  Future<void> _ensureCourseItemDetailEntityColumns() async {
    await _addTextColumnIfMissing('course_item_detail_rows', 'term_course_id');
    await _addTextColumnIfMissing('course_item_detail_rows', 'offering_id');
    await _addTextColumnIfMissing(
      'course_item_detail_rows',
      'instructor_course_id',
    );
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
  TextColumn get instructorCourseId => text().withDefault(const Constant(''))();
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

class SchoolTimetableTermRows extends Table {
  TextColumn get termKey => text()();
  TextColumn get schoolYear => text()();
  TextColumn get term => text()();
  TextColumn get firstWeekMonday => text()();
  TextColumn get sourceVersion => text().withDefault(const Constant(''))();
  IntColumn get rowCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {termKey};
}

class CourseCatalogRows extends Table {
  TextColumn get id => text()();
  TextColumn get catalogKey => text()();
  TextColumn get courseNo => text()();
  TextColumn get courseName => text()();
  RealColumn get credits => real().nullable()();
  TextColumn get searchText => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CourseTermCourseRows extends Table {
  TextColumn get id => text()();
  TextColumn get termKey =>
      text().references(SchoolTimetableTermRows, #termKey)();
  TextColumn get catalogId => text().references(CourseCatalogRows, #id)();
  TextColumn get courseNo => text()();
  TextColumn get courseName => text()();
  TextColumn get openCollege => text().withDefault(const Constant(''))();
  RealColumn get credits => real().nullable()();
  TextColumn get courseNature => text().withDefault(const Constant(''))();
  TextColumn get courseCategory => text().withDefault(const Constant(''))();
  TextColumn get openType => text().withDefault(const Constant(''))();
  IntColumn get teachingClassCount =>
      integer().withDefault(const Constant(0))();
  TextColumn get teacherSummary => text().withDefault(const Constant(''))();
  TextColumn get weekdaySummary => text().withDefault(const Constant(''))();
  TextColumn get searchText => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CourseInstructorCourseRows extends Table {
  TextColumn get id => text()();
  TextColumn get catalogId => text().references(CourseCatalogRows, #id)();
  TextColumn get courseNo => text()();
  TextColumn get courseName => text()();
  RealColumn get credits => real().nullable()();
  TextColumn get instructorName => text().withDefault(const Constant(''))();
  TextColumn get instructorNameKey => text().withDefault(const Constant(''))();
  IntColumn get offeringCount => integer().withDefault(const Constant(0))();
  TextColumn get latestTermKey => text().withDefault(const Constant(''))();
  TextColumn get latestOpenCollege => text().withDefault(const Constant(''))();
  TextColumn get latestTeachingTitle =>
      text().withDefault(const Constant(''))();
  TextColumn get searchText => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CourseOfferingRows extends Table {
  TextColumn get id => text()();
  TextColumn get termKey =>
      text().references(SchoolTimetableTermRows, #termKey)();
  TextColumn get termCourseId => text().references(CourseTermCourseRows, #id)();
  TextColumn get catalogId => text().references(CourseCatalogRows, #id)();
  TextColumn get instructorCourseId =>
      text().references(CourseInstructorCourseRows, #id)();
  TextColumn get sourceKey => text()();
  IntColumn get packageIndex => integer().withDefault(const Constant(0))();
  TextColumn get sourceStatus => text().withDefault(const Constant('active'))();
  TextColumn get schoolYear => text()();
  TextColumn get term => text()();
  TextColumn get teachingClassName => text()();
  TextColumn get courseNo => text()();
  TextColumn get courseName => text()();
  TextColumn get openCollege => text().withDefault(const Constant(''))();
  TextColumn get planCollege => text().withDefault(const Constant(''))();
  RealColumn get credits => real().nullable()();
  TextColumn get courseNature => text().withDefault(const Constant(''))();
  TextColumn get courseCategory => text().withDefault(const Constant(''))();
  TextColumn get openType => text().withDefault(const Constant(''))();
  TextColumn get grade => text().withDefault(const Constant(''))();
  TextColumn get major => text().withDefault(const Constant(''))();
  TextColumn get instructor => text().withDefault(const Constant(''))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get peopleRaw => text().withDefault(const Constant(''))();
  IntColumn get theoryHours => integer().nullable()();
  IntColumn get computerHours => integer().nullable()();
  IntColumn get experimentHours => integer().nullable()();
  IntColumn get practiceHours => integer().nullable()();
  TextColumn get sundayRaw => text().withDefault(const Constant(''))();
  TextColumn get mondayRaw => text().withDefault(const Constant(''))();
  TextColumn get tuesdayRaw => text().withDefault(const Constant(''))();
  TextColumn get wednesdayRaw => text().withDefault(const Constant(''))();
  TextColumn get thursdayRaw => text().withDefault(const Constant(''))();
  TextColumn get fridayRaw => text().withDefault(const Constant(''))();
  TextColumn get saturdayRaw => text().withDefault(const Constant(''))();
  TextColumn get remark => text().withDefault(const Constant(''))();
  TextColumn get otherTeachers => text().withDefault(const Constant(''))();
  TextColumn get textbook => text().withDefault(const Constant(''))();
  TextColumn get publisher => text().withDefault(const Constant(''))();
  TextColumn get openDepartmentCode => text().withDefault(const Constant(''))();
  TextColumn get collegeCode => text().withDefault(const Constant(''))();
  TextColumn get majorCode => text().withDefault(const Constant(''))();
  TextColumn get gradeCode => text().withDefault(const Constant(''))();
  TextColumn get schoolYearCode => text().withDefault(const Constant(''))();
  TextColumn get termCode => text().withDefault(const Constant(''))();
  TextColumn get courseCategoryCode => text().withDefault(const Constant(''))();
  TextColumn get conditionCode => text().withDefault(const Constant(''))();
  TextColumn get openTypeCode => text().withDefault(const Constant(''))();
  TextColumn get courseNatureCode => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get scheduleSummary => text().withDefault(const Constant(''))();
  TextColumn get weekdaySummary => text().withDefault(const Constant(''))();
  TextColumn get searchText => text().withDefault(const Constant(''))();
  TextColumn get originalFieldsJson =>
      text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CourseAudienceRows extends Table {
  TextColumn get id => text()();
  TextColumn get termKey =>
      text().references(SchoolTimetableTermRows, #termKey)();
  TextColumn get offeringId => text().references(CourseOfferingRows, #id)();
  TextColumn get termCourseId => text().references(CourseTermCourseRows, #id)();
  TextColumn get catalogId => text().references(CourseCatalogRows, #id)();
  TextColumn get grade => text().withDefault(const Constant(''))();
  TextColumn get major => text().withDefault(const Constant(''))();
  TextColumn get planCollege => text().withDefault(const Constant(''))();
  TextColumn get courseNature => text().withDefault(const Constant(''))();
  TextColumn get courseNatureCode => text().withDefault(const Constant(''))();
  TextColumn get courseCategory => text().withDefault(const Constant(''))();
  TextColumn get courseCategoryCode => text().withDefault(const Constant(''))();
  TextColumn get openType => text().withDefault(const Constant(''))();
  TextColumn get openTypeCode => text().withDefault(const Constant(''))();
  TextColumn get conditionCode => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CourseSourceRows extends Table {
  TextColumn get id => text()();
  TextColumn get termKey =>
      text().references(SchoolTimetableTermRows, #termKey)();
  TextColumn get termCourseId => text().withDefault(const Constant(''))();
  TextColumn get offeringId => text().withDefault(const Constant(''))();
  TextColumn get sourceKey => text().withDefault(const Constant(''))();
  IntColumn get packageIndex => integer().withDefault(const Constant(0))();
  TextColumn get sourceStatus => text().withDefault(const Constant('active'))();
  TextColumn get originalFieldsJson =>
      text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CourseMeetingRuleRows extends Table {
  TextColumn get id => text()();
  TextColumn get offeringId => text().references(CourseOfferingRows, #id)();
  TextColumn get termKey =>
      text().references(SchoolTimetableTermRows, #termKey)();
  TextColumn get termCourseId => text().references(CourseTermCourseRows, #id)();
  TextColumn get catalogId => text().references(CourseCatalogRows, #id)();
  IntColumn get weekday => integer()();
  IntColumn get segmentIndex => integer()();
  TextColumn get weekdayLabel => text().withDefault(const Constant(''))();
  TextColumn get rawText => text().withDefault(const Constant(''))();
  TextColumn get weekText => text().withDefault(const Constant(''))();
  TextColumn get sectionText => text().withDefault(const Constant(''))();
  TextColumn get locationText => text().withDefault(const Constant(''))();
  TextColumn get building => text().withDefault(const Constant(''))();
  TextColumn get room => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CourseOccurrenceRows extends Table {
  TextColumn get id => text()();
  TextColumn get ruleId => text().references(CourseMeetingRuleRows, #id)();
  TextColumn get offeringId => text().references(CourseOfferingRows, #id)();
  TextColumn get termKey =>
      text().references(SchoolTimetableTermRows, #termKey)();
  TextColumn get termCourseId => text().references(CourseTermCourseRows, #id)();
  TextColumn get catalogId => text().references(CourseCatalogRows, #id)();
  TextColumn get date => text()();
  IntColumn get weekIndex => integer()();
  IntColumn get weekday => integer()();
  TextColumn get sectionText => text().withDefault(const Constant(''))();
  TextColumn get locationText => text().withDefault(const Constant(''))();
  TextColumn get building => text().withDefault(const Constant(''))();
  TextColumn get room => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
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
