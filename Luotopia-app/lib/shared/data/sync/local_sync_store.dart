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

  Future<void> applyRemoteAgendaItem({
    required Map<String, dynamic> payload,
    required int revision,
    required DateTime syncedAt,
  }) {
    final id = payload['id'] as String? ?? '';
    if (id.isEmpty) {
      return Future<void>.value();
    }
    return _db.into(_db.agendaItemRows).insertOnConflictUpdate(
          AgendaItemRowsCompanion.insert(
            id: id,
            type: payload['type'] as String? ?? 'task',
            title: payload['title'] as String? ?? '',
            notes: Value(payload['notes'] as String? ?? ''),
            location: Value(payload['location'] as String? ?? ''),
            color: payload['color'] as String? ?? 'sky',
            reminder: payload['reminder'] as String? ?? 'none',
            repeatRule: payload['repeat_rule'] as String? ?? 'none',
            startAt: _requiredDate(payload['start_at']),
            endAt: _requiredDate(payload['end_at']),
            isAllDay: Value(payload['is_all_day'] as bool? ?? false),
            deadline: Value(_optionalDate(payload['deadline'])),
            estimatedDurationMinutes: Value(
              (payload['estimated_duration_minutes'] as num?)?.toInt() ?? 0,
            ),
            isCompleted: Value(payload['is_completed'] as bool? ?? false),
            completedAt: Value(_optionalDate(payload['completed_at'])),
            sortOrder: Value((payload['sort_order'] as num?)?.toDouble() ?? 0),
            sourceKind: Value(payload['source_kind'] as String? ?? 'manual'),
            sourceRef: Value(payload['source_ref'] as String? ?? ''),
            courseTimetableId: Value(
              payload['course_timetable_id'] as String? ?? '',
            ),
            courseSourceKind: Value(
              payload['course_source_kind'] as String? ?? 'manual',
            ),
            courseSourceCourseId: Value(
              payload['course_source_course_id'] as String? ?? '',
            ),
            courseNature: Value(payload['course_nature'] as String? ?? ''),
            instructor: Value(payload['instructor'] as String? ?? ''),
            weekMeta: Value(payload['week_meta'] as String? ?? ''),
            revision: Value(revision),
            dirty: const Value(false),
            deletedAt: const Value(null),
            lastSyncedAt: Value(syncedAt),
            createdAt: _requiredDate(payload['created_at']),
            updatedAt: _requiredDate(payload['updated_at']),
          ),
        );
  }

  Future<void> applyRemoteCourseTimetable({
    required Map<String, dynamic> payload,
    required int revision,
    required DateTime syncedAt,
  }) {
    final id = payload['id'] as String? ?? '';
    if (id.isEmpty) {
      return Future<void>.value();
    }
    return _db.into(_db.courseTimetableRows).insertOnConflictUpdate(
          CourseTimetableRowsCompanion.insert(
            id: id,
            name: payload['name'] as String? ?? '',
            source: payload['source'] as String? ?? 'manual',
            termLabel: Value(payload['term_label'] as String? ?? ''),
            revision: Value(revision),
            dirty: const Value(false),
            deletedAt: const Value(null),
            lastSyncedAt: Value(syncedAt),
            createdAt: _requiredDate(payload['created_at']),
            updatedAt: _requiredDate(payload['updated_at']),
          ),
        );
  }

  Future<void> applyRemoteDelete({
    required String entityType,
    required String entityId,
    required int revision,
    required DateTime deletedAt,
  }) async {
    if (entityType == 'agenda_item') {
      await (_db.update(_db.agendaItemRows)
            ..where((row) => row.id.equals(entityId)))
          .write(
        AgendaItemRowsCompanion(
          revision: Value(revision),
          dirty: const Value(false),
          deletedAt: Value(deletedAt),
          lastSyncedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
        ),
      );
    } else if (entityType == 'course_timetable') {
      await (_db.update(_db.courseTimetableRows)
            ..where((row) => row.id.equals(entityId)))
          .write(
        CourseTimetableRowsCompanion(
          revision: Value(revision),
          dirty: const Value(false),
          deletedAt: Value(deletedAt),
          lastSyncedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
        ),
      );
    }
    await _db.into(_db.syncTombstoneRows).insertOnConflictUpdate(
          SyncTombstoneRowsCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            revision: Value(revision),
            dirty: const Value(false),
            deletedAt: deletedAt,
          ),
        );
  }

  DateTime _requiredDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  DateTime? _optionalDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
