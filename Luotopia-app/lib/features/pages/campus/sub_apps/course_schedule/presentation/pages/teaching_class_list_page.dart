import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_schedule/presentation/viewmodels/teaching_class_list_view_model.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_schedule/presentation/widgets/teaching_class_tile.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class TeachingClassListPage extends ConsumerWidget {
  const TeachingClassListPage({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.academicYear,
    required this.semester,
  });

  final String courseCode;
  final String courseName;
  final String academicYear;
  final int semester;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = TeachingClassListKey(
      courseCode: courseCode,
      academicYear: academicYear,
      semester: semester,
    );
    final state = ref.watch(teachingClassListViewModelProvider(key));

    return ui.Scaffold(
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, key),
            _buildCourseInfo(context),
            const Divider(height: 1),
            Expanded(child: _buildList(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TeachingClassListKey key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              courseName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            courseCode,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.5),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$academicYear 第$semester学期',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, TeachingClassListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state.classes.isEmpty) {
      return Center(
        child: Text(
          '未找到教学班信息',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: state.classes.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final tc = state.classes[index];
        return TeachingClassTile(
          teachingClass: tc,
          onTap: () => _openDetail(context, tc.id),
        );
      },
    );
  }

  void _openDetail(BuildContext context, int id) {
    context.openSecondary(
      AppRoutePaths.campusCourseScheduleDetail.replaceFirst(':id', '$id'),
      extra: {'id': id, 'courseName': courseName},
    );
  }
}
