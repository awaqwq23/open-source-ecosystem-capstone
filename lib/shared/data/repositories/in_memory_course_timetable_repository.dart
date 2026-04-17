import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/mappers/course_timetable_storage_mapper.dart';
import 'package:huajuan_agenda/shared/domain/entities/course_timetable.dart';
import 'package:huajuan_agenda/shared/domain/repositories/course_timetable_repository.dart';

final courseTimetableBootstrapProvider = Provider<CourseTimetableStore>((ref) {
  return const CourseTimetableStore(timetables: []);
});

class InMemoryCourseTimetableRepository extends Notifier<CourseTimetableStore>
    implements CourseTimetableRepository {
  static const _hydrateChunkSize = 100;

  var _idSeed = 0;
  var _hasMutated = false;
  var _hydratedDeferred = false;

  @override
  CourseTimetableStore build() {
    final boot = ref.read(courseTimetableBootstrapProvider);
    _idSeed = boot.timetables.length;
    _hasMutated = false;
    _hydratedDeferred = false;
    return boot;
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
    _hasMutated = true;
    final now = DateTime.now();
    final timetable = CourseTimetable(
      id: 'timetable_${_idSeed++}',
      name: name.trim().isEmpty ? '课程表 ${_idSeed}' : name.trim(),
      source: source,
      termLabel: termLabel.trim(),
      createdAt: now,
    );
    state = state.copyWith(
      timetables: [...state.timetables, timetable],
      activeTimetableId: state.activeTimetableId ?? timetable.id,
    );
    await _persist();
    return timetable;
  }

  @override
  Future<void> renameTimetable(String id, String newName) async {
    final normalized = newName.trim();
    if (normalized.isEmpty) {
      return;
    }
    _hasMutated = true;
    state = state.copyWith(
      timetables: [
        for (final timetable in state.timetables)
          if (timetable.id == id)
            timetable.copyWith(name: normalized, updatedAt: DateTime.now())
          else
            timetable,
      ],
    );
    await _persist();
  }

  @override
  Future<void> setActiveTimetable(String? timetableId) async {
    if (timetableId != null && findById(timetableId) == null) {
      return;
    }
    _hasMutated = true;
    state = state.copyWith(activeTimetableId: timetableId);
    await _persist();
  }

  @override
  Future<void> deleteTimetable(String id) async {
    _hasMutated = true;
    final remaining = [
      for (final timetable in state.timetables)
        if (timetable.id != id) timetable,
    ];
    final nextActiveId = state.activeTimetableId == id
        ? (remaining.isEmpty ? null : remaining.first.id)
        : state.activeTimetableId;
    state = state.copyWith(
      timetables: remaining,
      activeTimetableId: nextActiveId,
      clearActiveTimetableId: nextActiveId == null,
    );
    await _persist();
  }

  void hydrateFromBootstrap(CourseTimetableStore store) {
    if (_hydratedDeferred) {
      return;
    }
    _hydratedDeferred = true;
    if (_hasMutated || state.timetables.isNotEmpty || state.activeTimetableId != null) {
      return;
    }
    state = store;
    _idSeed = store.timetables.length;
  }

  Future<void> hydrateFromSerializedBootstrap({
    required List<Map<String, dynamic>> timetablesJson,
    required String? activeTimetableId,
  }) async {
    if (_hydratedDeferred) {
      return;
    }
    _hydratedDeferred = true;
    if (_hasMutated ||
        state.timetables.isNotEmpty ||
        state.activeTimetableId != null ||
        timetablesJson.isEmpty) {
      return;
    }

    final timetables = <CourseTimetable>[];
    for (var index = 0; index < timetablesJson.length; index += _hydrateChunkSize) {
      final end = (index + _hydrateChunkSize).clamp(0, timetablesJson.length);
      for (final item in timetablesJson.sublist(index, end)) {
        final parsed = CourseTimetableStorageMapper.fromJson(item);
        if (parsed != null) {
          timetables.add(parsed);
        }
      }
      if (end < timetablesJson.length) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    final normalizedActiveId = activeTimetableId != null &&
            timetables.any((timetable) => timetable.id == activeTimetableId)
        ? activeTimetableId
        : (timetables.isEmpty ? null : timetables.first.id);
    state = CourseTimetableStore(
      timetables: timetables,
      activeTimetableId: normalizedActiveId,
    );
    _idSeed = timetables.length;
  }

  Future<void> _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs == null) {
      return Future<void>.value();
    }
    return Future.wait([
      prefs.setString(
        AppBootstrapStorageKeys.courseTimetables,
        jsonEncode([
          for (final timetable in state.timetables)
            CourseTimetableStorageMapper.toJson(timetable),
        ]),
      ),
      prefs.setString(
        AppBootstrapStorageKeys.activeCourseTimetableId,
        state.activeTimetableId ?? '',
      ),
    ]).then((_) {});
  }
}

final courseTimetableRepositoryProvider =
    NotifierProvider<InMemoryCourseTimetableRepository, CourseTimetableStore>(
  InMemoryCourseTimetableRepository.new,
);

final courseTimetableRepositoryNotifierProvider = Provider<CourseTimetableRepository>((ref) {
  return ref.read(courseTimetableRepositoryProvider.notifier);
});
