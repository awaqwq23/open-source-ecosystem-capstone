import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/id/app_id_generator.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/domain/repositories/course_timetable_repository.dart';

class InMemoryCourseTimetableRepository extends Notifier<CourseTimetableStore>
    implements CourseTimetableRepository {
  late final AppDatabase _db;

  @override
  CourseTimetableStore build() {
    _db = ref.read(appDatabaseProvider);
    List<CourseTimetableRow> timetableRows = const [];
    List<SelectedCourseTimetableRow> selectedRows = const [];

    void publish() {
      final timetables = timetableRows.map(_fromRow).toList(growable: false);
      final validIds = timetables.map((timetable) => timetable.id).toSet();
      final selected = {
        for (final row in selectedRows)
          if (validIds.contains(row.timetableId)) row.timetableId,
      };
      state = CourseTimetableStore(
        timetables: timetables,
        selectedTimetableIds: selected,
      );
    }

    final timetableSub = (_db.select(_db.courseTimetableRows)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([
            (row) => OrderingTerm(expression: row.createdAt),
          ]))
        .watch()
        .listen((rows) {
      timetableRows = rows;
      publish();
    });
    final selectedSub = (_db.select(_db.selectedCourseTimetableRows)
          ..orderBy([
            (row) => OrderingTerm(expression: row.sortOrder),
          ]))
        .watch()
        .listen((rows) {
      selectedRows = rows;
      publish();
    });
    ref.onDispose(() {
      timetableSub.cancel();
      selectedSub.cancel();
    });
    return const CourseTimetableStore(timetables: []);
  }

  @override
  CourseTimetableStore get store => state;

  @override
  CourseTimetable? findById(String id) {
    for (final timetable in state.timetables) {
      if (timetable.id == id) {
        return timetable;
      }
    }
    return null;
  }

  @override
  Future<CourseTimetable> createTimetable({
    required String name,
    required CourseTimetableSource source,
    String termLabel = '',
  }) async {
    final now = DateTime.now();
    final timetable = CourseTimetable(
      id: _createUniqueCourseTimetableId(),
      name: name.trim().isEmpty ? '课程表 ${state.timetables.length + 1}' : name.trim(),
      source: source,
      termLabel: termLabel.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _db.transaction(() async {
      await _db.into(_db.courseTimetableRows).insert(_toCompanion(timetable));
      await _db.into(_db.selectedCourseTimetableRows).insertOnConflictUpdate(
            SelectedCourseTimetableRowsCompanion.insert(
              timetableId: timetable.id,
              sortOrder: Value(state.selectedTimetableIds.length.toDouble()),
              updatedAt: now,
            ),
          );
    });
    return timetable;
  }

  @override
  Future<void> renameTimetable(String id, String newName) async {
    final normalized = newName.trim();
    if (normalized.isEmpty) {
      return;
    }
    await (_db.update(_db.courseTimetableRows)..where((row) => row.id.equals(id)))
        .write(
      CourseTimetableRowsCompanion(
        name: Value(normalized),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> setSelectedTimetables(Set<String> ids) async {
    final valid = ids.where((id) => findById(id) != null).toList(growable: false);
    await _db.transaction(() async {
      await _db.delete(_db.selectedCourseTimetableRows).go();
      final now = DateTime.now();
      for (var index = 0; index < valid.length; index++) {
        await _db.into(_db.selectedCourseTimetableRows).insert(
              SelectedCourseTimetableRowsCompanion.insert(
                timetableId: valid[index],
                sortOrder: Value(index.toDouble()),
                updatedAt: now,
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteTimetable(String id) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      final courseItems = await (_db.select(_db.agendaItemRows)
            ..where((row) => row.courseTimetableId.equals(id)))
          .get();
      final courseItemIds = courseItems.map((item) => item.id).toList(growable: false);
      await (_db.update(_db.courseTimetableRows)..where((row) => row.id.equals(id)))
          .write(
        CourseTimetableRowsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await (_db.delete(_db.selectedCourseTimetableRows)
            ..where((row) => row.timetableId.equals(id)))
          .go();
      await (_db.update(_db.agendaItemRows)
            ..where((row) => row.courseTimetableId.equals(id)))
          .write(
        AgendaItemRowsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      for (final itemId in courseItemIds) {
        await _db.into(_db.syncTombstoneRows).insertOnConflictUpdate(
              SyncTombstoneRowsCompanion.insert(
                entityType: 'agenda_item',
                entityId: itemId,
                deletedAt: now,
                dirty: const Value(true),
              ),
            );
      }
      await _db.into(_db.syncTombstoneRows).insertOnConflictUpdate(
            SyncTombstoneRowsCompanion.insert(
              entityType: 'course_timetable',
              entityId: id,
              deletedAt: now,
              dirty: const Value(true),
            ),
          );
    });
  }

  String _createUniqueCourseTimetableId() {
    final existingIds = state.timetables.map((timetable) => timetable.id).toSet();
    final generator = ref.read(appIdGeneratorProvider);
    var id = generator.newCourseTimetableId();
    while (existingIds.contains(id)) {
      id = generator.newCourseTimetableId();
    }
    return id;
  }

  CourseTimetableRowsCompanion _toCompanion(CourseTimetable timetable) {
    return CourseTimetableRowsCompanion.insert(
      id: timetable.id,
      name: timetable.name,
      source: timetable.source.name,
      termLabel: Value(timetable.termLabel),
      dirty: const Value(true),
      createdAt: timetable.createdAt,
      updatedAt: timetable.updatedAt ?? timetable.createdAt,
    );
  }

  CourseTimetable _fromRow(CourseTimetableRow row) {
    return CourseTimetable(
      id: row.id,
      name: row.name,
      source: _enumByName(CourseTimetableSource.values, row.source) ??
          CourseTimetableSource.manual,
      termLabel: row.termLabel,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  T? _enumByName<T extends Enum>(List<T> values, String name) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}

final courseTimetableRepositoryProvider =
    NotifierProvider<InMemoryCourseTimetableRepository, CourseTimetableStore>(
  InMemoryCourseTimetableRepository.new,
);

final courseTimetableRepositoryNotifierProvider =
    Provider<CourseTimetableRepository>((ref) {
  return ref.read(courseTimetableRepositoryProvider.notifier);
});
