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
import 'package:gap/gap.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

const double _editorRowHeight = 56;
const double _editorHorizontalPadding = 20;

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
          const Gap(16),
          Text(
            isZh ? '请先登录武大教务账户' : 'Please login to WHU Academic System',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Gap(16),
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
    if (context.mounted) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('登录成功')),
        );
      }
    }
  }
}

class _TimetableListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(courseTimetableRepositoryProvider);
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(_editorHorizontalPadding, 12, _editorHorizontalPadding, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              isZh ? '课程表列表' : 'Timetables',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: store.timetables.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Center(
                      child: Text(
                        isZh ? '还没有课程表，点右上角 + 从武大教务系统导入。' : 'No timetable yet. Tap + to import from WHU.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < store.timetables.length; i++) ...[
                        _TimetableRow(timetable: store.timetables[i]),
                        if (i != store.timetables.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimetableRow extends ConsumerWidget {
  const _TimetableRow({required this.timetable});

  final CourseTimetable timetable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(courseTimetableRepositoryProvider);
    final theme = Theme.of(context);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
    final isActive = store.activeTimetableId == timetable.id;

    final sourceText = switch (timetable.source) {
      CourseTimetableSource.whuJw => isZh ? '武大教务' : 'WHU',
      CourseTimetableSource.wakeup => isZh ? 'Wakeup' : 'Wakeup',
      CourseTimetableSource.merged => isZh ? '合并' : 'Merged',
      CourseTimetableSource.manual => isZh ? '手动' : 'Manual',
    };
    final subtitle = timetable.termLabel.trim().isEmpty
        ? sourceText
        : '$sourceText · ${timetable.termLabel}';

    return InkWell(
      onTap: () => _activate(context, ref),
      child: SizedBox(
        height: _editorRowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(
                width: 24,
                child: Icon(
                  isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Gap(12),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
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
            if (!isActive)
              IconButton(
                icon: Icon(Icons.check_circle_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
                tooltip: isZh ? '设为当前' : 'Set active',
                onPressed: () => _activate(context, ref),
              ),
            IconButton(
              icon: const Icon(AppIcons.delete, size: 20),
              tooltip: isZh ? '删除' : 'Delete',
              onPressed: () => _delete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _activate(BuildContext context, WidgetRef ref) {
    ref.read(courseTimetableRepositoryProvider.notifier).setActiveTimetable(timetable.id);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
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
        if (item.type == ItemType.course && item.courseDetails.timetableId == timetable.id)
          item.id,
    ];
    for (final itemId in courseItemIds) {
      await agendaRepo.deleteItem(itemId);
    }
    await ref.read(courseTimetableRepositoryProvider.notifier).deleteTimetable(timetable.id);
  }
}
