import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';

final localSyncStoreProvider = Provider<LocalSyncStore>((ref) {
  return LocalSyncStore(ref.read(appDatabaseProvider));
});

class LocalSyncStore {
  const LocalSyncStore(this._db);

  final AppDatabase _db;

  Future<List<AgendaItemRow>> dirtyAgendaItems() {
    return (_db.select(_db.agendaItemRows)
          ..where((row) => row.dirty.equals(true)))
        .get();
  }

  Future<List<CourseTimetableRow>> dirtyCourseTimetables() {
    return (_db.select(_db.courseTimetableRows)
          ..where((row) => row.dirty.equals(true)))
        .get();
  }

  Future<List<SyncTombstoneRow>> dirtyTombstones() {
    return (_db.select(_db.syncTombstoneRows)
          ..where((row) => row.dirty.equals(true)))
        .get();
  }

  Future<void> markAgendaItemSynced({
    required String id,
    required int revision,
    required DateTime syncedAt,
    String? remoteId,
  }) {
    return (_db.update(_db.agendaItemRows)..where((row) => row.id.equals(id)))
        .write(
      AgendaItemRowsCompanion(
        remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
        revision: Value(revision),
        dirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  Future<void> markCourseTimetableSynced({
    required String id,
    required int revision,
    required DateTime syncedAt,
    String? remoteId,
  }) {
    return (_db.update(_db.courseTimetableRows)..where((row) => row.id.equals(id))).write(
      CourseTimetableRowsCompanion(
        remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
        revision: Value(revision),
        dirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  Future<void> markTombstoneSynced({
    required String entityType,
    required String entityId,
    required int revision,
  }) {
    return (_db.update(_db.syncTombstoneRows)
          ..where((row) =>
              row.entityType.equals(entityType) & row.entityId.equals(entityId)))
        .write(
      SyncTombstoneRowsCompanion(
        revision: Value(revision),
        dirty: const Value(false),
      ),
    );
  }
}
