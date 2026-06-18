import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/viewmodels/all_school_timetable_view_model.dart';
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
          SegmentedButton<AllSchoolTimetableQueryMode>(
            segments: const [
              ButtonSegment(
                value: AllSchoolTimetableQueryMode.lightweight,
                label: Text('轻量'),
              ),
              ButtonSegment(
                value: AllSchoolTimetableQueryMode.professional,
                label: Text('专业'),
              ),
            ],
            selected: {state.query.mode},
            onSelectionChanged: (values) => notifier.setMode(values.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _onKeywordChanged,
            onSubmitted: notifier.setKeyword,
            decoration: InputDecoration(
              hintText: '搜课程、老师、课程号、教室',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.query.keyword.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        notifier.clearKeyword();
                      },
                      icon: const Icon(Icons.close),
                    ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
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
                  child: CircularProgressIndicator(strokeWidth: 2),
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
              child: Center(child: CircularProgressIndicator()),
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
            _FilterChip(label: '本学期', icon: Icons.auto_awesome, onTap: () {}),
            _FilterChip(label: '时间', icon: Icons.schedule, onTap: () {}),
            _FilterChip(label: '地点', icon: Icons.place, onTap: () {}),
          ] else ...[
            _FilterChip(
              label: '筛选',
              icon: Icons.tune,
              active: query.hasProfessionalFilters,
              onTap: () => _showProfessionalFilters(context),
            ),
            if (query.openCollege.isNotEmpty)
              _FilterChip(label: query.openCollege, onTap: () {}),
            if (query.grade.isNotEmpty)
              _FilterChip(label: '${query.grade}级', onTap: () {}),
            if (query.major.isNotEmpty)
              _FilterChip(label: query.major, onTap: () {}),
            if (query.weekday != null)
              _FilterChip(label: _weekdayLabel(query.weekday!), onTap: () {}),
            if (query.building.isNotEmpty)
              _FilterChip(label: query.building, onTap: () {}),
          ],
        ],
      ),
    );
  }

  Future<void> _showTermPicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final term in state.terms)
              ListTile(
                title: Text('${term.schoolYear} 第${term.term}学期'),
                subtitle: Text('${term.rowCount} 条教学班'),
                trailing: state.query.termKey == term.termKey
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  notifier.setTerm(term.termKey);
                  Navigator.of(context).pop();
                },
              ),
          ],
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
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('专业筛选', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: openCollege,
                  decoration: const InputDecoration(
                    labelText: '开课学院',
                    isDense: true,
                  ),
                ),
                TextField(
                  controller: grade,
                  decoration: const InputDecoration(
                    labelText: '年级',
                    isDense: true,
                  ),
                ),
                TextField(
                  controller: major,
                  decoration: const InputDecoration(
                    labelText: '专业',
                    isDense: true,
                  ),
                ),
                TextField(
                  controller: building,
                  decoration: const InputDecoration(
                    labelText: '教学楼',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < 7; i++)
                      ChoiceChip(
                        label: Text(_weekdayLabel(i)),
                        selected: weekday == i,
                        onSelected: (selected) {
                          setSheetState(() => weekday = selected ? i : null);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        notifier.clearProfessionalFilters();
                        Navigator.of(context).pop();
                      },
                      child: const Text('清空'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        notifier.applyProfessionalFilters(
                          openCollege: openCollege.text.trim(),
                          grade: grade.text.trim(),
                          major: major.text.trim(),
                          building: building.text.trim(),
                          weekday: weekday,
                        );
                        Navigator.of(context).pop();
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
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.icon,
    this.active = false,
  });

  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: icon == null ? null : Icon(icon, size: 16),
        label: Text(label),
        onPressed: onTap,
        backgroundColor: active
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
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
    final theme = Theme.of(context);
    final credits = head.credits == null ? '' : '${head.credits} 学分';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            head.courseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (credits.isNotEmpty)
                          Text(
                            credits,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${head.courseNo} · ${head.openCollege} · ${head.teachingClassCount} 个教学班',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (head.teacherSummary.isNotEmpty) head.teacherSummary,
                        if (head.weekdaySummary.isNotEmpty) head.weekdaySummary,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
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
