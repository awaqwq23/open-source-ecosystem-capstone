import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/data/drift_all_school_timetable_repository.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';

class AllSchoolTimetableState {
  const AllSchoolTimetableState({
    this.terms = const [],
    this.query = const AllSchoolTimetableQuery(),
    this.courseHeads = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  final List<SchoolTimetableTerm> terms;
  final AllSchoolTimetableQuery query;
  final List<SchoolCourseHead> courseHeads;
  final bool isLoading;
  final bool isSyncing;
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
    bool? isSyncing,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? hasLoaded,
  }) {
    return AllSchoolTimetableState(
      terms: terms ?? this.terms,
      query: query ?? this.query,
      courseHeads: courseHeads ?? this.courseHeads,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class AllSchoolTimetableViewModel extends Notifier<AllSchoolTimetableState> {
  late AllSchoolTimetableRepository _repository;

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
      if (_hasActiveFilter(query)) {
        final heads = await _repository.searchCourseHeads(query);
        state = state.copyWith(
          terms: terms,
          query: query,
          courseHeads: heads,
          isLoading: false,
          hasLoaded: true,
          clearErrorMessage: true,
        );
      } else {
        state = state.copyWith(
          terms: terms,
          query: query,
          isLoading: false,
          hasLoaded: true,
          clearErrorMessage: true,
        );
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  /// 从服务器同步全校课表数据
  Future<void> sync() async {
    if (state.isSyncing) {
      return;
    }
    state = state.copyWith(isSyncing: true, clearErrorMessage: true);
    try {
      final service = ref.read(unifiedPullServiceProvider);
      final result = await service.pullPublicScoped(
        trigger: 'manual',
        scopes: const ['school_timetable'],
      );
      if (result.isError) {
        throw result.error!;
      }
      // 同步完成后刷新页面数据
      await load();
      state = state.copyWith(isSyncing: false);
    } catch (error) {
      state = state.copyWith(isSyncing: false, errorMessage: '同步失败：$error');
    }
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

  Future<void> applyAdvancedFilters({
    required String courseName,
    required String teacher,
    required String teachingClass,
    required String openDepartment,
    required String studentCollege,
    required String grade,
    required String major,
    required String courseCategory,
    required String departmentOrCollege,
    required String openType,
    required String courseNature,
  }) {
    return _updateQuery(
      state.query.copyWith(
        courseName: courseName,
        teacher: teacher,
        teachingClass: teachingClass,
        openDepartment: openDepartment,
        studentCollege: studentCollege,
        grade: grade,
        major: major,
        courseCategory: courseCategory,
        departmentOrCollege: departmentOrCollege,
        openType: openType,
        courseNature: courseNature,
      ),
    );
  }

  Future<void> clearAdvancedFilters() {
    return _updateQuery(
      state.query.copyWith(
        courseName: '',
        teacher: '',
        teachingClass: '',
        openDepartment: '',
        studentCollege: '',
        grade: '',
        major: '',
        courseCategory: '',
        departmentOrCollege: '',
        openType: '',
        courseNature: '',
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
      if (_hasActiveFilter(query)) {
        final heads = await _repository.searchCourseHeads(query);
        state = state.copyWith(
          courseHeads: heads,
          isLoading: false,
          clearErrorMessage: true,
        );
      } else {
        state = state.copyWith(
          courseHeads: const [],
          isLoading: false,
          clearErrorMessage: true,
        );
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  static bool _hasActiveFilter(AllSchoolTimetableQuery query) {
    return query.keyword.isNotEmpty || query.hasAdvancedFilters;
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

class CourseHeadDetailQuery {
  const CourseHeadDetailQuery({required this.termKey, required this.id});

  final String termKey;
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseHeadDetailQuery &&
          other.termKey == termKey &&
          other.id == id;

  @override
  int get hashCode => Object.hash(termKey, id);
}

final courseHeadDetailProvider =
    FutureProvider.family<CourseHeadState, CourseHeadDetailQuery>((
      ref,
      args,
    ) async {
      final repository = ref.read(allSchoolTimetableRepositoryProvider);
      final head = await repository.findCourseHead(
        termKey: args.termKey,
        id: args.id,
      );
      if (head == null) {
        return const CourseHeadState(isLoading: false, errorMessage: '未找到课程');
      }
      final classes = await repository.loadTeachingClasses(
        termKey: args.termKey,
        courseHeadId: args.id,
      );
      return CourseHeadState(head: head, classes: classes, isLoading: false);
    });

class TeachingClassDetailState {
  const TeachingClassDetailState({
    required this.teachingClass,
    required this.meetings,
  });

  final SchoolTeachingClass teachingClass;
  final List<SchoolClassMeeting> meetings;
}

class TeachingClassDetailQuery {
  const TeachingClassDetailQuery({required this.termKey, required this.id});

  final String termKey;
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeachingClassDetailQuery &&
          other.termKey == termKey &&
          other.id == id;

  @override
  int get hashCode => Object.hash(termKey, id);
}

final teachingClassDetailProvider =
    FutureProvider.family<TeachingClassDetailState?, TeachingClassDetailQuery>((
      ref,
      args,
    ) async {
      final repository = ref.read(allSchoolTimetableRepositoryProvider);
      final teachingClass = await repository.findTeachingClass(
        termKey: args.termKey,
        id: args.id,
      );
      if (teachingClass == null) {
        return null;
      }
      final meetings = await repository.loadMeetings(
        termKey: args.termKey,
        teachingClassId: args.id,
      );
      return TeachingClassDetailState(
        teachingClass: teachingClass,
        meetings: meetings,
      );
    });
