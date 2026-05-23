import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/sync/device_id_store.dart';
import 'package:luotopia/shared/data/sync/local_sync_store.dart';
import 'package:luotopia/shared/data/sync/sync_client.dart';
import 'package:luotopia/shared/data/sync/sync_cursor_store.dart';
import 'package:luotopia/shared/data/sync/sync_payload_mapper.dart';

final agendaSyncServiceProvider = Provider<AgendaSyncService>((ref) {
  final service = AgendaSyncService(
    client: SyncClient(),
    deviceIdStore: ref.read(syncDeviceIdStoreProvider),
    cursorStore: ref.read(syncCursorStoreProvider),
    localStore: ref.read(localSyncStoreProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

class AgendaSyncService {
  AgendaSyncService({
    required SyncClient client,
    required SyncDeviceIdStore deviceIdStore,
    required SyncCursorStore cursorStore,
    required LocalSyncStore localStore,
  })  : _client = client,
        _deviceIdStore = deviceIdStore,
        _cursorStore = cursorStore,
        _localStore = localStore;

  final SyncClient _client;
  final SyncDeviceIdStore _deviceIdStore;
  final SyncCursorStore _cursorStore;
  final LocalSyncStore _localStore;
  bool _syncing = false;
  bool _queued = false;
  Timer? _debounceTimer;

  void syncDebounced(String accessToken, {Duration delay = const Duration(seconds: 2)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      unawaited(sync(accessToken));
    });
  }

  Future<void> sync(String accessToken) async {
    if (accessToken.isEmpty) {
      return;
    }
    if (_syncing) {
      _queued = true;
      return;
    }
    _syncing = true;
    try {
      await _pushDirtyChanges(accessToken);
      await _pullUntilCaughtUp(accessToken);
    } finally {
      _syncing = false;
      if (_queued) {
        _queued = false;
        unawaited(sync(accessToken));
      }
    }
  }

  Future<void> _pushDirtyChanges(String accessToken) async {
    final deviceId = await _deviceIdStore.getOrCreate();
    final cursor = _cursorStore.read();
    final dirtyAgenda = await _localStore.dirtyAgendaItems();
    final dirtyTimetables = await _localStore.dirtyCourseTimetables();
    final tombstones = await _localStore.dirtyTombstones();
    final changes = <Map<String, dynamic>>[
      for (final row in dirtyAgenda)
        if (row.deletedAt == null)
          {
            'entity_type': 'agenda_item',
            'entity_id': row.id,
            'operation': 'upsert',
            'payload': SyncPayloadMapper.agendaItemPayload(row),
          },
      for (final row in dirtyTimetables)
        if (row.deletedAt == null)
          {
            'entity_type': 'course_timetable',
            'entity_id': row.id,
            'operation': 'upsert',
            'payload': SyncPayloadMapper.courseTimetablePayload(row),
          },
      for (final row in tombstones)
        {
          'entity_type': row.entityType,
          'entity_id': row.entityId,
          'operation': 'delete',
          'payload': null,
        },
    ];
    if (changes.isEmpty) {
      return;
    }

    final response = await _client.pushChanges(
      accessToken: accessToken,
      body: {
        'base_cursor': cursor,
        'device_id': deviceId,
        'changes': changes,
      },
    );
    await _handleAccepted(response['accepted'] as List<dynamic>? ?? const []);
    await _applyChanges(response['server_changes'] as List<dynamic>? ?? const []);
    await _cursorStore.write((response['next_cursor'] as num?)?.toInt() ?? cursor);
  }

  Future<void> _pullUntilCaughtUp(String accessToken) async {
    var cursor = _cursorStore.read();
    while (true) {
      final response = await _client.pullChanges(
        accessToken: accessToken,
        cursor: cursor,
      );
      await _applyChanges(response['changes'] as List<dynamic>? ?? const []);
      final nextCursor = (response['next_cursor'] as num?)?.toInt() ?? cursor;
      await _cursorStore.write(nextCursor);
      cursor = nextCursor;
      if (response['has_more'] != true) {
        break;
      }
    }
  }

  Future<void> _handleAccepted(List<dynamic> rows) async {
    final syncedAt = DateTime.now();
    for (final raw in rows) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }
      final entityType = raw['entity_type'] as String? ?? '';
      final entityId = raw['entity_id'] as String? ?? '';
      final operation = raw['operation'] as String? ?? '';
      final revision = (raw['revision'] as num?)?.toInt() ?? 0;
      if (operation == 'delete') {
        await _localStore.applyRemoteDelete(
          entityType: entityType,
          entityId: entityId,
          revision: revision,
          deletedAt: syncedAt,
        );
        continue;
      }
      if (entityType == 'agenda_item') {
        await _localStore.markAgendaItemSynced(
          id: entityId,
          revision: revision,
          syncedAt: syncedAt,
          remoteId: entityId,
        );
      } else if (entityType == 'course_timetable') {
        await _localStore.markCourseTimetableSynced(
          id: entityId,
          revision: revision,
          syncedAt: syncedAt,
          remoteId: entityId,
        );
      } else {
        await _localStore.markTombstoneSynced(
          entityType: entityType,
          entityId: entityId,
          revision: revision,
        );
      }
    }
  }

  Future<void> _applyChanges(List<dynamic> rows) async {
    for (final raw in rows) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }
      final entityType = raw['entity_type'] as String? ?? '';
      final entityId = raw['entity_id'] as String? ?? '';
      final operation = raw['operation'] as String? ?? '';
      final revision = (raw['revision'] as num?)?.toInt() ?? 0;
      if (operation == 'delete') {
        await _localStore.applyRemoteDelete(
          entityType: entityType,
          entityId: entityId,
          revision: revision,
          deletedAt: _changeTime(raw),
        );
        continue;
      }
      final payload = raw['payload'];
      if (payload is! Map<String, dynamic>) {
        continue;
      }
      if (entityType == 'agenda_item') {
        await _localStore.applyRemoteAgendaItem(
          payload: payload,
          revision: revision,
          syncedAt: _changeTime(raw),
        );
      } else if (entityType == 'course_timetable') {
        await _localStore.applyRemoteCourseTimetable(
          payload: payload,
          revision: revision,
          syncedAt: _changeTime(raw),
        );
      }
    }
  }

  DateTime _changeTime(Map<String, dynamic> raw) {
    return DateTime.tryParse(raw['created_at'] as String? ?? '') ?? DateTime.now();
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
