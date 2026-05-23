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
    CourseTimetableRows,
    SelectedCourseTimetableRows,
    SyncTombstoneRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
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
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get estimatedDurationMinutes => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  RealColumn get sortOrder => real().withDefault(const Constant(0))();
  TextColumn get sourceKind => text().withDefault(const Constant('manual'))();
  TextColumn get sourceRef => text().withDefault(const Constant(''))();
  TextColumn get courseTimetableId => text().withDefault(const Constant(''))();
  TextColumn get courseSourceKind => text().withDefault(const Constant('manual'))();
  TextColumn get courseSourceCourseId => text().withDefault(const Constant(''))();
  TextColumn get courseNature => text().withDefault(const Constant(''))();
  TextColumn get instructor => text().withDefault(const Constant(''))();
  TextColumn get weekMeta => text().withDefault(const Constant(''))();
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
