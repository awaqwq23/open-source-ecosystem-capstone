import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/exceptions/empty_classroom_exception.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/repositories/empty_classroom_repository.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/repositories/empty_classroom_repository_provider.dart';

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
  final bool hasLoadedInitialData;
  final bool hasQueried;

  List<Building> get buildings => selectedCampus?.buildings ?? const [];

  List<String> get weeks {
    final maxWeek = int.tryParse(termInfo?.maxWeek ?? '') ?? 18;
    return List.generate(maxWeek, (index) => '${index + 1}');
  }

  bool get canQuery {
    return selectedCampus != null &&
        selectedBuilding != null &&
        termInfo != null &&
        selectedWeek.isNotEmpty &&
        selectedWeekDay.isNotEmpty &&
        !isQuerying;
  }

  bool get hasInitialError => errorMessage != null && campuses.isEmpty;

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
      hasLoadedInitialData: hasLoadedInitialData ?? this.hasLoadedInitialData,
      hasQueried: hasQueried ?? this.hasQueried,
    );
  }
}

class EmptyClassroomViewModel extends Notifier<EmptyClassroomState> {
  @override
  EmptyClassroomState build() {
    return const EmptyClassroomState();
  }

  Future<void> loadInitialData() async {
    if (state.isInitialLoading) {
      return;
    }
    state = state.copyWith(isInitialLoading: true, clearErrorMessage: true);

    try {
      final filters = await ref
          .read(emptyClassroomRepositoryProvider)
          .loadFilters();
      state = state.copyWith(
        termInfo: filters.termInfo,
        campuses: filters.campuses,
        selectedWeek: filters.termInfo.currentWeek,
        selectedWeekDay: filters.termInfo.weekDay,
        isInitialLoading: false,
        hasLoadedInitialData: true,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isInitialLoading: false,
        errorMessage: _errorMessage(error),
      );
    }
  }

  Future<void> query() async {
    final selectedCampus = state.selectedCampus;
    final selectedBuilding = state.selectedBuilding;
    final termInfo = state.termInfo;
    if (selectedCampus == null ||
        selectedBuilding == null ||
        termInfo == null) {
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
              teachingBuilding: selectedBuilding.name,
            ),
          );
      state = state.copyWith(
        classrooms: classrooms,
        isQuerying: false,
        hasQueried: true,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isQuerying: false,
        errorMessage: _errorMessage(error),
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
  }

  void selectBuilding(Building? building) {
    state = state.copyWith(
      selectedBuilding: building,
      clearSelectedBuilding: building == null,
      classrooms: const [],
      hasQueried: false,
      clearErrorMessage: true,
    );
  }

  void selectWeek(String week) {
    state = state.copyWith(
      selectedWeek: week,
      classrooms: const [],
      hasQueried: false,
      clearErrorMessage: true,
    );
  }

  void selectWeekDay(String weekDay) {
    state = state.copyWith(
      selectedWeekDay: weekDay,
      classrooms: const [],
      hasQueried: false,
      clearErrorMessage: true,
    );
  }

  String _errorMessage(Object error) {
    if (error is EmptyClassroomException) {
      return error.message;
    }
    return error.toString();
  }
}

final emptyClassroomViewModelProvider =
    NotifierProvider<EmptyClassroomViewModel, EmptyClassroomState>(
      EmptyClassroomViewModel.new,
    );
