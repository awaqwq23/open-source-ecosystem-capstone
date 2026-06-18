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
    SchoolCourseHeadRows,
    SchoolTeachingClassRows,
    SchoolClassMeetingRows,
    SyncTombstoneRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
      if (from < 5) {
        await m.createTable(schoolTimetableTermRows);
        await m.createTable(schoolCourseHeadRows);
        await m.createTable(schoolTeachingClassRows);
        await m.createTable(schoolClassMeetingRows);
        await _createSchoolTimetableIndexes();
      }
    },
    beforeOpen: (details) async {
      await _createSchoolTimetableIndexes();
    },
  );

  Future<void> _createSchoolTimetableIndexes() async {
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_course_heads_term
      ON school_course_head_rows(term_key)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_course_heads_course_no
      ON school_course_head_rows(course_no)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_course_heads_open_college
      ON school_course_head_rows(open_college)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_teaching_classes_head
      ON school_teaching_class_rows(course_head_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_teaching_classes_instructor
      ON school_teaching_class_rows(instructor)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_teaching_classes_grade_major
      ON school_teaching_class_rows(grade, major)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_class_meetings_class
      ON school_class_meeting_rows(teaching_class_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_class_meetings_weekday
      ON school_class_meeting_rows(weekday)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_school_class_meetings_location
      ON school_class_meeting_rows(building, room)
    ''');
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
  TextColumn get sourceVersion => text().withDefault(const Constant(''))();
  IntColumn get rowCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {termKey};
}

class SchoolCourseHeadRows extends Table {
  TextColumn get id => text()();
  TextColumn get termKey =>
      text().references(SchoolTimetableTermRows, #termKey)();
  TextColumn get courseHeadKey => text()();
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

class SchoolTeachingClassRows extends Table {
  TextColumn get id => text()();
  TextColumn get termKey =>
      text().references(SchoolTimetableTermRows, #termKey)();
  TextColumn get courseHeadId => text().references(SchoolCourseHeadRows, #id)();
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
  IntColumn get capacity => integer().nullable()();
  IntColumn get selectedCount => integer().nullable()();
  TextColumn get peopleRaw => text().withDefault(const Constant(''))();
  IntColumn get theoryHours => integer().nullable()();
  IntColumn get computerHours => integer().nullable()();
  IntColumn get experimentHours => integer().nullable()();
  IntColumn get practiceHours => integer().nullable()();
  TextColumn get remark => text().withDefault(const Constant(''))();
  TextColumn get otherTeachers => text().withDefault(const Constant(''))();
  TextColumn get textbook => text().withDefault(const Constant(''))();
  TextColumn get publisher => text().withDefault(const Constant(''))();
  TextColumn get scheduleSummary => text().withDefault(const Constant(''))();
  TextColumn get weekdaySummary => text().withDefault(const Constant(''))();
  TextColumn get searchText => text().withDefault(const Constant(''))();
  TextColumn get originalFieldsJson =>
      text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SchoolClassMeetingRows extends Table {
  TextColumn get id => text()();
  TextColumn get teachingClassId =>
      text().references(SchoolTeachingClassRows, #id)();
  IntColumn get weekday => integer()();
  TextColumn get weekdayLabel => text().withDefault(const Constant(''))();
  TextColumn get rawText => text().withDefault(const Constant(''))();
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
