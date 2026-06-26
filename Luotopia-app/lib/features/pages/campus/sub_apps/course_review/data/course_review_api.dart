import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/domain/models/course_review_models.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';
import 'package:luotopia/shared/data/api_client.dart';

/// 课程评价 HTTP 层，复用统一 apiClientProvider（已带 Luotopia access token）。
class CourseReviewApi {
  CourseReviewApi(this._api);

  static const String _base = '/api/v1/course-reviews';

  final ApiClient _api;

  /// 评价对象概览（免费）。
  Future<CourseReviewSubject> getSubject({
    required String courseId,
    required String teacherId,
  }) async {
    final json = await _api.get('$_base/courses/$courseId/teachers/$teacherId');
    return CourseReviewSubject.fromJson(json);
  }

  /// 评价正文列表（需权限）。返回 (列表, 下一页游标)。
  Future<({List<CourseReview> items, String nextCursor})> listReviews({
    required String courseId,
    required String teacherId,
    String cursor = '',
    int limit = 10,
  }) async {
    final params = <String>[];
    if (cursor.isNotEmpty) params.add('cursor=${Uri.encodeComponent(cursor)}');
    params.add('limit=$limit');
    final json = await _api
        .get('$_base/courses/$courseId/teachers/$teacherId/reviews?${params.join('&')}');
    final items = (json['items'] as List? ?? const [])
        .map((e) => CourseReview.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return (items: items, nextCursor: (json['next_cursor'] as String?) ?? '');
  }

  /// 提交评价，返回评价与最新钱包。
  Future<({CourseReview review, CourseReviewWallet wallet})> submitReview({
    required String courseId,
    required String teacherId,
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
    final json = await _api.post(
      '$_base/courses/$courseId/teachers/$teacherId/reviews',
      body: {
        'difficulty': difficulty,
        'workload': workload,
        'quality': quality,
        'interest': interest,
        'raw_grade_text': rawGradeText,
        'final_assessment': finalAssessment,
        'attendance_text': attendanceText,
        'homework_text': homeworkText,
        'content_text': contentText,
      },
    );
    final review = CourseReview.fromJson((json['review'] as Map<String, dynamic>?) ?? const {});
    final wallet = CourseReviewWallet.fromJson((json['wallet'] as Map<String, dynamic>?) ?? const {});
    return (review: review, wallet: wallet);
  }

  Future<void> deleteReview(String reviewId) async {
    await _api.delete('$_base/reviews/$reviewId');
  }

  Future<CourseReviewWallet> getWallet() async {
    final json = await _api.get('$_base/me/wallet');
    return CourseReviewWallet.fromJson(json);
  }

  Future<List<CourseReview>> myReviews() async {
    final json = await _api.get('$_base/me/reviews');
    return (json['items'] as List? ?? const [])
        .map((e) => CourseReview.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<CourseReviewWallet> redeemAccess(int durationDays) async {
    final json = await _api.post(
      '$_base/access/redeem',
      body: {'duration_days': durationDays},
    );
    return CourseReviewWallet.fromJson(json);
  }
}

// 引用 pull_providers 中导出的 apiClientProvider（同文件定义）。
final courseReviewApiProvider = Provider<CourseReviewApi>((ref) {
  return CourseReviewApi(ref.read(apiClientProvider));
});
