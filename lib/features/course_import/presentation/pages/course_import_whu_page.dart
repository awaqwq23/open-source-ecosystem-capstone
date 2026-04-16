import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/course_import/data/whu_course_import_adapter.dart';
import 'package:huajuan_agenda/features/course_import/domain/models/course_import_models.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseImportWhuPage extends ConsumerStatefulWidget {
  const CourseImportWhuPage({super.key});

  @override
  ConsumerState<CourseImportWhuPage> createState() => _CourseImportWhuPageState();
}

class _CourseImportWhuPageState extends ConsumerState<CourseImportWhuPage> {
  final _adapter = const WhuCourseImportAdapter();
  final _nameController = TextEditingController();
  final _termController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _termController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isZh = _isChinese(context);
    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: Text(isZh ? '武汉大学教务导入' : 'WHU Import'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            isZh
                ? '首版先提供导入流程与课程表管理链路，解析器仍在接入。'
                : 'V1 provides import flow and timetable management. Parser is not connected yet.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: isZh ? '课程表名称' : 'Timetable Name',
              hintText: isZh ? '例如：2026 春季学期' : 'e.g. 2026 Spring',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _termController,
            decoration: InputDecoration(
              labelText: isZh ? '学期标识（可选）' : 'Term Label (Optional)',
              hintText: isZh ? '例如：2025-2026-2' : 'e.g. 2025-2026-2',
            ),
          ),
          const SizedBox(height: 20),
          ui.PrimaryButton(
            onPressed: _submitting ? null : _submit,
            leading: _submitting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(AppIcons.web),
            child: Text(isZh ? '开始导入' : 'Start Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final isZh = _isChinese(context);
      final request = CourseImportRequest(
        timetableName: _nameController.text.trim(),
        termLabel: _termController.text.trim(),
      );
      final result = await _adapter.import(request);
      if (!mounted) {
        return;
      }
      if (result.success) {
        await ref.read(courseTimetableRepositoryProvider.notifier).createTimetable(
              name: request.timetableName,
              source: _adapter.source,
              termLabel: request.termLabel,
            );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          action: result.success
              ? null
              : SnackBarAction(
                  label: isZh ? '知道了' : 'OK',
                  onPressed: () {},
                ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
  }
}
