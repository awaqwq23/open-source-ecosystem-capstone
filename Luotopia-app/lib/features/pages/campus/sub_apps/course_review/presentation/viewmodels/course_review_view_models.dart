import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/data/course_review_api.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/data/course_review_local_data.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/domain/models/course_review_models.dart';
import 'package:luotopia/shared/data/api_client.dart';

/// 评价对象键（courseId + teacherId），用于 FutureProvider.family。
@immutable
class CourseReviewSubjectKey {
  const CourseReviewSubjectKey(this.courseId, this.teacherId);

  final String courseId;
  final String teacherId;

  @override
  bool operator ==(Object other) =>
      other is CourseReviewSubjectKey &&
      other.courseId == courseId &&
      other.teacherId == teacherId;

  @override
  int get hashCode => Object.hash(courseId, teacherId);
}

// ---- Future providers ----

/// 本地课程搜索（按关键字）。
final courseReviewSearchProvider =
    FutureProvider.family<List<CourseReviewCourse>, String>((ref, keyword) async {
  final local = ref.read(courseReviewLocalDataProvider);
  return local.searchCourses(keyword);
});

/// 某课程的本地教师列表。
final courseReviewTeachersProvider =
    FutureProvider.family<List<CourseReviewTeacher>, String>((ref, courseId) async {
  final local = ref.read(courseReviewLocalDataProvider);
  return local.listTeachers(courseId);
});

/// 评价对象概览（免费）。
final courseReviewSubjectProvider =
    FutureProvider.family<CourseReviewSubject, CourseReviewSubjectKey>((
  ref,
  key,
) async {
  final api = ref.read(courseReviewApiProvider);
  return api.getSubject(courseId: key.courseId, teacherId: key.teacherId);
});

// ---- 会话视图模型：钱包 / 提交 / 兑换 / 删除 ----

class CourseReviewSessionState {
  const CourseReviewSessionState({
    this.wallet,
    this.isSubmitting = false,
    this.message,
    this.error,
  });

  final CourseReviewWallet? wallet;
  final bool isSubmitting;
  final String? message;
  final String? error;

  bool get hasAccess => wallet?.accessGrant?.isActive ?? false;

  CourseReviewSessionState copyWith({
    CourseReviewWallet? wallet,
    bool? isSubmitting,
    String? message,
    String? error,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return CourseReviewSessionState(
      wallet: wallet ?? this.wallet,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: clearMessage ? null : message ?? this.message,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class CourseReviewSessionViewModel extends Notifier<CourseReviewSessionState> {
  late CourseReviewApi _api;

  @override
  CourseReviewSessionState build() {
    _api = ref.read(courseReviewApiProvider);
    return const CourseReviewSessionState();
  }

  Future<void> refreshWallet() async {
    try {
      final wallet = await _api.getWallet();
      state = state.copyWith(wallet: wallet, clearError: true);
    } catch (error) {
      state = state.copyWith(error: _errorMessage(error));
    }
  }

  Future<bool> submitReview({
    required CourseReviewSubjectKey key,
    required int difficulty,
    required int workload,
    required int quality,
    required int interest,
    required String contentText,
    String rawGradeText = '',
    String finalAssessment = '',
    String attendanceText = '',
    String homeworkText = '',
  }) async {
    state = state.copyWith(isSubmitting: true, clearMessage: true, clearError: true);
    try {
      final result = await _api.submitReview(
        courseId: key.courseId,
        teacherId: key.teacherId,
        difficulty: difficulty,
        workload: workload,
        quality: quality,
        interest: interest,
        contentText: contentText,
        rawGradeText: rawGradeText,
        finalAssessment: finalAssessment,
        attendanceText: attendanceText,
        homeworkText: homeworkText,
      );
      state = state.copyWith(
        wallet: result.wallet,
        isSubmitting: false,
        message: '评价已发布，积分 +${result.wallet.balance - (state.wallet?.balance ?? 0)}',
      );
      ref.invalidate(courseReviewSubjectProvider(key));
      ref.invalidate(courseReviewListViewModelProvider);
      return true;
    } catch (error) {
      state = state.copyWith(isSubmitting: false, error: _errorMessage(error));
      return false;
    }
  }

  Future<bool> redeemAccess(int durationDays) async {
    state = state.copyWith(isSubmitting: true, clearMessage: true, clearError: true);
    try {
      final wallet = await _api.redeemAccess(durationDays);
      state = state.copyWith(
        wallet: wallet,
        isSubmitting: false,
        message: '已兑换 $durationDays 天查询权限',
      );
      ref.invalidate(courseReviewListViewModelProvider);
      return true;
    } catch (error) {
      state = state.copyWith(isSubmitting: false, error: _errorMessage(error));
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _api.deleteReview(reviewId);
      ref.invalidate(courseReviewListViewModelProvider);
      ref.invalidate(courseReviewSubjectProvider);
      return true;
    } catch (error) {
      state = state.copyWith(error: _errorMessage(error));
      return false;
    }
  }
}

final courseReviewSessionViewModelProvider =
    NotifierProvider<CourseReviewSessionViewModel, CourseReviewSessionState>(
      CourseReviewSessionViewModel.new,
    );

// ---- 评价列表视图模型 ----

class CourseReviewListState {
  const CourseReviewListState({
    this.key,
    this.items = const [],
    this.cursor = '',
    this.isLoading = false,
    this.hasLoaded = false,
    this.hasAccess = false,
    this.requiresLogin = false,
    this.error,
  });

  final CourseReviewSubjectKey? key;
  final List<CourseReview> items;
  final String cursor;
  final bool isLoading;
  final bool hasLoaded;
  final bool hasAccess;
  final bool requiresLogin;
  final String? error;

  bool get canLoadMore => cursor.isNotEmpty && !isLoading;

  CourseReviewListState copyWith({
    CourseReviewSubjectKey? key,
    List<CourseReview>? items,
    String? cursor,
    bool? isLoading,
    bool? hasLoaded,
    bool? hasAccess,
    bool? requiresLogin,
    String? error,
    bool clearError = false,
  }) {
    return CourseReviewListState(
      key: key ?? this.key,
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      hasAccess: hasAccess ?? this.hasAccess,
      requiresLogin: requiresLogin ?? this.requiresLogin,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class CourseReviewListViewModel extends Notifier<CourseReviewListState> {
  late CourseReviewApi _api;

  @override
  CourseReviewListState build() {
    _api = ref.read(courseReviewApiProvider);
    return const CourseReviewListState();
  }

  Future<void> load(CourseReviewSubjectKey key) async {
    state = CourseReviewListState(key: key, isLoading: true);
    await _fetch(reset: true);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    state = state.copyWith(isLoading: true, clearError: true);
    await _fetch(reset: false);
  }

  Future<void> refresh() async {
    if (state.key == null) return;
    state = state.copyWith(isLoading: true, cursor: '', clearError: true);
    await _fetch(reset: true);
  }

  Future<void> _fetch({required bool reset}) async {
    final key = state.key;
    if (key == null) return;
    try {
      final result = await _api.listReviews(
        courseId: key.courseId,
        teacherId: key.teacherId,
        cursor: reset ? '' : state.cursor,
      );
      final items = reset ? result.items : [...state.items, ...result.items];
      state = CourseReviewListState(
        key: key,
        items: items,
        cursor: result.nextCursor,
        hasLoaded: true,
        hasAccess: true,
      );
    } on ApiClientException catch (error) {
      if (error.statusCode == 403) {
        // access_required：无查询权限，不算错误，展示兑换引导。
        state = CourseReviewListState(
          key: key,
          hasLoaded: true,
          hasAccess: false,
        );
      } else if (error.statusCode == 401) {
        state = CourseReviewListState(
          key: key,
          hasLoaded: true,
          requiresLogin: true,
        );
      } else {
        state = state.copyWith(isLoading: false, error: error.message);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }
}

final courseReviewListViewModelProvider =
    NotifierProvider<CourseReviewListViewModel, CourseReviewListState>(
      CourseReviewListViewModel.new,
    );

String _errorMessage(Object error) {
  if (error is ApiClientException) return error.message;
  return error.toString();
}
