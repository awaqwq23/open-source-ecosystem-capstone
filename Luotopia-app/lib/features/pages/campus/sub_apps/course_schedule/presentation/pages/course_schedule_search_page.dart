import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_schedule/domain/models/course_group.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_schedule/presentation/viewmodels/course_schedule_search_view_model.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_schedule/presentation/widgets/course_group_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseScheduleSearchPage extends ConsumerWidget {
  const CourseScheduleSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseScheduleSearchViewModelProvider);
    final notifier = ref.read(courseScheduleSearchViewModelProvider.notifier);

    return ui.Scaffold(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(context, notifier, state.keyword),
            _buildFilterChips(context, ref, state),
            const SizedBox(height: 4),
            _buildResultStatus(context, state),
            const Divider(height: 1),
            Expanded(child: _buildResults(context, ref, state, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            '全校课表',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '2025-2026 第1学期',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    CourseScheduleSearchViewModel notifier,
    String keyword,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: keyword,
            selection: TextSelection.collapsed(offset: keyword.length),
          ),
        ),
        onChanged: notifier.updateKeyword,
        onSubmitted: (_) => notifier.submitSearch(),
        decoration: InputDecoration(
          hintText: '搜索课程名、课程号、教师、教室...',
          hintStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon: keyword.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    notifier.updateKeyword('');
                    notifier.submitSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    CourseScheduleSearchState state,
  ) {
    final notifier = ref.read(courseScheduleSearchViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: state.selectedSchool ?? '学院',
              icon: Icons.business_outlined,
              isActive: state.selectedSchool != null,
              onTap: notifier.toggleSchoolFilter,
              onClear: state.selectedSchool != null
                  ? () => notifier.setSchool(null)
                  : null,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: state.selectedGrade != null
                  ? '${state.selectedGrade}级'
                  : '年级',
              icon: Icons.grade_outlined,
              isActive: state.selectedGrade != null,
              onTap: notifier.toggleGradeFilter,
              onClear: state.selectedGrade != null
                  ? () => notifier.setGrade(null)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStatus(
    BuildContext context,
    CourseScheduleSearchState state,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!state.hasSearched || state.isLoading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            '共 ${state.groups.length} 门课程',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const Spacer(),
          Text(
            '相关度优先',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    WidgetRef ref,
    CourseScheduleSearchState state,
    CourseScheduleSearchViewModel notifier,
  ) {
    if (state.isSeeding) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state.hasSearched && state.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '没有找到匹配的课程',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: state.groups.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final group = state.groups[index];
        return CourseGroupCard(
          group: group,
          onTap: () => _openTeachingClassList(context, group),
        );
      },
    );
  }

  void _openTeachingClassList(BuildContext context, CourseGroup group) {
    context.openSecondary(
      AppRoutePaths.campusCourseScheduleTeachingClasses,
      extra: {
        'courseCode': group.courseCode,
        'courseName': group.courseName,
        'academicYear': group.academicYear,
        'semester': group.semester,
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isActive
          ? colors.primary.withValues(alpha: 0.1)
          : colors.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? colors.primary
                      : colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (isActive && onClear != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 14, color: colors.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
