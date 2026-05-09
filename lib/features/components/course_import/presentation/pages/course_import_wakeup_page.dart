import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:luotopia/features/components/course_import/data/wakeup_course_import_adapter.dart';
import 'package:luotopia/features/components/course_import/domain/models/course_import_models.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseImportWakeupPage extends ConsumerStatefulWidget {
  const CourseImportWakeupPage({super.key});

  @override
  ConsumerState<CourseImportWakeupPage> createState() => _CourseImportWakeupPageState();
}

class _CourseImportWakeupPageState extends ConsumerState<CourseImportWakeupPage> {
  final _adapter = const WakeupCourseImportAdapter();
  final _nameController = TextEditingController();
  final _payloadController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isZh = _isChinese(context);
    return ui.Scaffold(
      headers: [
        buildAppBar(
          title: isZh ? 'Wakeup 导入' : 'Wakeup Import',
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            isZh
                ? '支持粘贴 Wakeup 分享口令或链接。当前版本先提供占位流程。'
                : 'Paste Wakeup share code/link. Parser is not connected in this version.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: isZh ? '课程表名称' : 'Timetable Name',
              hintText: isZh ? '例如：Wakeup 导入 1' : 'e.g. Wakeup Import 1',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _payloadController,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: isZh ? '分享口令或链接' : 'Share Code / Link',
              hintText: isZh ? '粘贴 Wakeup 分享内容' : 'Paste shared content',
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
                : const Icon(AppIcons.import),
            child: Text(isZh ? '开始导入' : 'Start Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final request = CourseImportRequest(
        timetableName: _nameController.text.trim(),
        payload: _payloadController.text.trim(),
      );
      final result = await _adapter.import(request);
      if (!mounted) {
        return;
      }
      if (result.success) {
        await ref.read(courseTimetableRepositoryProvider.notifier).createTimetable(
              name: request.timetableName,
              source: _adapter.source,
            );
      }
      _showMessage(result.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _showMessage(String message) async {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_isChinese(dialogContext) ? '确定' : 'OK'),
            ),
          ],
        );
      },
    );
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
  }
}
