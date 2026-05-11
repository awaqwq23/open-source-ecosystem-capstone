import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/components/course_import/data/whu_course_import_service.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/whu_auth/whu_auth.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/presentation/widgets/app_date_time_pickers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

const double _editorRowHeight = 56;

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
    final theme = Theme.of(context);
    final isZh = _isChinese(context);
    final inferredTerm = _inferCurrentTerm(DateTime.now());
    final authState = ref.watch(whuAuthProvider);
    final cookieHeader = authState.cookieHeader;
    final hasCookie = cookieHeader.isNotEmpty;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: Text(isZh ? '武大教务导入' : 'WHU Import'),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 登录授权 ──
            _EditorSection(
              children: [
                _ActionRow(
                  label: isZh ? '教务授权' : 'Auth',
                  value: hasCookie
                      ? (isZh ? '已获取会话' : 'Session acquired')
                      : (isZh ? '未登录' : 'Not logged in'),
                  leadingIcon: AppIcons.web,
                  onTap: _submitting ? null : _openLoginPage,
                ),
              ],
            ),
            const Gap(20),

            // ── 导入配置 ──
            _EditorSection(
              children: [
                _RoundedTextField(
                  controller: _nameController,
                  hintText: isZh ? '课程表名称（如：2026 春季学期）' : 'Timetable name (e.g. 2026 Spring)',
                ),
                _DividerLine(),
                _ActionRow(
                  label: isZh ? '自动识别学期' : 'Detected Term',
                  value: isZh
                      ? '${inferredTerm.academicYearStart}-${inferredTerm.academicYearStart + 1} 第${inferredTerm.semester}学期'
                      : '${inferredTerm.academicYearStart}-${inferredTerm.academicYearStart + 1} Sem ${inferredTerm.semester}',
                  leadingIcon: AppIcons.calendar,
                ),
                _DividerLine(),
                _ActionRow(
                  label: isZh ? '第1周周一' : 'Week-1 Monday',
                  value: _weekOneMonday == null
                      ? (isZh ? '点击选择' : 'Tap to select')
                      : '${_weekOneMonday!.year}-${_weekOneMonday!.month.toString().padLeft(2, '0')}-${_weekOneMonday!.day.toString().padLeft(2, '0')}',
                  leadingIcon: AppIcons.calendar,
                  onTap: _submitting ? null : () => _pickWeekOneMonday(context),
                ),
                _DividerLine(),
                _RoundedTextField(
                  controller: _termController,
                  hintText: isZh ? '学期标识（可选，如：2025-2026-2）' : 'Term label (optional)',
                ),
              ],
            ),
            const Gap(24),

            // ── 提交 ──
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ui.PrimaryButton(
                onPressed: _submitting ? null : _submit,
                leading: _submitting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(AppIcons.import, size: 18),
                child: Text(isZh ? '开始导入' : 'Start Import'),
              ),
            ),

            if (_statusText != null) ...[
              const Gap(12),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  _statusText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
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

      setState(() {
        _statusText = isZh
            ? '导入完成：新增 ${payload.items.length} 条，当前周 $currentWeekCount 条。'
            : 'Import finished: ${payload.items.length} items, $currentWeekCount in current week.';
      });
      _showMessage(
        isZh
            ? '导入完成：新增 ${payload.items.length} 条课程事项，课程表「$tableName」。'
            : 'Imported ${payload.items.length} items to "$tableName".',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (error is WhuSessionInvalidException) {
        await ref.read(whuAuthProvider.notifier).logout();
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
    final picked = await AppDateTimePickers.pickDate(
      context,
      initialDate: _weekOneMonday ?? DateTime.now(),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _weekOneMonday = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _openLoginPage() async {
    await context.push(AppRoutePaths.settingsWhuAuthLogin);
    if (!mounted) {
      return;
    }
    if (ref.read(whuAuthProvider).isAuthenticated) {
      _showMessage(
        _isChinese(context) ? '已获取教务会话，可开始导入。' : 'Session acquired. Ready to import.',
      );
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

// ── Reusable editor-style components ──

class _EditorSection extends StatelessWidget {
  const _EditorSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1 && children[i] is! _DividerLine)
              _DividerLine(),
          ],
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.value,
    this.leadingIcon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? leadingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: _editorRowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  AppIcons.drillIn,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else
              const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  const _RoundedTextField({
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _editorRowHeight,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
