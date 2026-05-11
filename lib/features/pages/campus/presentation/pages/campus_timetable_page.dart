import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

const double _rowHeight = 72;
const double _pageHorizontalPad = 20;

class CampusTimetablePage extends ConsumerWidget {
  const CampusTimetablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whuAuth = ref.watch(whuAuthProvider);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: Text(isZh ? '课程表' : 'Timetable'),
          trailing: whuAuth.isAuthenticated
              ? <Widget>[
                  ui.IconButton.ghost(
                    icon: const Icon(AppIcons.add),
                    onPressed: () => context.push(AppRoutePaths.settingsCourseImportWhu),
                  ),
                ]
              : <Widget>[],
        ),
      ],
      child: whuAuth.isAuthenticated
          ? _TimetableListView()
          : _UnauthenticatedView(),
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 48, color: colors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            isZh ? '请先登录武大教务账户' : 'Please login to WHU Academic System',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ui.OutlineButton(
            onPressed: () => _login(context),
            child: Text(isZh ? '去登录' : 'Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    await context.push(AppRoutePaths.settingsWhuAuthLogin);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('登录成功')),
      );
    }
  }
}

class _TimetableListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(courseTimetableRepositoryProvider);
    final agendaItems = ref.watch(agendaItemRepositoryProvider);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    final overlapMap = _buildOverlapMap(store.timetables, agendaItems);
    final selectedSet = store.selectedTimetableIds;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(_pageHorizontalPad, 8, _pageHorizontalPad, 24),
      child: Column(
        children: [
          if (store.timetables.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Center(
                child: Text(
                  isZh ? '还没有课程表，点右上角 + 从武大教务系统导入。' : 'No timetable yet. Tap + to import from WHU.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (final timetable in store.timetables)
              _TimetableCheckTile(
                timetable: timetable,
                isSelected: selectedSet.contains(timetable.id),
                conflictIds: overlapMap[timetable.id] ?? {},
                selectedSet: selectedSet,
                onToggle: (checked) {
                  final next = Set<String>.from(selectedSet);
                  if (checked) {
                    next.add(timetable.id);
                  } else {
                    next.remove(timetable.id);
                  }
                  ref.read(courseTimetableRepositoryProvider.notifier).setSelectedTimetables(next);
                },
                onDelete: () => _deleteTimetable(context, ref, timetable.id),
              ),
        ],
      ),
    );
  }

  /// Build a map: timetableId -> set of other timetableIds that overlap with it.
  Map<String, Set<String>> _buildOverlapMap(
    List<CourseTimetable> timetables,
    List<dynamic> agendaItems,
  ) {
    // Compute the global date range per timetable
    final ranges = <String, DateTimeRange>{};
    for (final t in timetables) {
      DateTime? first, last;
      for (final item in agendaItems) {
        if (item.type == ItemType.course && item.courseDetails.timetableId == t.id) {
          final s = DateUtils.dateOnly(item.startAt);
          final e = DateUtils.dateOnly(item.endAt);
          if (first == null || s.isBefore(first)) first = s;
          if (last == null || e.isAfter(last)) last = e;
        }
      }
      if (first != null && last != null) {
        ranges[t.id] = DateTimeRange(start: first, end: last);
      }
    }

    final conflict = <String, Set<String>>{};
    for (final t in timetables) {
      conflict[t.id] = {};
    }
    final ids = ranges.keys.toList();
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final a = ranges[ids[i]]!;
        final b = ranges[ids[j]]!;
        if (a.start.isBefore(b.end) && b.start.isBefore(a.end)) {
          conflict[ids[i]]!.add(ids[j]);
          conflict[ids[j]]!.add(ids[i]);
        }
      }
    }
    return conflict;
  }

  Future<void> _deleteTimetable(BuildContext context, WidgetRef ref, String timetableId) async {
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isZh ? '删除课程表' : 'Delete timetable'),
          content: Text(
            isZh
                ? '会同时删除该课程表下的所有课程事项。'
                : 'All course items in this timetable will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(isZh ? '取消' : 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(isZh ? '删除' : 'Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) return;

    final agendaRepo = ref.read(agendaItemRepositoryProvider.notifier);
    final courseItemIds = [
      for (final item in ref.read(agendaItemRepositoryProvider))
        if (item.type == ItemType.course && item.courseDetails.timetableId == timetableId)
          item.id,
    ];
    for (final itemId in courseItemIds) {
      await agendaRepo.deleteItem(itemId);
    }
    await ref.read(courseTimetableRepositoryProvider.notifier).deleteTimetable(timetableId);
  }
}

class _TimetableCheckTile extends StatelessWidget {
  const _TimetableCheckTile({
    required this.timetable,
    required this.isSelected,
    required this.conflictIds,
    required this.selectedSet,
    required this.onToggle,
    required this.onDelete,
  });

  final CourseTimetable timetable;
  final bool isSelected;
  final Set<String> conflictIds;
  final Set<String> selectedSet;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    final hasActiveConflict = isSelected
        ? false
        : conflictIds.any((id) => selectedSet.contains(id));

    final canToggle = !hasActiveConflict;

    final subtitle = timetable.termLabel.trim().isEmpty
        ? null
        : timetable.termLabel;

    return SizedBox(
      height: _rowHeight,
      child: InkWell(
        onTap: canToggle ? () => onToggle(!isSelected) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (v) {
                if (v != null && canToggle) onToggle(v);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timetable.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (hasActiveConflict)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            IconButton(
              icon: const Icon(AppIcons.delete, size: 20),
              tooltip: isZh ? '删除' : 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
