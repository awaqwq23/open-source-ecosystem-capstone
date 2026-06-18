import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/course_schedule_repository.dart';
import '../../domain/models/course_group.dart';

/// Search page state: Level 1 of the course schedule.
class CourseScheduleSearchState {
  const CourseScheduleSearchState({
    this.keyword = '',
    this.selectedAcademicYear = '2025-2026',
    this.selectedSemester = 1,
    this.selectedSchool,
    this.selectedGrade,
    this.groups = const [],
    this.isLoading = false,
    this.hasSearched = false,
    this.availableSchools = const [],
    this.availableGrades = const [],
    this.filterSchoolOpen = false,
    this.filterGradeOpen = false,
    this.isSeeding = true,
  });

  final String keyword;
  final String selectedAcademicYear;
  final int selectedSemester;
  final String? selectedSchool;
  final String? selectedGrade;
  final List<CourseGroup> groups;
  final bool isLoading;
  final bool hasSearched;
  final List<String> availableSchools;
  final List<String> availableGrades;
  final bool filterSchoolOpen;
  final bool filterGradeOpen;
  final bool isSeeding;

  bool get hasActiveFilters =>
      keyword.isNotEmpty ||
      selectedSchool != null ||
      selectedGrade != null;

  CourseScheduleSearchState copyWith({
    String? keyword,
    String? selectedAcademicYear,
    int? selectedSemester,
    String? selectedSchool,
    bool clearSchool = false,
    String? selectedGrade,
    bool clearGrade = false,
    List<CourseGroup>? groups,
    bool? isLoading,
    bool? hasSearched,
    List<String>? availableSchools,
    List<String>? availableGrades,
    bool? filterSchoolOpen,
    bool? filterGradeOpen,
    bool? isSeeding,
  }) {
    return CourseScheduleSearchState(
      keyword: keyword ?? this.keyword,
      selectedAcademicYear: selectedAcademicYear ?? this.selectedAcademicYear,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      selectedSchool: clearSchool ? null : selectedSchool ?? this.selectedSchool,
      selectedGrade: clearGrade ? null : selectedGrade ?? this.selectedGrade,
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
      availableSchools: availableSchools ?? this.availableSchools,
      availableGrades: availableGrades ?? this.availableGrades,
      filterSchoolOpen: filterSchoolOpen ?? this.filterSchoolOpen,
      filterGradeOpen: filterGradeOpen ?? this.filterGradeOpen,
      isSeeding: isSeeding ?? this.isSeeding,
    );
  }
}

class CourseScheduleSearchViewModel extends Notifier<CourseScheduleSearchState> {
  @override
  CourseScheduleSearchState build() {
    _init();
    return const CourseScheduleSearchState();
  }

  Future<void> _init() async {
    final repo = ref.read(courseScheduleRepositoryProvider);
    await repo.seedIfNeeded();
    state = state.copyWith(isSeeding: false);
    // Load filter options
    final schools = await repo.getSchools(
      state.selectedAcademicYear,
      state.selectedSemester,
    );
    final grades = await repo.getGrades(
      state.selectedAcademicYear,
      state.selectedSemester,
    );
    state = state.copyWith(
      availableSchools: schools,
      availableGrades: grades,
    );
    // Auto-search with empty keyword (show all)
    await search();
  }

  Future<void> search() async {
    state = state.copyWith(isLoading: true, hasSearched: true);
    try {
      final repo = ref.read(courseScheduleRepositoryProvider);
      final groups = await repo.searchGroups(
        keyword: state.keyword.isNotEmpty ? state.keyword : null,
        academicYear: state.selectedAcademicYear,
        semester: state.selectedSemester,
        school: state.selectedSchool,
        grade: state.selectedGrade,
      );
      state = state.copyWith(groups: groups, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
  }

  Future<void> submitSearch() async {
    await search();
  }

  Future<void> clearSearch() async {
    state = state.copyWith(keyword: '', hasSearched: false);
  }

  Future<void> setSchool(String? school) async {
    state = school != null
        ? state.copyWith(selectedSchool: school, filterSchoolOpen: false)
        : state.copyWith(clearSchool: true, filterSchoolOpen: false);
    await search();
  }

  Future<void> setGrade(String? grade) async {
    state = grade != null
        ? state.copyWith(selectedGrade: grade, filterGradeOpen: false)
        : state.copyWith(clearGrade: true, filterGradeOpen: false);
    await search();
  }

  void toggleSchoolFilter() {
    state = state.copyWith(
      filterSchoolOpen: !state.filterSchoolOpen,
      filterGradeOpen: false,
    );
  }

  void toggleGradeFilter() {
    state = state.copyWith(
      filterGradeOpen: !state.filterGradeOpen,
      filterSchoolOpen: false,
    );
  }

  Future<void> clearAllFilters() async {
    state = state.copyWith(
      keyword: '',
      clearSchool: true,
      clearGrade: true,
    );
    await search();
  }
}

final courseScheduleSearchViewModelProvider =
    NotifierProvider<CourseScheduleSearchViewModel, CourseScheduleSearchState>(
  CourseScheduleSearchViewModel.new,
);
