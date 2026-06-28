import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/data/empty_classroom_filter_preferences.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/exceptions/empty_classroom_exception.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/repositories/empty_classroom_repository.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/repositories/empty_classroom_repository_provider.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/use_cases/sort_empty_classrooms.dart';

class EmptyClassroomState {
  const EmptyClassroomState({
    this.termInfo,
    this.campuses = const [],
    this.classrooms = const [],
    this.selectedCampus,
    this.selectedBuilding,
    this.selectedWeek = '',
    this.selectedWeekDay = '',
    this.isInitialLoading = false,
    this.isQuerying = false,
    this.errorMessage,
    this.errorCode,
    this.onlyConflictFree = false,
    this.conflictingSectionKeys = const {},
    this.hasLoadedInitialData = false,
    this.hasQueried = false,
  });

  final TermInfo? termInfo;
  final List<CampusBuilding> campuses;
  final List<EmptyClassroom> classrooms;
  final CampusBuilding? selectedCampus;
  final Building? selectedBuilding;
  final String selectedWeek;
  final String selectedWeekDay;
  final bool isInitialLoading;
  final bool isQuerying;
  final String? errorMessage;
  final EmptyClassroomExceptionCode? errorCode;
  final bool onlyConflictFree;
  final Set<String> conflictingSectionKeys;
  final bool hasLoadedInitialData;
  final bool hasQueried;

  List<Building> get buildings => selectedCampus?.buildings ?? const [];

  List<String> get weeks {
    final maxWeek = int.tryParse(termInfo?.maxWeek ?? '') ?? 20;
    return List.generate(maxWeek, (index) => '${index + 1}');
  }

  bool get canQuery {
    return selectedCampus != null &&
        termInfo != null &&
        selectedWeek.isNotEmpty &&
        selectedWeekDay.isNotEmpty &&
        !isQuerying;
  }

  bool get hasInitialError => errorMessage != null && campuses.isEmpty;

  List<EmptyClassroom> get visibleClassrooms {
    if (!onlyConflictFree) {
      return classrooms;
    }
    return classrooms.where(_hasConflictFreeSection).toList();
  }

  EmptyClassroomState copyWith({
    TermInfo? termInfo,
    List<CampusBuilding>? campuses,
    List<EmptyClassroom>? classrooms,
    CampusBuilding? selectedCampus,
    Building? selectedBuilding,
    String? selectedWeek,
    String? selectedWeekDay,
    bool? isInitialLoading,
    bool? isQuerying,
    String? errorMessage,
    EmptyClassroomExceptionCode? errorCode,
    bool? onlyConflictFree,
    Set<String>? conflictingSectionKeys,
    bool clearErrorMessage = false,
    bool? hasLoadedInitialData,
    bool? hasQueried,
    bool clearSelectedCampus = false,
    bool clearSelectedBuilding = false,
  }) {
    return EmptyClassroomState(
      termInfo: termInfo ?? this.termInfo,
      campuses: campuses ?? this.campuses,
      classrooms: classrooms ?? this.classrooms,
      selectedCampus: clearSelectedCampus
          ? null
          : selectedCampus ?? this.selectedCampus,
      selectedBuilding: clearSelectedBuilding
          ? null
          : selectedBuilding ?? this.selectedBuilding,
      selectedWeek: selectedWeek ?? this.selectedWeek,
      selectedWeekDay: selectedWeekDay ?? this.selectedWeekDay,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isQuerying: isQuerying ?? this.isQuerying,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      errorCode: clearErrorMessage ? null : errorCode ?? this.errorCode,
      onlyConflictFree: onlyConflictFree ?? this.onlyConflictFree,
      conflictingSectionKeys:
          conflictingSectionKeys ?? this.conflictingSectionKeys,
      hasLoadedInitialData: hasLoadedInitialData ?? this.hasLoadedInitialData,
      hasQueried: hasQueried ?? this.hasQueried,
    );
  }

  bool _hasConflictFreeSection(EmptyClassroom classroom) {
    final classroomKey = '${classroom.building}|${classroom.name}';
    for (final section in classroom.availableSections) {
      if (!conflictingSectionKeys.contains('$classroomKey|$section')) {
        return true;
      }
    }
    return false;
  }
}

class EmptyClassroomViewModel extends Notifier<EmptyClassroomState> {
  static const _sortClassrooms = SortEmptyClassroomsUseCase();

  @override
  EmptyClassroomState build() {
    return const EmptyClassroomState();
  }

  Future<void> loadInitialData() async {
    if (state.isInitialLoading) {
      return;
    }

    // 同步阶段：读取本地缓存，立即展示 UI
    final savedFilters = ref
        .read(emptyClassroomFilterPreferencesProvider)
        .read();
    if (savedFilters != null) {
      state = state.copyWith(
        selectedCampus: savedFilters.campus != null
            ? CampusBuilding(campus: savedFilters.campus!, buildings: const [])
            : null,
        selectedBuilding: savedFilters.building != null
            ? Building(
                code: '',
                name: savedFilters.building!,
                campus: savedFilters.campus ?? '',
              )
            : null,
        selectedWeek: savedFilters.week ?? '',
        selectedWeekDay: savedFilters.weekDay ?? '',
        hasLoadedInitialData: true,
        clearErrorMessage: true,
      );
    }

    // 异步阶段：加载远程筛选选项
    state = state.copyWith(isInitialLoading: true, clearErrorMessage: true);
    try {
      final filters = await ref
          .read(emptyClassroomRepositoryProvider)
          .loadFilters();
      final selectedCampus = _savedCampus(
        filters.campuses,
        savedFilters?.campus,
      );
      final selectedBuilding = _savedBuilding(
        selectedCampus,
        savedFilters?.building,
      );
      final normalizedSelectedBuilding =
          selectedBuilding ?? _firstBuilding(selectedCampus);
      state = state.copyWith(
        termInfo: filters.termInfo,
        campuses: filters.campuses,
        selectedCampus: selectedCampus,
        selectedBuilding: normalizedSelectedBuilding,
        selectedWeek: _savedWeek(savedFilters?.week, filters.termInfo),
        selectedWeekDay: _savedWeekDay(savedFilters?.weekDay, filters.termInfo),
        isInitialLoading: false,
        hasLoadedInitialData: true,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isInitialLoading: false,
        errorMessage: _errorMessage(error),
        errorCode: _errorCode(error),
      );
    }
  }

  Future<void> query() async {
    final selectedCampus = state.selectedCampus;
    final termInfo = state.termInfo;
    if (selectedCampus == null || termInfo == null) {
      return;
    }

    state = state.copyWith(isQuerying: true, clearErrorMessage: true);

    try {
      final classrooms = await ref
          .read(emptyClassroomRepositoryProvider)
          .queryRooms(
            EmptyClassroomQuery(
              campus: selectedCampus.campus,
              schoolYear: termInfo.schoolYear,
              term: termInfo.termName,
              week: state.selectedWeek,
              weekDay: state.selectedWeekDay,
              teachingBuilding: state.selectedBuilding?.name,
            ),
          );
      state = state.copyWith(
        classrooms: _sortClassrooms(classrooms),
        isQuerying: false,
        hasQueried: true,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isQuerying: false,
        errorMessage: _errorMessage(error),
        errorCode: _errorCode(error),
      );
    }
  }

  void selectCampus(CampusBuilding? campus) {
    state = state.copyWith(
      selectedCampus: campus,
      clearSelectedCampus: campus == null,
      clearSelectedBuilding: true,
      classrooms: const [],
      hasQueried: false,
      clearErrorMessage: true,
    );
    _saveFilterSnapshot();
  }

  void selectBuilding(Building? building) {
    state = state.copyWith(
      selectedBuilding: building,
      clearSelectedBuilding: building == null,
      classrooms: const [],
      hasQueried: false,
      clearErrorMessage: true,
    );
    _saveFilterSnapshot();
  }

  void selectWeek(String week) {
    state = state.copyWith(
      selectedWeek: week,
      classrooms: const [],
      hasQueried: false,
      clearErrorMessage: true,
    );
    _saveFilterSnapshot();
  }

  void selectWeekDay(String weekDay) {
    state = state.copyWith(
      selectedWeekDay: weekDay,
      classrooms: const [],
      hasQueried: false,
      clearErrorMessage: true,
    );
    _saveFilterSnapshot();
  }

  void setOnlyConflictFree(bool value) {
    state = state.copyWith(onlyConflictFree: value);
  }

  void updateConflictingSectionKeys(Set<String> keys) {
    state = state.copyWith(conflictingSectionKeys: keys);
  }

  String _errorMessage(Object error) {
    if (error is EmptyClassroomException) {
      return error.message;
    }
    return error.toString();
  }

  EmptyClassroomExceptionCode? _errorCode(Object error) {
    if (error is EmptyClassroomException) {
      return error.code;
    }
    return null;
  }

  CampusBuilding? _savedCampus(
    List<CampusBuilding> campuses,
    String? campusName,
  ) {
    if (campusName != null && campusName.isNotEmpty) {
      for (final campus in campuses) {
        if (campus.campus == campusName) {
          return campus;
        }
      }
    }
    return campuses.isEmpty ? null : campuses.first;
  }

  Building? _savedBuilding(CampusBuilding? campus, String? buildingName) {
    if (campus == null || buildingName == null || buildingName.isEmpty) {
      return null;
    }
    for (final building in campus.buildings) {
      if (building.name == buildingName) {
        return building;
      }
    }
    return null;
  }

  Building? _firstBuilding(CampusBuilding? campus) {
    if (campus == null || campus.buildings.isEmpty) {
      return null;
    }
    return campus.buildings.first;
  }

  String _savedWeek(String? savedWeek, TermInfo termInfo) {
    final maxWeek = int.tryParse(termInfo.maxWeek) ?? 18;
    final week = int.tryParse(savedWeek ?? '');
    if (week != null && week >= 1 && week <= maxWeek) {
      return '$week';
    }
    return termInfo.currentWeek;
  }

  String _savedWeekDay(String? savedWeekDay, TermInfo termInfo) {
    final weekDay = int.tryParse(savedWeekDay ?? '');
    if (weekDay != null && weekDay >= 1 && weekDay <= 7) {
      return '$weekDay';
    }
    return termInfo.weekDay;
  }

  void _saveFilterSnapshot() {
    ref
        .read(emptyClassroomFilterPreferencesProvider)
        .write(
          EmptyClassroomFilterSnapshot(
            campus: state.selectedCampus?.campus,
            building: state.selectedBuilding?.name,
            week: state.selectedWeek,
            weekDay: state.selectedWeekDay,
          ),
        );
  }
}

final emptyClassroomViewModelProvider =
    NotifierProvider<EmptyClassroomViewModel, EmptyClassroomState>(
      EmptyClassroomViewModel.new,
    );
