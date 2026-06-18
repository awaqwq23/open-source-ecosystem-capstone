import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/motion/app_motion_widgets.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/viewmodels/all_school_timetable_view_model.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/widgets/timetable_list_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AllSchoolTimetablePage extends ConsumerStatefulWidget {
  const AllSchoolTimetablePage({super.key});

  @override
  ConsumerState<AllSchoolTimetablePage> createState() =>
      _AllSchoolTimetablePageState();
}

class _AllSchoolTimetablePageState
    extends ConsumerState<AllSchoolTimetablePage> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(allSchoolTimetableViewModelProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onKeywordChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) {
        return;
      }
      ref.read(allSchoolTimetableViewModelProvider.notifier).setKeyword(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allSchoolTimetableViewModelProvider);
    final notifier = ref.read(allSchoolTimetableViewModelProvider.notifier);
    final theme = Theme.of(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('全校课表'),
        ),
      ],
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _TermStatus(state: state),
          const SizedBox(height: 12),
          _QueryModeControl(
            mode: state.query.mode,
            onChanged: notifier.setMode,
          ),
          const SizedBox(height: 12),
          ui.TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _onKeywordChanged,
            onSubmitted: notifier.setKeyword,
            hintText: '搜课程、老师、课程号、教室',
            features: [
              const ui.InputLeadingFeature(Icon(Icons.search, size: 16)),
              if (state.query.keyword.isNotEmpty)
                ui.InputTrailingFeature(
                  ui.IconButton.ghost(
                    onPressed: () {
                      _searchController.clear();
                      notifier.clearKeyword();
                    },
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _FilterStrip(state: state, notifier: notifier),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  state.isLoading
                      ? '正在查询'
                      : '${state.courseHeads.length} 门课 · 相关度优先',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (state.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: ui.CircularProgressIndicator(size: 16),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.errorMessage != null)
            _StatusCard(text: state.errorMessage!)
          else if (!state.hasLoaded ||
              state.isLoading && state.courseHeads.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: ui.CircularProgressIndicator()),
            )
          else if (state.courseHeads.isEmpty)
            _StatusCard(
              text: state.terms.isEmpty ? '暂无全校课表数据，等待更新' : '没有找到符合条件的课程',
            )
          else
            ...state.courseHeads.map(
              (head) => _CourseHeadTile(
                head: head,
                onTap: () => context.openSecondary(
                  AppRoutePaths.campusAllSchoolTimetableHead,
                  extra: CourseHeadPageArgs(head.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QueryModeControl extends StatelessWidget {
  const _QueryModeControl({required this.mode, required this.onChanged});

  final AllSchoolTimetableQueryMode mode;
  final ValueChanged<AllSchoolTimetableQueryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return ui.ButtonGroup.horizontal(
      expands: true,
      children: [
        ui.SelectedButton(
          value: mode == AllSchoolTimetableQueryMode.lightweight,
          onChanged: (_) => onChanged(AllSchoolTimetableQueryMode.lightweight),
          child: const Text('轻量'),
        ),
        ui.SelectedButton(
          value: mode == AllSchoolTimetableQueryMode.professional,
          onChanged: (_) => onChanged(AllSchoolTimetableQueryMode.professional),
          child: const Text('专业'),
        ),
      ],
    );
  }
}

class _TermStatus extends StatelessWidget {
  const _TermStatus({required this.state});

  final AllSchoolTimetableState state;

  @override
  Widget build(BuildContext context) {
    final term = state.selectedTerm;
    final colors = Theme.of(context).colorScheme;
    final text = term == null
        ? '暂无本地全校课表数据'
        : '${term.schoolYear} 第${term.term}学期 · ${term.rowCount} 条教学班';
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({required this.state, required this.notifier});

  final AllSchoolTimetableState state;
  final AllSchoolTimetableViewModel notifier;

  @override
  Widget build(BuildContext context) {
    final query = state.query;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: state.selectedTerm?.termKey ?? '学期',
            icon: Icons.calendar_month,
            onTap: () => _showTermPicker(context),
          ),
          if (query.mode == AllSchoolTimetableQueryMode.lightweight) ...[
            const _FilterChip(label: '本学期', icon: Icons.auto_awesome),
            const _FilterChip(label: '时间', icon: Icons.schedule),
            const _FilterChip(label: '地点', icon: Icons.place),
          ] else ...[
            _FilterChip(
              label: '筛选',
              icon: Icons.tune,
              active: query.hasProfessionalFilters,
              onTap: () => _showProfessionalFilters(context),
            ),
            if (query.openCollege.isNotEmpty)
              _FilterChip(label: query.openCollege),
            if (query.grade.isNotEmpty) _FilterChip(label: '${query.grade}级'),
            if (query.major.isNotEmpty) _FilterChip(label: query.major),
            if (query.weekday != null)
              _FilterChip(label: _weekdayLabel(query.weekday!)),
            if (query.building.isNotEmpty) _FilterChip(label: query.building),
          ],
        ],
      ),
    );
  }

  Future<void> _showTermPicker(BuildContext context) {
    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) => AppSheetEntrance(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择学期',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              for (final term in state.terms)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ui.CardButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () {
                      notifier.setTerm(term.termKey);
                      ui.closeSheet(sheetContext);
                    },
                    trailing: state.query.termKey == term.termKey
                        ? const Icon(Icons.check)
                        : null,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${term.schoolYear} 第${term.term}学期'),
                          const SizedBox(height: 2),
                          Text(
                            '${term.rowCount} 条教学班',
                            style: Theme.of(sheetContext).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    sheetContext,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showProfessionalFilters(BuildContext context) {
    final openCollege = TextEditingController(text: state.query.openCollege);
    final grade = TextEditingController(text: state.query.grade);
    final major = TextEditingController(text: state.query.major);
    final building = TextEditingController(text: state.query.building);
    var weekday = state.query.weekday;
    return ui
        .openSheet<void>(
          context: context,
          position: ui.OverlayPosition.bottom,
          builder: (sheetContext) => StatefulBuilder(
            builder: (sheetContext, setSheetState) => AppSheetEntrance(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '专业筛选',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ui.TextField(
                      controller: openCollege,
                      placeholder: const Text('开课学院'),
                    ),
                    const SizedBox(height: 8),
                    ui.TextField(
                      controller: grade,
                      placeholder: const Text('年级'),
                    ),
                    const SizedBox(height: 8),
                    ui.TextField(
                      controller: major,
                      placeholder: const Text('专业'),
                    ),
                    const SizedBox(height: 8),
                    ui.TextField(
                      controller: building,
                      placeholder: const Text('教学楼'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < 7; i++)
                          ui.SelectedButton(
                            value: weekday == i,
                            onChanged: (selected) {
                              setSheetState(
                                () => weekday = selected ? i : null,
                              );
                            },
                            child: Text(_weekdayLabel(i)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ui.TextButton(
                          onPressed: () {
                            notifier.clearProfessionalFilters();
                            ui.closeSheet(sheetContext);
                          },
                          child: const Text('清空'),
                        ),
                        const Spacer(),
                        ui.PrimaryButton(
                          onPressed: () {
                            notifier.applyProfessionalFilters(
                              openCollege: openCollege.text.trim(),
                              grade: grade.text.trim(),
                              major: major.text.trim(),
                              building: building.text.trim(),
                              weekday: weekday,
                            );
                            ui.closeSheet(sheetContext);
                          },
                          child: const Text('查看结果'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .whenComplete(() {
          openCollege.dispose();
          grade.dispose();
          major.dispose();
          building.dispose();
        });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.onTap,
    this.icon,
    this.active = false,
  });

  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ui.Chip(
        leading: icon == null ? null : Icon(icon, size: 16),
        style: active ? const ui.ButtonStyle.primary() : null,
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

class _CourseHeadTile extends StatelessWidget {
  const _CourseHeadTile({required this.head, required this.onTap});

  final SchoolCourseHead head;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final credits = head.credits == null ? '' : '${head.credits} 学分';
    return TimetableListButton(
      title: head.courseName,
      meta:
          '${head.courseNo} · ${head.openCollege} · ${head.teachingClassCount} 个教学班',
      detail: [
        if (head.teacherSummary.isNotEmpty) head.teacherSummary,
        if (head.weekdaySummary.isNotEmpty) head.weekdaySummary,
      ].join(' · '),
      trailingLabel: credits,
      onPressed: onTap,
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

String _weekdayLabel(int weekday) {
  return const ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][weekday];
}

class CourseHeadPageArgs {
  const CourseHeadPageArgs(this.courseHeadId);

  final String courseHeadId;
}

class TeachingClassDetailPageArgs {
  const TeachingClassDetailPageArgs(this.teachingClassId);

  final String teachingClassId;
}
