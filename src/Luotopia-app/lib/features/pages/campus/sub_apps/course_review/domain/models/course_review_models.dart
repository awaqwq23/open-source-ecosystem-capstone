/// 课程评价客户端领域模型。评价对象 = 全校课表的 course_id + teacher_id。/// 本地课程搜索结果（跨学期课程目录项）。
class CourseReviewCourse {
  const CourseReviewCourse({
    required this.courseId,
    required this.courseNo,
    required this.courseName,
    required this.credits,
    required this.teacherCount,
  });

  final String courseId;
  final String courseNo;
  final String courseName;
  final String credits;
  final int teacherCount;
}

/// 某课程下的教师（跨学期去重），用于选择评价对象。
class CourseReviewTeacher {
  const CourseReviewTeacher({
    required this.teacherId,
    required this.name,
    required this.title,
    required this.classCount,
  });

  final String teacherId;
  final String name;
  final String title;
  final int classCount;
}

/// 评价对象聚合概览（服务端 `/courses/:courseId/teachers/:teacherId`）。
class CourseReviewSubject {
  const CourseReviewSubject({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.reviewCount,
    this.avgDifficulty,
    this.avgWorkload,
    this.avgQuality,
    this.avgInterest,
    required this.gradeSampleCount,
    this.avgGrade,
    this.latestReviewAt,
  });

  final String id;
  final String courseId;
  final String teacherId;
  final int reviewCount;
  final double? avgDifficulty;
  final double? avgWorkload;
  final double? avgQuality;
  final double? avgInterest;
  final int gradeSampleCount;
  final double? avgGrade;
  final DateTime? latestReviewAt;

  factory CourseReviewSubject.fromJson(Map<String, dynamic> json) {
    final s = (json['subject'] as Map<String, dynamic>?) ?? const {};
    return CourseReviewSubject(
      id: s['id'] as String? ?? '',
      courseId: s['course_id'] as String? ?? '',
      teacherId: s['teacher_id'] as String? ?? '',
      reviewCount: (s['review_count'] as num?)?.toInt() ?? 0,
      avgDifficulty: (s['avg_difficulty'] as num?)?.toDouble(),
      avgWorkload: (s['avg_workload'] as num?)?.toDouble(),
      avgQuality: (s['avg_quality'] as num?)?.toDouble(),
      avgInterest: (s['avg_interest'] as num?)?.toDouble(),
      gradeSampleCount: (s['grade_sample_count'] as num?)?.toInt() ?? 0,
      avgGrade: (s['avg_grade'] as num?)?.toDouble(),
      latestReviewAt: _parseTime(s['latest_review_at']),
    );
  }
}

/// 单条评价。
class CourseReview {
  const CourseReview({
    required this.id,
    required this.subjectId,
    required this.difficulty,
    required this.workload,
    required this.quality,
    required this.interest,
    required this.rawGradeText,
    this.gradeValue,
    required this.finalAssessment,
    required this.attendanceText,
    required this.homeworkText,
    required this.contentText,
    required this.createdAt,
  });

  final String id;
  final String subjectId;
  final int difficulty;
  final int workload;
  final int quality;
  final int interest;
  final String rawGradeText;
  final double? gradeValue;
  final String finalAssessment;
  final String attendanceText;
  final String homeworkText;
  final String contentText;
  final DateTime createdAt;

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: json['id'] as String? ?? '',
      subjectId: json['subject_id'] as String? ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 0,
      workload: (json['workload'] as num?)?.toInt() ?? 0,
      quality: (json['quality'] as num?)?.toInt() ?? 0,
      interest: (json['interest'] as num?)?.toInt() ?? 0,
      rawGradeText: json['raw_grade_text'] as String? ?? '',
      gradeValue: (json['grade_value'] as num?)?.toDouble(),
      finalAssessment: json['final_assessment'] as String? ?? '',
      attendanceText: json['attendance_text'] as String? ?? '',
      homeworkText: json['homework_text'] as String? ?? '',
      contentText: json['content_text'] as String? ?? '',
      createdAt:
          _parseTime(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// 查询权限授权区间。
class CourseReviewAccessGrant {
  const CourseReviewAccessGrant({
    required this.id,
    required this.startsAt,
    required this.expiresAt,
  });

  final String id;
  final DateTime startsAt;
  final DateTime expiresAt;

  bool get isActive => DateTime.now().isBefore(expiresAt);

  factory CourseReviewAccessGrant.fromJson(Map<String, dynamic> json) {
    return CourseReviewAccessGrant(
      id: json['id'] as String? ?? '',
      startsAt:
          _parseTime(json['starts_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt:
          _parseTime(json['expires_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// 钱包视图（余额 + 当前有效权限窗口）。
class CourseReviewWallet {
  const CourseReviewWallet({required this.balance, this.accessGrant});

  final int balance;
  final CourseReviewAccessGrant? accessGrant;

  factory CourseReviewWallet.fromJson(Map<String, dynamic> json) {
    final grant = json['access_grant'] as Map<String, dynamic>?;
    return CourseReviewWallet(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      accessGrant: grant == null
          ? null
          : CourseReviewAccessGrant.fromJson(grant),
    );
  }
}

class CourseReviewPolicy {
  const CourseReviewPolicy({
    required this.pointsPerReview,
    required this.accessCostPerDay,
    required this.maxRedeemDays,
  });

  final int pointsPerReview;
  final int accessCostPerDay;
  final int maxRedeemDays;

  int costForDays(int days) => days * accessCostPerDay;

  bool canRedeemDays(int days) =>
      days > 0 && (maxRedeemDays <= 0 || days <= maxRedeemDays);

  factory CourseReviewPolicy.fromJson(Map<String, dynamic> json) {
    return CourseReviewPolicy(
      pointsPerReview: (json['points_per_review'] as num?)?.toInt() ?? 0,
      accessCostPerDay: (json['access_cost_per_day'] as num?)?.toInt() ?? 0,
      maxRedeemDays: (json['max_redeem_days'] as num?)?.toInt() ?? 0,
    );
  }
}

DateTime? _parseTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
