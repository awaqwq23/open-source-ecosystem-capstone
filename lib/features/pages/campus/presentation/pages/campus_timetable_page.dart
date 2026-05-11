import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

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
    if (context.mounted) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('登录成功')),
        );
      }
    }
  }
}

class _TimetableListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(courseTimetableRepositoryProvider);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: SettingsFlatSection(
        title: isZh ? '课程表列表' : 'Timetables',
        children: store.timetables.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    isZh ? '还没有课程表，点右上角 + 从武大教务系统导入。' : 'No timetable yet. Tap + to import from WHU.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ]
            : [
                for (final timetable in store.timetables)
                  _TimetableListTile(timetable: timetable),
              ],
      ),
    );
  }
}

class _TimetableListTile extends ConsumerWidget {
  const _TimetableListTile({required this.timetable});

  final CourseTimetable timetable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(courseTimetableRepositoryProvider);
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    final sourceText = switch (timetable.source) {
      CourseTimetableSource.whuJw => isZh ? '来源：武大教务' : 'Source: WHU',
      CourseTimetableSource.wakeup => isZh ? '来源：Wakeup' : 'Source: Wakeup',
      CourseTimetableSource.merged => isZh ? '来源：合并' : 'Source: Merged',
      CourseTimetableSource.manual => isZh ? '来源：手动' : 'Source: Manual',
    };
    final subtitle = timetable.termLabel.trim().isEmpty
        ? sourceText
        : '$sourceText · ${timetable.termLabel}';

    return SettingsFlatTile(
      title: timetable.name,
      subtitle: subtitle,
      leading: Icon(
        store.activeTimetableId == timetable.id
            ? AppIcons.selected
            : AppIcons.itemTypeCourse,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ui.IconButton.ghost(
            icon: const Icon(AppIcons.selected),
            onPressed: store.activeTimetableId == timetable.id
                ? null
                : () => ref
                    .read(courseTimetableRepositoryProvider.notifier)
                    .setActiveTimetable(timetable.id),
          ),
          ui.IconButton.ghost(
            icon: const Icon(AppIcons.delete),
            onPressed: () => _deleteTimetable(context, ref, timetable.id),
          ),
        ],
      ),
    );
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
