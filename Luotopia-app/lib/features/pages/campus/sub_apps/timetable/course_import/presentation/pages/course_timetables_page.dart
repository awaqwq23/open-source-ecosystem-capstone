import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseTimetablesPage extends ConsumerWidget {
  const CourseTimetablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(courseTimetableRepositoryProvider);
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
          title: Text(isZh ? '课程表与导入' : 'Course Tables & Import'),
          trailing: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.add),
              onPressed: () => _createEmptyTimetable(context, ref),
            ),
          ],
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SectionTitle(text: isZh ? '导入来源' : 'Import Sources'),
          ListTile(
            leading: const Icon(AppIcons.web),
            title: Text(isZh ? '武汉大学教务系统' : 'WHU Academic System'),
            subtitle: Text(isZh ? '通过内嵌网页登录并导入课程' : 'Import courses via embedded web login'),
            trailing: const Icon(AppIcons.drillIn),
            onTap: () => context.push(AppRoutePaths.settingsCourseImportWhu),
          ),
          ListTile(
            leading: const Icon(AppIcons.import),
            title: Text(isZh ? 'Wakeup 分享口令/链接' : 'Wakeup Share Link/Code'),
            subtitle: Text(isZh ? '从分享文本导入课程表' : 'Import timetable from shared text'),
            trailing: const Icon(AppIcons.drillIn),
            onTap: () => context.push(AppRoutePaths.settingsCourseImportWakeup),
          ),
          const SizedBox(height: 12),
          _SectionTitle(text: isZh ? '课程表列表' : 'Timetables'),
          if (store.timetables.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                isZh ? '还没有课程表，先从上方导入或手动创建。' : 'No timetable yet. Import or create one first.',
              ),
            )
          else
            for (final timetable in store.timetables)
              ListTile(
                leading: Icon(
                  store.isSelected(timetable.id)
                      ? AppIcons.selected
                      : AppIcons.itemTypeCourse,
                ),
                title: Text(timetable.name),
                subtitle: Text(_sourceLabel(context, timetable.source, timetable.termLabel)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ui.IconButton.ghost(
                      icon: const Icon(AppIcons.selected),
                      onPressed: store.isSelected(timetable.id)
                          ? null
                          : () => ref
                              .read(courseTimetableRepositoryProvider.notifier)
                              .setSelectedTimetables({timetable.id}),
                    ),
                    ui.IconButton.ghost(
                      icon: const Icon(AppIcons.delete),
                      onPressed: () => _deleteTimetable(context, ref, timetable.id),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  String _sourceLabel(BuildContext context, CourseTimetableSource source, String termLabel) {
    final isZh = _isChinese(context);
    final sourceText = switch (source) {
      CourseTimetableSource.whuJw => isZh ? '来源：武大教务' : 'Source: WHU',
      CourseTimetableSource.wakeup => isZh ? '来源：Wakeup' : 'Source: Wakeup',
      CourseTimetableSource.merged => isZh ? '来源：合并' : 'Source: Merged',
      CourseTimetableSource.manual => isZh ? '来源：手动' : 'Source: Manual',
    };
    if (termLabel.trim().isEmpty) {
      return sourceText;
    }
    return '$sourceText · $termLabel';
  }

  Future<void> _createEmptyTimetable(BuildContext context, WidgetRef ref) async {
    final isZh = _isChinese(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isZh ? '新建课程表' : 'Create timetable'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: isZh ? '输入课程表名称' : 'Enter timetable name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(isZh ? '取消' : 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(isZh ? '创建' : 'Create'),
            ),
          ],
        );
      },
    );
    if (result == null) {
      return;
    }
    await ref.read(courseTimetableRepositoryProvider.notifier).createTimetable(
          name: result,
          source: CourseTimetableSource.manual,
        );
  }

  Future<void> _deleteTimetable(BuildContext context, WidgetRef ref, String timetableId) async {
    final isZh = _isChinese(context);
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
        ) ??
        false;
    if (!shouldDelete) {
      return;
    }
    await ref.read(courseTimetableRepositoryProvider.notifier).deleteTimetable(timetableId);
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
