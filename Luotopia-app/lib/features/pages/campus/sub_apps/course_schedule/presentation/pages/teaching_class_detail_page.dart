import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_schedule/domain/models/teaching_class.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_schedule/presentation/viewmodels/teaching_class_detail_view_model.dart';

class TeachingClassDetailPage extends ConsumerWidget {
  const TeachingClassDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachingClassDetailViewModelProvider(id));
    final tc = state.teachingClass;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, tc),
            const Divider(height: 1),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : tc == null
                      ? Center(
                          child: Text(
                            state.errorMessage ?? '未找到课程信息',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : _buildDetail(context, tc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TeachingClass? tc) {
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
              tc?.courseName ?? '课程详情',
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

  Widget _buildDetail(BuildContext context, TeachingClass tc) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Course basic info ──
        _SectionHeader(title: '课程信息'),
        const SizedBox(height: 8),
        _InfoRow(label: '课程名称', value: tc.courseName),
        _InfoRow(label: '课程号', value: tc.courseCode),
        _InfoRow(label: '学分', value: '${tc.credits}'),
        _InfoRow(label: '开课学院', value: tc.school),
        _InfoRow(label: '课程性质', value: tc.courseNature),
        _InfoRow(label: '课程类别', value: tc.courseCategory),
        _InfoRow(label: '开课类型', value: tc.courseType),

        const SizedBox(height: 20),

        // ── Teaching class info ──
        _SectionHeader(title: '教学班信息'),
        const SizedBox(height: 8),
        _InfoRow(label: '教学班', value: tc.teachingClassName),
        _InfoRow(label: '学年', value: tc.academicYear),
        _InfoRow(label: '学期', value: '第${tc.semester}学期'),
        _InfoRow(label: '年级', value: '${tc.grade}级'),
        _InfoRow(label: '专业', value: tc.major),
        _InfoRow(label: '计划学院', value: tc.planSchool),

        const SizedBox(height: 20),

        // ── Teacher info ──
        _SectionHeader(title: '教师信息'),
        const SizedBox(height: 8),
        _InfoRow(label: '教师', value: tc.teacher),
        _InfoRow(label: '职称', value: tc.teacherTitle),
        if (tc.otherTeachers != null && tc.otherTeachers!.isNotEmpty)
          _InfoRow(label: '其他教师', value: tc.otherTeachers!),

        const SizedBox(height: 20),

        // ── Time & location ──
        _SectionHeader(title: '时间地点'),
        const SizedBox(height: 8),
        if (tc.scheduleMon != null && tc.scheduleMon!.isNotEmpty)
          _InfoRow(label: '周一', value: tc.scheduleMon!),
        if (tc.scheduleTue != null && tc.scheduleTue!.isNotEmpty)
          _InfoRow(label: '周二', value: tc.scheduleTue!),
        if (tc.scheduleWed != null && tc.scheduleWed!.isNotEmpty)
          _InfoRow(label: '周三', value: tc.scheduleWed!),
        if (tc.scheduleThu != null && tc.scheduleThu!.isNotEmpty)
          _InfoRow(label: '周四', value: tc.scheduleThu!),
        if (tc.scheduleFri != null && tc.scheduleFri!.isNotEmpty)
          _InfoRow(label: '周五', value: tc.scheduleFri!),
        if (tc.scheduleSat != null && tc.scheduleSat!.isNotEmpty)
          _InfoRow(label: '周六', value: tc.scheduleSat!),
        if (tc.scheduleSun != null && tc.scheduleSun!.isNotEmpty)
          _InfoRow(label: '周日', value: tc.scheduleSun!),

        const SizedBox(height: 20),

        // ── Enrollment & hours ──
        _SectionHeader(title: '容量与学时'),
        const SizedBox(height: 8),
        _InfoRow(label: '上课人数', value: tc.studentCount),
        if (tc.theoryHours != null)
          _InfoRow(label: '理论学时', value: '${tc.theoryHours}'),
        if (tc.computerHours != null)
          _InfoRow(label: '上机学时', value: '${tc.computerHours}'),
        if (tc.experimentHours != null)
          _InfoRow(label: '实验学时', value: '${tc.experimentHours}'),
        if (tc.practiceHours != null)
          _InfoRow(label: '实践学时', value: '${tc.practiceHours}'),
        if (tc.totalHours > 0)
          _InfoRow(label: '总学时', value: '${tc.totalHours}'),

        const SizedBox(height: 20),

        // ── Notes & materials ──
        _SectionHeader(title: '资料与备注'),
        const SizedBox(height: 8),
        if (tc.textbook != null && tc.textbook!.isNotEmpty)
          _InfoRow(label: '教材名称', value: tc.textbook!),
        if (tc.publisher != null && tc.publisher!.isNotEmpty)
          _InfoRow(label: '出版社', value: tc.publisher!),
        if (tc.notes != null && tc.notes!.isNotEmpty)
          _InfoRow(label: '选课备注', value: tc.notes!),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
