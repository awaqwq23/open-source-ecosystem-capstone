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
    return (_db.select(
      _db.agendaItemRows,
    )..where((row) => row.dirty.equals(true))).get();
  }

  Future<List<CourseTimetableRow>> dirtyCourseTimetables() {
    return (_db.select(
      _db.courseTimetableRows,
    )..where((row) => row.dirty.equals(true))).get();
  }

  Future<List<SelectedCourseTimetableRow>> dirtySelectedTimetables() {
    return (_db.select(
      _db.selectedCourseTimetableRows,
    )..where((row) => row.dirty.equals(true) & row.deletedAt.isNull())).get();
  }

  Future<List<SyncTombstoneRow>> dirtyTombstones() {
    return (_db.select(
      _db.syncTombstoneRows,
    )..where((row) => row.dirty.equals(true))).get();
  }

  Future<int> pendingChangeCount() async {
    final agenda = await dirtyAgendaItems();
    final timetables = await dirtyCourseTimetables();
    final selected = await dirtySelectedTimetables();
    final tombstones = await dirtyTombstones();
    return agenda.length +
        timetables.length +
        selected.length +
        tombstones.length;
  }

  Future<void> markAgendaItemSynced({
    required String id,
    required int revision,
    required DateTime syncedAt,
    String? remoteId,
  }) {
    return (_db.update(
      _db.agendaItemRows,
    )..where((row) => row.id.equals(id))).write(
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
    return (_db.update(
      _db.courseTimetableRows,
    )..where((row) => row.id.equals(id))).write(
      CourseTimetableRowsCompanion(
        remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
        revision: Value(revision),
        dirty: const Value(false),
        lastSyncedAt: Value(syncedAt),
      ),
    );
  }

  Future<void> markSelectedTimetableSynced({
    required String timetableId,
    required int revision,
    required DateTime syncedAt,
  }) {
    return (_db.update(
      _db.selectedCourseTimetableRows,
    )..where((row) => row.timetableId.equals(timetableId))).write(
      SelectedCourseTimetableRowsCompanion(
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
    return (_db.update(_db.syncTombstoneRows)..where(
          (row) =>
              row.entityType.equals(entityType) & row.entityId.equals(entityId),
        ))
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
  }) async {
    final id = payload['id'] as String? ?? '';
    if (id.isEmpty) {
      return;
    }
    if (!await _shouldApplyAgendaItem(id, revision)) {
      return;
    }
    final type = payload['type'] as String? ?? 'task';
    final details = payload['details'] as Map<String, dynamic>? ?? const {};
    await _db.transaction(() async {
      await _db
          .into(_db.agendaItemRows)
          .insertOnConflictUpdate(
            AgendaItemRowsCompanion.insert(
              id: id,
              type: type,
              title: payload['title'] as String? ?? '',
              notes: Value(payload['notes'] as String? ?? ''),
              location: Value(payload['location'] as String? ?? ''),
              color: payload['color'] as String? ?? 'sky',
              reminder: payload['reminder'] as String? ?? 'none',
              repeatRule: payload['repeat_rule'] as String? ?? 'none',
              isCompleted: Value(payload['is_completed'] as bool? ?? false),
              completedAt: Value(_optionalDate(payload['completed_at'])),
              sortOrder: Value(
                (payload['sort_order'] as num?)?.toDouble() ?? 0,
              ),
              sourceKind: Value(payload['source_kind'] as String? ?? 'manual'),
              sourceRef: Value(payload['source_ref'] as String? ?? ''),
              revision: Value(revision),
              dirty: const Value(false),
              deletedAt: const Value(null),
              lastSyncedAt: Value(syncedAt),
              createdAt: _requiredDate(payload['created_at']),
              updatedAt: _requiredDate(payload['updated_at']),
            ),
          );
      await (_db.delete(
        _db.scheduleItemDetailRows,
      )..where((row) => row.itemId.equals(id))).go();
      await (_db.delete(
        _db.taskItemDetailRows,
      )..where((row) => row.itemId.equals(id))).go();
      await (_db.delete(
        _db.courseItemDetailRows,
      )..where((row) => row.itemId.equals(id))).go();
      switch (type) {
        case 'schedule':
          await _db
              .into(_db.scheduleItemDetailRows)
              .insert(
                ScheduleItemDetailRowsCompanion.insert(
                  itemId: id,
                  startAt: _requiredDate(details['start_at']),
                  endAt: _requiredDate(details['end_at']),
                  isAllDay: Value(details['is_all_day'] as bool? ?? false),
                  countdownEnabled: Value(
                    details['countdown_enabled'] as bool? ?? false,
                  ),
                  autoCompletedOnceAt: Value(
                    _optionalDate(details['auto_completed_once_at']),
                  ),
                ),
              );
        case 'task':
          await _db
              .into(_db.taskItemDetailRows)
              .insert(
                TaskItemDetailRowsCompanion.insert(
                  itemId: id,
                  deadlineAt: _requiredDate(details['deadline_at']),
                ),
              );
        case 'course':
          await _db
              .into(_db.courseItemDetailRows)
              .insert(
                CourseItemDetailRowsCompanion.insert(
                  itemId: id,
                  startAt: _requiredDate(details['start_at']),
                  endAt: _requiredDate(details['end_at']),
                  isAllDay: Value(details['is_all_day'] as bool? ?? false),
                  timetableId: Value(details['timetable_id'] as String? ?? ''),
                  sourceKind: Value(
                    details['source_kind'] as String? ?? 'manual',
                  ),
                  sourceCourseId: Value(
                    details['source_course_id'] as String? ?? '',
                  ),
                  courseNature: Value(
                    details['course_nature'] as String? ?? '',
                  ),
                  instructor: Value(details['instructor'] as String? ?? ''),
                  weekMeta: Value(details['week_meta'] as String? ?? ''),
                  termCourseId: Value(
                    details['term_course_id'] as String? ?? '',
                  ),
                  offeringId: Value(details['offering_id'] as String? ?? ''),
                  teacherId: Value(
                    details['teacher_id'] as String? ?? '',
                  ),
                  occurrenceId: Value(
                    details['occurrence_id'] as String? ?? '',
                  ),
                ),
              );
      }
    });
  }

  Future<void> applyRemoteCourseTimetable({
    required Map<String, dynamic> payload,
    required int revision,
    required DateTime syncedAt,
  }) async {
    final id = payload['id'] as String? ?? '';
    if (id.isEmpty) {
      return;
    }
    if (!await _shouldApplyCourseTimetable(id, revision)) {
      return;
    }
    await _db
        .into(_db.courseTimetableRows)
        .insertOnConflictUpdate(
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

  Future<void> applyRemoteSelectedTimetable({
    required Map<String, dynamic> payload,
    required int revision,
    required DateTime syncedAt,
  }) async {
    final timetableId = payload['timetable_id'] as String? ?? '';
    if (timetableId.isEmpty ||
        !await _shouldApplySelectedTimetable(timetableId, revision)) {
      return;
    }
    await _db
        .into(_db.selectedCourseTimetableRows)
        .insertOnConflictUpdate(
          SelectedCourseTimetableRowsCompanion.insert(
            timetableId: timetableId,
            sortOrder: Value((payload['sort_order'] as num?)?.toDouble() ?? 0),
            revision: Value(revision),
            dirty: const Value(false),
            deletedAt: const Value(null),
            lastSyncedAt: Value(syncedAt),
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
      await (_db.update(
        _db.agendaItemRows,
      )..where((row) => row.id.equals(entityId))).write(
        AgendaItemRowsCompanion(
          revision: Value(revision),
          dirty: const Value(false),
          deletedAt: Value(deletedAt),
          lastSyncedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
        ),
      );
    } else if (entityType == 'course_timetable') {
      await (_db.update(
        _db.courseTimetableRows,
      )..where((row) => row.id.equals(entityId))).write(
        CourseTimetableRowsCompanion(
          revision: Value(revision),
          dirty: const Value(false),
          deletedAt: Value(deletedAt),
          lastSyncedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
        ),
      );
    } else if (entityType == 'selected_course_timetable') {
      await (_db.update(
        _db.selectedCourseTimetableRows,
      )..where((row) => row.timetableId.equals(entityId))).write(
        SelectedCourseTimetableRowsCompanion(
          revision: Value(revision),
          dirty: const Value(false),
          deletedAt: Value(deletedAt),
          lastSyncedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
        ),
      );
    }
    await _db
        .into(_db.syncTombstoneRows)
        .insertOnConflictUpdate(
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

  Future<bool> _shouldApplyAgendaItem(String id, int revision) async {
    final row = await (_db.select(
      _db.agendaItemRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null || row.revision <= revision;
  }

  Future<bool> _shouldApplyCourseTimetable(String id, int revision) async {
    final row = await (_db.select(
      _db.courseTimetableRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null || row.revision <= revision;
  }

  Future<bool> _shouldApplySelectedTimetable(
    String timetableId,
    int revision,
  ) async {
    final row =
        await (_db.select(_db.selectedCourseTimetableRows)
              ..where((table) => table.timetableId.equals(timetableId)))
            .getSingleOrNull();
    return row == null || row.revision <= revision;
  }
}
