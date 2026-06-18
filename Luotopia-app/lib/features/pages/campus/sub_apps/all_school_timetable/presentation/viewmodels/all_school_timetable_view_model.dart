import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/data/drift_all_school_timetable_repository.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart';

class AllSchoolTimetableState {
  const AllSchoolTimetableState({
    this.terms = const [],
    this.query = const AllSchoolTimetableQuery(),
    this.courseHeads = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  final List<SchoolTimetableTerm> terms;
  final AllSchoolTimetableQuery query;
  final List<SchoolCourseHead> courseHeads;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  SchoolTimetableTerm? get selectedTerm {
    for (final term in terms) {
      if (term.termKey == query.termKey) {
        return term;
      }
    }
    return terms.isEmpty ? null : terms.first;
  }

  AllSchoolTimetableState copyWith({
    List<SchoolTimetableTerm>? terms,
    AllSchoolTimetableQuery? query,
    List<SchoolCourseHead>? courseHeads,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? hasLoaded,
  }) {
    return AllSchoolTimetableState(
      terms: terms ?? this.terms,
      query: query ?? this.query,
      courseHeads: courseHeads ?? this.courseHeads,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class AllSchoolTimetableViewModel extends Notifier<AllSchoolTimetableState> {
  late final AllSchoolTimetableRepository _repository;

  @override
  AllSchoolTimetableState build() {
    _repository = ref.read(allSchoolTimetableRepositoryProvider);
    return const AllSchoolTimetableState();
  }

  Future<void> load() async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _repository.ensureLocalDataReady();
      final terms = await _repository.loadTerms();
      final selectedTermKey = terms.isEmpty ? null : terms.first.termKey;
      final query = state.query.copyWith(termKey: selectedTermKey);
      final heads = await _repository.searchCourseHeads(query);
      state = state.copyWith(
        terms: terms,
        query: query,
        courseHeads: heads,
        isLoading: false,
        hasLoaded: true,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> setMode(AllSchoolTimetableQueryMode mode) {
    return _updateQuery(state.query.copyWith(mode: mode));
  }

  Future<void> setKeyword(String keyword) {
    return _updateQuery(state.query.copyWith(keyword: keyword));
  }

  Future<void> setTerm(String termKey) {
    return _updateQuery(state.query.copyWith(termKey: termKey));
  }

  Future<void> clearKeyword() {
    return _updateQuery(state.query.copyWith(keyword: ''));
  }

  Future<void> setOpenCollege(String value) {
    return _updateQuery(state.query.copyWith(openCollege: value));
  }

  Future<void> setGrade(String value) {
    return _updateQuery(state.query.copyWith(grade: value));
  }

  Future<void> setMajor(String value) {
    return _updateQuery(state.query.copyWith(major: value));
  }

  Future<void> setWeekday(int? value) {
    return _updateQuery(
      state.query.copyWith(weekday: value, clearWeekday: value == null),
    );
  }

  Future<void> setBuilding(String value) {
    return _updateQuery(state.query.copyWith(building: value));
  }

  Future<void> applyProfessionalFilters({
    required String openCollege,
    required String grade,
    required String major,
    required String building,
    required int? weekday,
  }) {
    return _updateQuery(
      state.query.copyWith(
        openCollege: openCollege,
        grade: grade,
        major: major,
        building: building,
        weekday: weekday,
        clearWeekday: weekday == null,
      ),
    );
  }

  Future<void> clearProfessionalFilters() {
    return _updateQuery(
      state.query.copyWith(
        openCollege: '',
        grade: '',
        major: '',
        building: '',
        clearWeekday: true,
      ),
    );
  }

  Future<void> _updateQuery(AllSchoolTimetableQuery query) async {
    state = state.copyWith(
      query: query,
      isLoading: true,
      clearErrorMessage: true,
    );
    try {
      final heads = await _repository.searchCourseHeads(query);
      state = state.copyWith(
        courseHeads: heads,
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}

final allSchoolTimetableViewModelProvider =
    NotifierProvider<AllSchoolTimetableViewModel, AllSchoolTimetableState>(
      AllSchoolTimetableViewModel.new,
    );

class CourseHeadState {
  const CourseHeadState({
    this.head,
    this.classes = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final SchoolCourseHead? head;
  final List<SchoolTeachingClass> classes;
  final bool isLoading;
  final String? errorMessage;
}

final courseHeadDetailProvider = FutureProvider.family<CourseHeadState, String>(
  (ref, courseHeadId) async {
    final repository = ref.read(allSchoolTimetableRepositoryProvider);
    await repository.ensureLocalDataReady();
    final head = await repository.findCourseHead(courseHeadId);
    if (head == null) {
      return const CourseHeadState(isLoading: false, errorMessage: '未找到课程');
    }
    final classes = await repository.loadTeachingClasses(courseHeadId);
    return CourseHeadState(head: head, classes: classes, isLoading: false);
  },
);

class TeachingClassDetailState {
  const TeachingClassDetailState({
    required this.teachingClass,
    required this.meetings,
  });

  final SchoolTeachingClass teachingClass;
  final List<SchoolClassMeeting> meetings;
}

final teachingClassDetailProvider =
    FutureProvider.family<TeachingClassDetailState?, String>((
      ref,
      teachingClassId,
    ) async {
      final repository = ref.read(allSchoolTimetableRepositoryProvider);
      await repository.ensureLocalDataReady();
      final teachingClass = await repository.findTeachingClass(teachingClassId);
      if (teachingClass == null) {
        return null;
      }
      final meetings = await repository.loadMeetings(teachingClassId);
      return TeachingClassDetailState(
        teachingClass: teachingClass,
        meetings: meetings,
      );
    });
