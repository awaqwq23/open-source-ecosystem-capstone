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

class CampusTimetablePage extends ConsumerStatefulWidget {
  const CampusTimetablePage({super.key});

  @override
  ConsumerState<CampusTimetablePage> createState() => _CampusTimetablePageState();
}

class _CampusTimetablePageState extends ConsumerState<CampusTimetablePage> {
  Set<String> _pendingSelectedIds = {};
  final Set<String> _pendingDeleteIds = {};
  List<String> _initialTimetableIds = const [];
  bool _didInit = false;

  @override
  Widget build(BuildContext context) {
    if (!_didInit) {
      _didInit = true;
      final store = ref.read(courseTimetableRepositoryProvider);
      _pendingSelectedIds = Set<String>.from(store.selectedTimetableIds);
      _initialTimetableIds = store.timetables.map((t) => t.id).toList();
    }

    // Cancel: revert all pending changes and pop
    void cancel() {
      final store = ref.read(courseTimetableRepositoryProvider);
      final notifier = ref.read(courseTimetableRepositoryProvider.notifier);
      // Remove timetables added by import since page opened
      for (final t in store.timetables) {
        if (!_initialTimetableIds.contains(t.id)) {
          notifier.deleteTimetable(t.id);
        }
      }
      // Restore original selection
      notifier.setSelectedTimetables(_initialTimetableIds.toSet());
      Navigator.of(context).maybePop();
    }

    void confirm() async {
      final notifier = ref.read(courseTimetableRepositoryProvider.notifier);
      // Apply pending deletes
      for (final id in _pendingDeleteIds) {
        final agendaRepo = ref.read(agendaItemRepositoryProvider.notifier);
        final courseItemIds = [
          for (final item in ref.read(agendaItemRepositoryProvider))
            if (item.type == ItemType.course && item.courseDetails.timetableId == id)
              item.id,
        ];
        for (final itemId in courseItemIds) {
          await agendaRepo.deleteItem(itemId);
        }
        await notifier.deleteTimetable(id);
      }
      // Apply selection
      await notifier.setSelectedTimetables(_pendingSelectedIds);
      if (!context.mounted) return;
      Navigator.of(context).maybePop();
    }

    final whuAuth = ref.watch(whuAuthProvider);
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: cancel,
            ),
          ],
          title: Text(isZh ? '课程表' : 'Timetable'),
          trailing: whuAuth.isAuthenticated
              ? <Widget>[
                  ui.IconButton.ghost(
                    icon: const Icon(Icons.check),
                    onPressed: confirm,
                  ),
                ]
              : <Widget>[],
        ),
      ],
      child: whuAuth.isAuthenticated
          ? Stack(
              children: [
                _TimetableListView(
                  pendingSelectedIds: _pendingSelectedIds,
                  pendingDeleteIds: _pendingDeleteIds,
                  onToggle: (id, checked) {
                    setState(() {
                      if (checked) {
                        _pendingSelectedIds.add(id);
                        _pendingDeleteIds.remove(id);
                      } else {
                        _pendingSelectedIds.remove(id);
                      }
                    });
                  },
                  onDelete: (id) {
                    setState(() {
                      _pendingDeleteIds.add(id);
                      _pendingSelectedIds.remove(id);
                    });
                  },
                ),
                Positioned(
                  right: 20,
                  bottom: 24,
                  child: FloatingActionButton(
                    heroTag: 'timetable-fab',
                    onPressed: () => context.push(AppRoutePaths.settingsCourseImportWhu),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: const Icon(AppIcons.add),
                  ),
                ),
              ],
            )
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
  const _TimetableListView({
    required this.pendingSelectedIds,
    required this.pendingDeleteIds,
    required this.onToggle,
    required this.onDelete,
  });

  final Set<String> pendingSelectedIds;
  final Set<String> pendingDeleteIds;
  final void Function(String id, bool checked) onToggle;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(courseTimetableRepositoryProvider);
    final agendaItems = ref.watch(agendaItemRepositoryProvider);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    final visibleTimetables = store.timetables
        .where((t) => !pendingDeleteIds.contains(t.id))
        .toList();
    final overlapMap = _buildOverlapMap(visibleTimetables, agendaItems);
    final selectedSet = pendingSelectedIds;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: Column(
        children: [
          if (visibleTimetables.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Center(
                child: Text(
                  isZh ? '还没有课程表，点右下角 + 从武大教务系统导入。' : 'No timetable yet. Tap + to import from WHU.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (final timetable in visibleTimetables)
              _TimetableCheckTile(
                timetable: timetable,
                isSelected: selectedSet.contains(timetable.id),
                conflictIds: overlapMap[timetable.id] ?? {},
                selectedSet: selectedSet,
                onToggle: (checked) => onToggle(timetable.id, checked),
                onDelete: () => onDelete(timetable.id),
              ),
        ],
      ),
    );
  }

  Map<String, Set<String>> _buildOverlapMap(
    List<CourseTimetable> timetables,
    List<dynamic> agendaItems,
  ) {
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

    final timeStr = '${timetable.createdAt.year}-${timetable.createdAt.month.toString().padLeft(2, '0')}-${timetable.createdAt.day.toString().padLeft(2, '0')}';
    final termPart = timetable.termLabel.trim();
    final subtitle = termPart.isEmpty
        ? (isZh ? '导入于 $timeStr' : 'Imported $timeStr')
        : '$termPart · $timeStr';

    return SizedBox(
      height: _rowHeight,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: canToggle ? () => onToggle(!isSelected) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
        ),
      ),
    );
  }
}
