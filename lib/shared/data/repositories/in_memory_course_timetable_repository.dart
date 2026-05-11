import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/app_bootstrap.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/shared/data/id/app_id_generator.dart';
import 'package:luotopia/shared/data/mappers/course_timetable_storage_mapper.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/domain/repositories/course_timetable_repository.dart';

final courseTimetableBootstrapProvider = Provider<CourseTimetableStore>((ref) {
  return const CourseTimetableStore(timetables: []);
});

class InMemoryCourseTimetableRepository extends Notifier<CourseTimetableStore>
    implements CourseTimetableRepository {
  @override
  CourseTimetableStore build() {
    final boot = ref.read(courseTimetableBootstrapProvider);
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
    final now = DateTime.now();
    final timetable = CourseTimetable(
      id: _createUniqueCourseTimetableId(),
      name: name.trim().isEmpty ? '课程表 ${state.timetables.length + 1}' : name.trim(),
      source: source,
      termLabel: termLabel.trim(),
      createdAt: now,
    );
    final selected = <String>{...state.selectedTimetableIds, timetable.id};
    state = state.copyWith(
      timetables: [...state.timetables, timetable],
      selectedTimetableIds: selected,
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
  Future<void> setSelectedTimetables(Set<String> ids) async {
    final valid = ids.where((id) => findById(id) != null).toSet();
    state = state.copyWith(selectedTimetableIds: valid);
    await _persist();
  }

  @override
  Future<void> deleteTimetable(String id) async {
    final remaining = [
      for (final timetable in state.timetables)
        if (timetable.id != id) timetable,
    ];
    final nextSelected = Set<String>.from(state.selectedTimetableIds)
      ..remove(id);
    state = state.copyWith(
      timetables: remaining,
      selectedTimetableIds: nextSelected,
    );
    await _persist();
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
        jsonEncode(state.selectedTimetableIds.toList()),
      ),
    ]).then((_) {});
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
}

final courseTimetableRepositoryProvider =
    NotifierProvider<InMemoryCourseTimetableRepository, CourseTimetableStore>(
  InMemoryCourseTimetableRepository.new,
);

final courseTimetableRepositoryNotifierProvider = Provider<CourseTimetableRepository>((ref) {
  return ref.read(courseTimetableRepositoryProvider.notifier);
});
