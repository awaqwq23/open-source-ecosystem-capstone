import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/data/drift_all_school_timetable_repository.dart';
import 'package:luotopia/features/pages/campus/sub_apps/timetable/course_import/data/whu_course_import_service.dart';
import 'package:luotopia/features/whu_auth/whu_auth.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/presentation/widgets/app_date_time_pickers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

const double _rowHeight = 56;
const double _horizontalPad = 16;

class _TermOption {
  const _TermOption({required this.year, required this.semester});

  final int year;
  final int semester;

  String label(bool isZh) {
    final next = year + 1;
    if (isZh) {
      return '$year-$next 学年第$semester学期';
    }
    final sem = switch (semester) {
      1 => 'Fall',
      2 => 'Spring',
      _ => 'Summer',
    };
    return '$year-$next $sem';
  }

  String termLabel() => '$year-${year + 1}-$semester';

  @override
  bool operator ==(Object other) =>
      other is _TermOption && other.year == year && other.semester == semester;

  @override
  int get hashCode => Object.hash(year, semester);
}

List<_TermOption> _availableTerms() {
  final now = DateTime.now();
  final current = _inferCurrentTerm(now);
  final options = <_TermOption>{};
  for (
    var y = current.academicYearStart - 2;
    y <= current.academicYearStart + 1;
    y++
  ) {
    for (var s = 1; s <= 3; s++) {
      options.add(_TermOption(year: y, semester: s));
    }
  }
  final sorted = options.toList()
    ..sort((a, b) {
      final c = b.year.compareTo(a.year);
      return c != 0 ? c : b.semester.compareTo(a.semester);
    });
  return sorted;
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

class CourseImportWhuPage extends ConsumerStatefulWidget {
  const CourseImportWhuPage({super.key});

  @override
  ConsumerState<CourseImportWhuPage> createState() =>
      _CourseImportWhuPageState();
}

class _CourseImportWhuPageState extends ConsumerState<CourseImportWhuPage> {
  final _nameController = TextEditingController();
  DateTime? _weekOneMonday;
  bool _submitting = false;
  String? _statusText;
  bool _didInitLocale = false;

  late final List<_TermOption> _allTerms;
  _TermOption _selectedTerm;

  _CourseImportWhuPageState()
    : _selectedTerm = _TermOption(
        year: 0,
        semester: 0,
      ); // dummy, set in initState

  @override
  void initState() {
    super.initState();
    final inferred = _inferCurrentTerm(DateTime.now());
    _allTerms = _availableTerms();
    _selectedTerm = _allTerms.firstWhere(
      (t) =>
          t.year == inferred.academicYearStart &&
          t.semester == inferred.semester,
      orElse: () => _allTerms.first,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitLocale) {
      _didInitLocale = true;
      _nameController.text = _selectedTerm.label(_isChinese(context));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
  }

  @override
  Widget build(BuildContext context) {
    final whuAuth = ref.watch(whuAuthProvider);
    final theme = Theme.of(context);
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
          title: Text(isZh ? '导入课程表' : 'Import Schedule'),
        ),
      ],
      child: whuAuth.isAuthenticated
          ? SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 课程表名称 ──
                  _RoundedTextField(
                    controller: _nameController,
                    hintText: isZh ? '课程表名称' : 'Timetable name',
                  ),
                  const Gap(12),

                  // ── 导入学期选择 ──
                  _SemesterPicker(
                    allTerms: _allTerms,
                    selected: _selectedTerm,
                    onChange: (term) {
                      setState(() {
                        _selectedTerm = term;
                        _nameController.text = term.label(isZh);
                      });
                    },
                  ),
                  const Gap(16),

                  // ── 第1周周一 ──
                  _FlatActionRow(
                    label: isZh ? '第一周周一' : 'Week-1 Monday',
                    value: _weekOneMonday == null
                        ? (isZh ? '点击选择' : 'Tap to select')
                        : '${_weekOneMonday!.year}-${_weekOneMonday!.month.toString().padLeft(2, '0')}-${_weekOneMonday!.day.toString().padLeft(2, '0')}',
                    onTap: _submitting
                        ? null
                        : () => _pickWeekOneMonday(context),
                  ),
                  const Gap(24),

                  // ── 开始导入 ──
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
            )
          : _ImportLoginRequiredView(
              isZh: isZh,
              onLogin: () => context.openSecondary(AppRoutePaths.whuAccount),
            ),
    );
  }

  String _formatNow() {
    final now = DateTime.now();
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${now.year}-${pad(now.month)}-${pad(now.day)} ${pad(now.hour)}:${pad(now.minute)}';
  }

  Future<void> _submit() async {
    final isZh = _isChinese(context);
    if (_weekOneMonday == null) {
      _showMessage(isZh ? '请选择第1周周一日期。' : 'Please select Week-1 Monday.');
      return;
    }
    setState(() {
      _submitting = true;
      _statusText = isZh
          ? '正在校验并建立教务会话...'
          : 'Verifying and establishing education session...';
    });
    try {
      setState(() {
        _statusText = isZh ? '正在请求教务课表...' : 'Fetching timetable...';
      });
      final client = await ref
          .read(whuAuthGatewayProvider)
          .authorizeEducation();
      final WhuCourseImportPayload payload;
      try {
        final service = WhuCourseImportService(client: client);
        payload = await service.loadCourses(
          year: _selectedTerm.year,
          semester: _selectedTerm.semester,
          weekOneMonday: _weekOneMonday!,
        );
      } finally {
        client.close();
      }
      final baseName = _nameController.text.trim();
      final tableName = baseName.isEmpty
          ? '${_selectedTerm.label(isZh)} ${_formatNow()}'
          : '$baseName ${_formatNow()}';
      final termLabel = _selectedTerm.termLabel();
      setState(() {
        _statusText = isZh ? '正在关联统一课程实体...' : 'Linking course entities...';
      });
      final allSchoolRepo = ref.read(allSchoolTimetableRepositoryProvider);
      await allSchoolRepo.ensureLocalDataReady();
      final terms = await allSchoolRepo.loadTerms();
      final hasSnapshot = terms.any((term) => term.termKey == termLabel);
      final importItems = <ItemDraft>[];
      var matchedCourseCount = 0;
      var matchedOfferingCount = 0;
      var matchedOccurrenceCount = 0;
      if (hasSnapshot) {
        for (final entry in payload.entries) {
          final link = await allSchoolRepo.matchPersonalCourse(
            entry.matchQuery,
          );
          if (link.hasCourse) {
            matchedCourseCount++;
          }
          if (link.hasOffering) {
            matchedOfferingCount++;
          }
          if (link.hasOccurrence) {
            matchedOccurrenceCount++;
          }
          importItems.add(
            entry.draft.copyWith(
              courseDetails: entry.draft.courseDetails.copyWith(
                termCourseId: link.termCourseId,
                offeringId: link.offeringId,
                instructorCourseId: link.instructorCourseId,
                occurrenceId: link.occurrenceId,
              ),
            ),
          );
        }
      } else {
        importItems.addAll(payload.items);
      }
      await ref
          .read(courseTimetableRepositoryProvider.notifier)
          .importCourseTimetable(
            name: tableName,
            source: CourseTimetableSource.whuJw,
            termLabel: termLabel,
            items: importItems,
          );

      if (!mounted) {
        return;
      }
      final today = DateUtils.dateOnly(DateTime.now());
      final currentWeekStart = today.subtract(
        Duration(days: today.weekday - DateTime.monday),
      );
      final currentWeekEnd = currentWeekStart.add(const Duration(days: 7));
      final currentWeekCount = importItems.where((item) {
        final startAt = item.timelineStartAt;
        final endAt = item.timelineEndAt;
        if (startAt == null || endAt == null) {
          return false;
        }
        return endAt.isAfter(currentWeekStart) &&
            startAt.isBefore(currentWeekEnd);
      }).length;
      final linkSummary = hasSnapshot
          ? (isZh
                ? '统一课程关联：课程 $matchedCourseCount，教学班 $matchedOfferingCount，课次 $matchedOccurrenceCount。'
                : 'Linked entities: courses $matchedCourseCount, offerings $matchedOfferingCount, occurrences $matchedOccurrenceCount.')
          : (isZh
                ? '未找到 $termLabel 全校课表快照，本次仅导入个人课表。'
                : 'No all-school timetable snapshot for $termLabel; imported personal timetable only.');

      setState(() {
        _statusText = isZh
            ? '导入完成：新增 ${importItems.length} 条，当前周 $currentWeekCount 条。$linkSummary'
            : 'Import finished: ${importItems.length} items, $currentWeekCount in current week. $linkSummary';
      });
      _showMessage(
        isZh
            ? '导入完成：新增 ${importItems.length} 条课程事项，课程表「$tableName」。'
            : 'Imported ${importItems.length} items to "$tableName".',
      );
    } catch (error) {
      if (!mounted) {
        return;
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
}

class _ImportLoginRequiredView extends StatelessWidget {
  const _ImportLoginRequiredView({required this.isZh, required this.onLogin});

  final bool isZh;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              isZh ? '请先登录武大教务账户' : 'Please login to WHU Academic System',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ui.OutlineButton(
              onPressed: onLogin,
              child: Text(isZh ? '去登录' : 'Login'),
            ),
          ],
        ),
      ),
    );
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

// ── 学期选择器 ──

class _SemesterPicker extends StatelessWidget {
  const _SemesterPicker({
    required this.allTerms,
    required this.selected,
    required this.onChange,
  });

  final List<_TermOption> allTerms;
  final _TermOption selected;
  final ValueChanged<_TermOption> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    return SizedBox(
      height: _rowHeight,
      child: InkWell(
        onTap: () => _openSheet(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 4),
            Text(
              isZh ? '导入学期' : 'Semester',
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            Flexible(
              child: Text(
                selected.label(isZh),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              AppIcons.drillIn,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final years = <int>[];
    for (final t in allTerms) {
      if (!years.contains(t.year)) years.add(t.year);
    }
    final initialYearIndex = years.indexOf(selected.year);
    final initialSemIndex = selected.semester - 1;

    final yearCtrl = FixedExtentScrollController(
      initialItem: initialYearIndex.clamp(0, years.length - 1),
    );

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return _SemesterWheelSheet(
          years: years,
          allTerms: allTerms,
          initialYearIndex: initialYearIndex.clamp(0, years.length - 1),
          initialSemIndex: initialSemIndex.clamp(0, 2),
          yearCtrl: yearCtrl,
          onChange: onChange,
        );
      },
    );
  }
}

class _SemesterWheelSheet extends StatefulWidget {
  const _SemesterWheelSheet({
    required this.years,
    required this.allTerms,
    required this.initialYearIndex,
    required this.initialSemIndex,
    required this.yearCtrl,
    required this.onChange,
  });

  final List<int> years;
  final List<_TermOption> allTerms;
  final int initialYearIndex;
  final int initialSemIndex;
  final FixedExtentScrollController yearCtrl;
  final ValueChanged<_TermOption> onChange;

  @override
  State<_SemesterWheelSheet> createState() => _SemesterWheelSheetState();
}

class _SemesterWheelSheetState extends State<_SemesterWheelSheet> {
  late int _selectedYear;
  late int _selectedSem;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.years[widget.initialYearIndex];
    _selectedSem = _pickInitialSem();
  }

  int _pickInitialSem() {
    final avail = _availableSems;
    final idx = widget.initialSemIndex;
    return idx < avail.length ? avail[idx] : avail.last;
  }

  List<int> get _availableSems =>
      widget.allTerms
          .where((t) => t.year == _selectedYear)
          .map((t) => t.semester)
          .toList()
        ..sort();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final availSems = _availableSems;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isZh ? '选择学期' : 'Select Semester',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ui.TextButton(
                  onPressed: () {
                    final match = widget.allTerms.firstWhere(
                      (t) =>
                          t.year == _selectedYear && t.semester == _selectedSem,
                      orElse: () => widget.allTerms.first,
                    );
                    widget.onChange(match);
                    Navigator.of(context).pop();
                  },
                  child: Text(isZh ? '确定' : 'Done'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: widget.yearCtrl,
                    itemExtent: 44,
                    onSelectedItemChanged: (i) {
                      setState(() {
                        _selectedYear = widget.years[i];
                        if (!_availableSems.contains(_selectedSem)) {
                          _selectedSem = _availableSems.last;
                        }
                      });
                    },
                    children: [
                      for (final y in widget.years)
                        Center(
                          child: Text(
                            isZh ? '$y-${y + 1} 学年' : '$y-${y + 1}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    key: ValueKey('sem_$_selectedYear'),
                    itemExtent: 44,
                    onSelectedItemChanged: (i) {
                      setState(() => _selectedSem = availSems[i]);
                    },
                    children: [
                      for (final s in availSems)
                        Center(
                          child: Text(
                            isZh ? '第$s学期' : 'Sem $s',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

// ── 组件 ──

class _FlatActionRow extends StatelessWidget {
  const _FlatActionRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: _rowHeight,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 4),
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                    Icon(
                      AppIcons.drillIn,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  const _RoundedTextField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isCollapsed: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPad,
                  vertical: 16,
                ),
              ),
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
