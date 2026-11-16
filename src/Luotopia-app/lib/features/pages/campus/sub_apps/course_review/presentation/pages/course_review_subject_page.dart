import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/domain/models/course_review_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/presentation/viewmodels/course_review_view_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/presentation/pages/course_review_write_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseReviewSubjectPageArgs {
  const CourseReviewSubjectPageArgs({
    required this.courseId,
    required this.teacherId,
    required this.courseName,
    required this.courseNo,
    required this.teacherName,
  });

  final String courseId;
  final String teacherId;
  final String courseName;
  final String courseNo;
  final String teacherName;
}

class CourseReviewSubjectPage extends ConsumerStatefulWidget {
  const CourseReviewSubjectPage({required this.args, super.key});

  final CourseReviewSubjectPageArgs args;

  @override
  ConsumerState<CourseReviewSubjectPage> createState() =>
      _CourseReviewSubjectPageState();
}

class _CourseReviewSubjectPageState
    extends ConsumerState<CourseReviewSubjectPage> {
  late final CourseReviewSubjectKey _key = CourseReviewSubjectKey(
    widget.args.courseId,
    widget.args.teacherId,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final notifier = ref.read(courseReviewListViewModelProvider.notifier);
      notifier.load(_key);
      if (ref.read(luotopiaAuthProvider).isAuthenticated) {
        ref.read(courseReviewSessionViewModelProvider.notifier).refreshWallet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectAsync = ref.watch(courseReviewSubjectProvider(_key));
    final list = ref.watch(courseReviewListViewModelProvider);
    final session = ref.watch(courseReviewSessionViewModelProvider);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('课程评价'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _TitleBlock(args: widget.args),
          const SizedBox(height: 16),
          subjectAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: ui.CircularProgressIndicator()),
            ),
            error: (error, _) => _ErrorBox(text: '加载概览失败：$error'),
            data: (subject) => _OverviewCard(subject: subject),
          ),
          const SizedBox(height: 16),
          // 权限/登录/兑换引导
          _AccessGate(
            list: list,
            session: session,
            onLogin: () => context.openSecondary(AppRoutePaths.luotopiaLogin),
            onRedeem: () => context.openSecondary(
              AppRoutePaths.campusCourseReviewWallet,
            ),
          ),
          const SizedBox(height: 8),
          _ReviewListSection(
            list: list,
            onLoadMore: () =>
                ref.read(courseReviewListViewModelProvider.notifier).loadMore(),
          ),
          const SizedBox(height: 16),
          ui.PrimaryButton(
            onPressed: session.isSubmitting
                ? null
                : () => _openWrite(context),
            child: const Text('写评价（发布得积分）'),
          ),
          if (session.message != null) ...[
            const SizedBox(height: 8),
            Text(
              session.message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          if (session.error != null) ...[
            const SizedBox(height: 8),
            Text(
              session.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openWrite(BuildContext context) async {
    if (!ref.read(luotopiaAuthProvider).isAuthenticated) {
      _toast(context, '请先登录 Luotopia 账户');
      context.openSecondary(AppRoutePaths.luotopiaLogin);
      return;
    }
    await context.openSecondary(
      AppRoutePaths.campusCourseReviewWrite,
      extra: CourseReviewWritePageArgs(
        key: _key,
        courseName: widget.args.courseName,
        teacherName: widget.args.teacherName,
      ),
    );
    if (!mounted) return;
    ref.invalidate(courseReviewSubjectProvider(_key));
    ref.read(courseReviewListViewModelProvider.notifier).refresh();
    ref.read(courseReviewSessionViewModelProvider.notifier).refreshWallet();
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.args});

  final CourseReviewSubjectPageArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          args.courseName,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          [
            args.courseNo,
            if (args.teacherName.isNotEmpty) '任课：${args.teacherName}',
          ].join(' · '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.subject});

  final CourseReviewSubject subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (subject.reviewCount == 0) {
      return ui.Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '暂无评价，成为第一位评价者。',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }
    return ui.Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '共 ${subject.reviewCount} 条评价',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _Metric(label: '难度', value: subject.avgDifficulty),
                _Metric(label: '工作量', value: subject.avgWorkload),
                _Metric(label: '质量', value: subject.avgQuality),
                _Metric(label: '趣味', value: subject.avgInterest),
              ],
            ),
            if (subject.gradeSampleCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '成绩样本 ${subject.gradeSampleCount} 条 · 均分 ${subject.avgGrade?.toStringAsFixed(1)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ui.Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ui.BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: ui.BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(
            value == null ? '—' : value!.toStringAsFixed(1),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AccessGate extends StatelessWidget {
  const _AccessGate({
    required this.list,
    required this.session,
    required this.onLogin,
    required this.onRedeem,
  });

  final CourseReviewListState list;
  final CourseReviewSessionState session;
  final VoidCallback onLogin;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (list.requiresLogin) {
      return _Banner(
        text: '登录后查看完整评价正文',
        action: '去登录',
        onAction: onLogin,
      );
    }
    if (list.hasAccess) {
      final grant = session.wallet?.accessGrant;
      if (grant != null) {
        return Text(
          '查询权限有效期至 ${_formatDate(grant.expiresAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      }
      return const SizedBox.shrink();
    }
    return _Banner(
      text: '查看完整评价正文需要查询权限',
      action: '去兑换',
      onAction: onRedeem,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.action, required this.onAction});

  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ui.Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ui.BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: ui.BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
          ui.TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}

class _ReviewListSection extends StatelessWidget {
  const _ReviewListSection({
    required this.list,
    required this.onLoadMore,
  });

  final CourseReviewListState list;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!list.hasLoaded && list.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: ui.CircularProgressIndicator()),
      );
    }
    if (list.error != null) {
      return _ErrorBox(text: list.error!);
    }
    if (!list.hasAccess) {
      // 无权限时仅展示概览，不展示正文。
      return const SizedBox.shrink();
    }
    if (list.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            '暂无评价正文',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final review in list.items) _ReviewTile(review: review),
        if (list.canLoadMore)
          ui.TextButton(
            onPressed: onLoadMore,
            child: const Text('加载更多'),
          ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final CourseReview review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ui.Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _Tag('难度 ${review.difficulty}'),
                  _Tag('工作量 ${review.workload}'),
                  _Tag('质量 ${review.quality}'),
                  _Tag('趣味 ${review.interest}'),
                  if (review.gradeValue != null) _Tag('成绩 ${review.gradeValue!.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 8),
              Text(review.contentText, style: theme.textTheme.bodyMedium),
              if (review.finalAssessment.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('考核：${review.finalAssessment}', style: theme.textTheme.bodySmall),
              ],
              if (review.attendanceText.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('考勤：${review.attendanceText}', style: theme.textTheme.bodySmall),
              ],
              if (review.homeworkText.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('作业：${review.homeworkText}', style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 6),
              Text(
                _formatDate(review.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ui.Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ui.BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: ui.BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime time) {
  return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
}
