import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/motion/app_motion_widgets.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/data/course_review_local_data.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/domain/models/course_review_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/presentation/viewmodels/course_review_view_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/presentation/pages/course_review_subject_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

/// 课程评价入口：先搜课程，再选拾该课程的教师，进入评价对象页。
class CourseReviewPage extends ConsumerStatefulWidget {
  const CourseReviewPage({super.key});

  @override
  ConsumerState<CourseReviewPage> createState() => _CourseReviewPageState();
}

class _CourseReviewPageState extends ConsumerState<CourseReviewPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _keyword = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _keyword = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = _keyword.isEmpty
        ? null
        : ref.watch(courseReviewSearchProvider(_keyword));

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
          trailing: [
            ui.IconButton.ghost(
              icon: const Icon(Icons.account_balance_wallet, size: 20),
              onPressed: () => context.openSecondary(
                AppRoutePaths.campusCourseReviewWallet,
              ),
            ),
          ],
        ),
      ],
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            '选择课程与教师，查看或发布评价。评价对象为跨学期的“课程 + 任课教师”组合。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ui.TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            hintText: '搜课程名或课程号',
            features: [
              const ui.InputLeadingFeature(Icon(Icons.search, size: 16)),
              if (_searchController.text.isNotEmpty)
                ui.InputTrailingFeature(
                  ui.IconButton.ghost(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _keyword = '');
                    },
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (async == null)
            _Hint(text: '输入关键字搜索全校课表中的课程。', icon: Icons.search)
          else
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: ui.CircularProgressIndicator()),
              ),
              error: (error, _) => _Hint(text: '查询失败：$error', icon: Icons.error_outline),
              data: (courses) => courses.isEmpty
                  ? _Hint(text: '没有找到相关课程', icon: Icons.search_off)
                  : Column(
                      children: [
                        for (final course in courses)
                          _CourseTile(
                            course: course,
                            onTap: () => _openTeachers(course),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Future<void> _openTeachers(CourseReviewCourse course) async {
    final context = this.context;
    final teachers = await ref
        .read(courseReviewLocalDataProvider)
        .listTeachers(course.courseId);
    if (!context.mounted) return;
    if (teachers.isEmpty) {
      _toast(context, '该课程暂无可用教师');
      return;
    }
    await ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) => AppSheetEntrance(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择任课教师',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${course.courseName} · ${course.courseNo}',
                style: Theme.of(sheetContext)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(sheetContext).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              for (final teacher in teachers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ui.CardButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () {
                      ui.closeSheet(sheetContext);
                      context.openSecondary(
                        AppRoutePaths.campusCourseReviewSubject,
                        extra: CourseReviewSubjectPageArgs(
                          courseId: course.courseId,
                          teacherId: teacher.teacherId,
                          courseName: course.courseName,
                          courseNo: course.courseNo,
                          teacherName: teacher.name,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(teacher.name.isEmpty ? '（未署名教师）' : teacher.name),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (teacher.title.isNotEmpty) teacher.title,
                              '${teacher.classCount} 个教学班',
                            ].join(' · '),
                            style: Theme.of(sheetContext).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course, required this.onTap});

  final CourseReviewCourse course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ui.CardButton(
        alignment: Alignment.centerLeft,
        onPressed: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.courseName, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                [
                  course.courseNo,
                  if (course.credits.isNotEmpty) '${course.credits} 学分',
                  '${course.teacherCount} 位教师',
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
