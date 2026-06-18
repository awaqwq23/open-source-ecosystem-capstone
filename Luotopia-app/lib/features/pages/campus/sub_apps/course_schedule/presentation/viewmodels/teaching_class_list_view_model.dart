import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/course_schedule_repository.dart';
import '../../domain/models/teaching_class.dart';

/// Provider family key for Level 2: teaching class list.
class TeachingClassListKey {
  const TeachingClassListKey({
    required this.courseCode,
    required this.academicYear,
    required this.semester,
  });

  final String courseCode;
  final String academicYear;
  final int semester;

  @override
  bool operator ==(Object other) =>
      other is TeachingClassListKey &&
      other.courseCode == courseCode &&
      other.academicYear == academicYear &&
      other.semester == semester;

  @override
  int get hashCode => Object.hash(courseCode, academicYear, semester);
}

/// State for Level 2 page.
class TeachingClassListState {
  const TeachingClassListState({
    this.classes = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<TeachingClass> classes;
  final bool isLoading;
  final String? errorMessage;

  TeachingClassListState copyWith({
    List<TeachingClass>? classes,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeachingClassListState(
      classes: classes ?? this.classes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TeachingClassListViewModel
    extends FamilyNotifier<TeachingClassListState, TeachingClassListKey> {
  @override
  TeachingClassListState build(TeachingClassListKey arg) {
    _load(arg);
    return const TeachingClassListState(isLoading: true);
  }

  Future<void> _load(TeachingClassListKey key) async {
    try {
      final repo = ref.read(courseScheduleRepositoryProvider);
      final classes = await repo.getTeachingClasses(
        courseCode: key.courseCode,
        academicYear: key.academicYear,
        semester: key.semester,
      );
      state = state.copyWith(classes: classes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final teachingClassListViewModelProvider =
    NotifierProvider.family<TeachingClassListViewModel, TeachingClassListState,
        TeachingClassListKey>(
  TeachingClassListViewModel.new,
);
