import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/course_schedule_repository.dart';
import '../../domain/models/teaching_class.dart';

/// State for Level 3: teaching class detail.
class TeachingClassDetailState {
  const TeachingClassDetailState({
    this.teachingClass,
    this.isLoading = true,
    this.errorMessage,
  });

  final TeachingClass? teachingClass;
  final bool isLoading;
  final String? errorMessage;

  TeachingClassDetailState copyWith({
    TeachingClass? teachingClass,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeachingClassDetailState(
      teachingClass: teachingClass ?? this.teachingClass,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TeachingClassDetailViewModel
    extends FamilyNotifier<TeachingClassDetailState, int> {
  @override
  TeachingClassDetailState build(int arg) {
    _load(arg);
    return const TeachingClassDetailState(isLoading: true);
  }

  Future<void> _load(int id) async {
    try {
      final repo = ref.read(courseScheduleRepositoryProvider);
      final tc = await repo.getTeachingClassById(id);
      state = state.copyWith(
        teachingClass: tc,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final teachingClassDetailViewModelProvider =
    NotifierProvider.family<TeachingClassDetailViewModel,
        TeachingClassDetailState, int>(
  TeachingClassDetailViewModel.new,
);
