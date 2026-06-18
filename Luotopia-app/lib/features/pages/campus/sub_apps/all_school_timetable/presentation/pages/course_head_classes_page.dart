import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/pages/all_school_timetable_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/viewmodels/all_school_timetable_view_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseHeadClassesPage extends ConsumerWidget {
  const CourseHeadClassesPage({required this.args, super.key});

  final CourseHeadPageArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseHeadDetailProvider(args.courseHeadId));
    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('课程列表'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: ui.CircularProgressIndicator()),
        error: (error, _) => _CenteredMessage(text: error.toString()),
        data: (data) {
          final head = data.head;
          if (head == null) {
            return _CenteredMessage(text: data.errorMessage ?? '未找到课程');
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _CourseHeadSummary(head: head),
              const SizedBox(height: 14),
              Text(
                '${data.classes.length} 个教学班',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in data.classes)
                _TeachingClassTile(
                  item: item,
                  onTap: () => context.openSecondary(
                    AppRoutePaths.campusAllSchoolTimetableClass,
                    extra: TeachingClassDetailPageArgs(item.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CourseHeadSummary extends StatelessWidget {
  const _CourseHeadSummary({required this.head});

  final SchoolCourseHead head;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final meta = [
      head.courseNo,
      head.openCollege,
      if (head.credits != null) '${head.credits} 学分',
      if (head.courseNature.isNotEmpty) head.courseNature,
    ].where((item) => item.isNotEmpty).join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          head.courseName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          meta,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        if (head.teacherSummary.isNotEmpty ||
            head.weekdaySummary.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            [
              if (head.teacherSummary.isNotEmpty) head.teacherSummary,
              if (head.weekdaySummary.isNotEmpty) head.weekdaySummary,
            ].join(' · '),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _TeachingClassTile extends StatelessWidget {
  const _TeachingClassTile({required this.item, required this.onTap});

  final SchoolTeachingClass item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final teacher = [
      item.instructor,
      if (item.title.isNotEmpty) item.title,
    ].where((part) => part.isNotEmpty).join(' · ');
    final target = [
      if (item.grade.isNotEmpty) '${item.grade}级',
      if (item.major.isNotEmpty) item.major,
    ].join(' · ');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.teachingClassName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (teacher.isNotEmpty) teacher,
                        if (item.peopleRaw.isNotEmpty) item.peopleRaw,
                        if (target.isNotEmpty) target,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.scheduleSummary.isEmpty
                          ? item.weekdaySummary
                          : item.scheduleSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
