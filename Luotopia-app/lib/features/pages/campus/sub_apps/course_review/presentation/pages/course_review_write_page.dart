import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/presentation/viewmodels/course_review_view_models.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseReviewWritePageArgs {
  const CourseReviewWritePageArgs({
    required this.key,
    required this.courseName,
    required this.teacherName,
  });

  final CourseReviewSubjectKey key;
  final String courseName;
  final String teacherName;
}

class CourseReviewWritePage extends ConsumerStatefulWidget {
  const CourseReviewWritePage({required this.args, super.key});

  final CourseReviewWritePageArgs args;

  @override
  ConsumerState<CourseReviewWritePage> createState() =>
      _CourseReviewWritePageState();
}

class _CourseReviewWritePageState extends ConsumerState<CourseReviewWritePage> {
  int _difficulty = 3;
  int _workload = 3;
  int _quality = 3;
  int _interest = 3;
  final _contentController = TextEditingController();
  final _gradeController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _attendanceController = TextEditingController();
  final _homeworkController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _gradeController.dispose();
    _assessmentController.dispose();
    _attendanceController.dispose();
    _homeworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          title: const Text('写评价'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(
            '${widget.args.courseName} · ${widget.args.teacherName}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _RatingRow(label: '难度（越高越难）', value: _difficulty, onChanged: (v) => setState(() => _difficulty = v)),
          _RatingRow(label: '工作量（越高越重）', value: _workload, onChanged: (v) => setState(() => _workload = v)),
          _RatingRow(label: '质量（越高越好）', value: _quality, onChanged: (v) => setState(() => _quality = v)),
          _RatingRow(label: '趣味（越高越有趣）', value: _interest, onChanged: (v) => setState(() => _interest = v)),
          const SizedBox(height: 12),
          ui.TextField(
            controller: _contentController,
            minLines: 3,
            maxLines: 8,
            hintText: '课程内容与评价（必填）',
          ),
          const SizedBox(height: 10),
          ui.TextField(
            controller: _gradeController,
            hintText: '成绩（可选，如 90 / 优）',
          ),
          const SizedBox(height: 10),
          ui.TextField(
            controller: _assessmentController,
            minLines: 1,
            maxLines: 4,
            hintText: '期末考核方式（可选）',
          ),
          const SizedBox(height: 10),
          ui.TextField(
            controller: _attendanceController,
            minLines: 1,
            maxLines: 4,
            hintText: '考勤情况（可选）',
          ),
          const SizedBox(height: 10),
          ui.TextField(
            controller: _homeworkController,
            minLines: 1,
            maxLines: 4,
            hintText: '平时作业（可选）',
          ),
          const SizedBox(height: 20),
          ui.PrimaryButton(
            onPressed: session.isSubmitting ? null : _submit,
            child: session.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: ui.CircularProgressIndicator(size: 18),
                  )
                : const Text('发布评价'),
          ),
          if (session.error != null) ...[
            const SizedBox(height: 10),
            Text(
              session.error!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      _toast('请填写课程内容与评价');
      return;
    }
    final ok = await ref.read(courseReviewSessionViewModelProvider.notifier).submitReview(
          key: widget.args.key,
          difficulty: _difficulty,
          workload: _workload,
          quality: _quality,
          interest: _interest,
          contentText: content,
          rawGradeText: _gradeController.text.trim(),
          finalAssessment: _assessmentController.text.trim(),
          attendanceText: _attendanceController.text.trim(),
          homeworkText: _homeworkController.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      _toast('评价已发布');
      Navigator.of(context).maybePop();
    }
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          for (var i = 1; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: ui.IconButton.ghost(
                icon: Icon(
                  i <= value ? Icons.star : Icons.star_border,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}
