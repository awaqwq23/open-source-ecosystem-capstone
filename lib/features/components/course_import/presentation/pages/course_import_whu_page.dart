import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:luotopia/features/components/course_import/data/whu_course_import_service.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/whu_auth/whu_auth.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseImportWhuPage extends ConsumerStatefulWidget {
  const CourseImportWhuPage({super.key});

  @override
  ConsumerState<CourseImportWhuPage> createState() => _CourseImportWhuPageState();
}

class _CourseImportWhuPageState extends ConsumerState<CourseImportWhuPage> {
  final _service = WhuCourseImportService();
  final _nameController = TextEditingController();
  final _termController = TextEditingController();
  DateTime? _weekOneMonday;
  bool _submitting = false;
  String? _statusText;

  @override
  void dispose() {
    _nameController.dispose();
    _termController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isZh = _isChinese(context);
    final inferredTerm = _inferCurrentTerm(DateTime.now());
    final authState = ref.watch(whuAuthProvider);
    final cookieHeader = authState.cookieHeader;
    return ui.Scaffold(
      headers: [
        buildAppBar(
          title: isZh ? '武汉大学教务导入' : 'WHU Import',
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
            isZh ? '请先登录教务获取会话，再导入学期课表。' : 'Login first to get session, then import timetable.',
          ),
          const SizedBox(height: 16),
          ui.PrimaryButton(
            onPressed: _submitting ? null : _openLoginPage,
            leading: const Icon(AppIcons.web),
            child: Text(cookieHeader.isEmpty ? (isZh ? '登录教务并授权' : 'Login to WHU') : (isZh ? '已获取会话，重新登录' : 'Session acquired, relogin')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: isZh ? '课程表名称' : 'Timetable Name',
              hintText: isZh ? '例如：2026 春季学期' : 'e.g. 2026 Spring',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(AppIcons.calendar),
            title: Text(isZh ? '自动识别学期' : 'Detected Term'),
            subtitle: Text(
              isZh
                  ? '${inferredTerm.academicYearStart}-${inferredTerm.academicYearStart + 1} 学年 第${inferredTerm.semester}学期'
                  : '${inferredTerm.academicYearStart}-${inferredTerm.academicYearStart + 1} Semester ${inferredTerm.semester}',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(AppIcons.calendar),
            title: Text(isZh ? '第1周周一日期' : 'Week-1 Monday'),
            subtitle: Text(
              _weekOneMonday == null
                  ? (isZh ? '点击选择' : 'Tap to select')
                  : '${_weekOneMonday!.year}-${_weekOneMonday!.month.toString().padLeft(2, '0')}-${_weekOneMonday!.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(AppIcons.drillIn),
            onTap: _submitting ? null : () => _pickWeekOneMonday(context),
          ),
          const SizedBox(height: 4),
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
          if (_statusText != null) ...[
            const SizedBox(height: 12),
            Text(
              _statusText!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isZh = _isChinese(context);
    final authState = ref.read(whuAuthProvider);
    if (authState.cookieHeader.isEmpty) {
      _showMessage(isZh ? '请先完成教务登录授权。' : 'Please login first.');
      return;
    }
    if (_weekOneMonday == null) {
      _showMessage(isZh ? '请选择第1周周一日期。' : 'Please select Week-1 Monday.');
      return;
    }
    final inferredTerm = _inferCurrentTerm(DateTime.now());
    setState(() {
      _submitting = true;
      _statusText = isZh ? '正在校验并建立教务会话...' : 'Verifying and establishing education session...';
    });
    try {
      setState(() {
        _statusText = isZh ? '正在请求教务课表...' : 'Fetching timetable...';
      });
      final payload = await _service.loadCourses(
        cookieHeader: authState.cookieHeader,
        year: inferredTerm.academicYearStart,
        semester: inferredTerm.semester,
        weekOneMonday: _weekOneMonday!,
        homeSettings: ref.read(appHomeSettingsProvider),
      );
      final tableName = _nameController.text.trim().isEmpty
          ? (isZh ? '武大导入 ${DateTime.now().toLocal()}' : 'WHU Import ${DateTime.now().toLocal()}')
          : _nameController.text.trim();
      final termLabel = _termController.text.trim().isEmpty
          ? payload.termLabel
          : _termController.text.trim();
      final timetable = await ref.read(courseTimetableRepositoryProvider.notifier).createTimetable(
            name: tableName,
            source: CourseTimetableSource.whuJw,
            termLabel: termLabel,
          );
      await ref.read(courseTimetableRepositoryProvider.notifier).setActiveTimetable(timetable.id);

      final agendaRepo = ref.read(agendaItemRepositoryProvider.notifier);
      for (final draft in payload.items) {
        await agendaRepo.createItem(
          draft.copyWith(
            courseDetails: draft.courseDetails.copyWith(timetableId: timetable.id),
          ),
        );
      }

      if (!mounted) {
        return;
      }
      final today = DateUtils.dateOnly(DateTime.now());
      final currentWeekStart = today.subtract(Duration(days: today.weekday - DateTime.monday));
      final currentWeekEnd = currentWeekStart.add(const Duration(days: 7));
      final currentWeekCount = payload.items.where((item) {
        final startAt = item.startAt;
        final endAt = item.endAt;
        return endAt.isAfter(currentWeekStart) && startAt.isBefore(currentWeekEnd);
      }).length;
      _showMessage(
        isZh
            ? '导入完成：新增 ${payload.items.length} 条课程事项，当前周命中 $currentWeekCount 条，课程表「$tableName」。'
            : 'Imported ${payload.items.length} items ($currentWeekCount in current week) to "$tableName".',
      );
      setState(() {
        _statusText = isZh
            ? '导入完成：新增 ${payload.items.length} 条，当前周命中 $currentWeekCount 条。'
            : 'Import finished: ${payload.items.length} items, $currentWeekCount in current week.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (error is WhuSessionInvalidException) {
        await ref.read(whuAuthProvider.notifier).clearCookie();
      }
      setState(() {
        _statusText = isZh ? '导入失败：$error' : 'Import failed: $error';
      });
      _showMessage(isZh ? '导入失败：$error' : 'Import failed: $error');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _pickWeekOneMonday(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekOneMonday ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _weekOneMonday = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _openLoginPage() async {
    final cookieHeader = await context.push<String>(
      AppRoutePaths.settingsWhuAuthLogin,
    );
    if (!mounted || cookieHeader == null || cookieHeader.trim().isEmpty) {
      return;
    }
    await ref.read(whuAuthProvider.notifier).setCookie(cookieHeader.trim());
    _showMessage(
      _isChinese(context) ? '已获取教务会话，可开始导入。' : 'Session acquired. Ready to import.',
    );
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

  _InferredTerm _inferCurrentTerm(DateTime now) {
    final month = now.month;
    if (month >= 9) {
      return _InferredTerm(academicYearStart: now.year, semester: 1);
    }
    if (month == 8) {
      return _InferredTerm(academicYearStart: now.year - 1, semester: 3);
    }
    if (month == 1) {
      return _InferredTerm(academicYearStart: now.year - 1, semester: 1);
    }
    return _InferredTerm(academicYearStart: now.year - 1, semester: 2);
  }
}

class _InferredTerm {
  const _InferredTerm({
    required this.academicYearStart,
    required this.semester,
  });

  final int academicYearStart;
  final int semester;
}
