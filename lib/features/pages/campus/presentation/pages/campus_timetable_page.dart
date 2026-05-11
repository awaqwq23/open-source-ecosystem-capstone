import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/presentation/widgets/app_date_time_pickers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CampusTimetablePage extends ConsumerWidget {
  const CampusTimetablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(settingsViewModelProvider);
    final settings = state.homeSettings;
    final store = ref.watch(courseTimetableRepositoryProvider);
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
          trailing: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.add),
              onPressed: () => _createEmptyTimetable(context, ref),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          children: [
            // ── 课程导入 ──
            SettingsFlatSection(
              title: isZh ? '课程导入' : 'Course Import',
              children: [
                SettingsFlatTile(
                  title: isZh ? '武汉大学教务系统' : 'WHU Academic System',
                  subtitle: isZh ? '通过内嵌网页登录并导入课程' : 'Import via embedded web login',
                  leading: const Icon(AppIcons.web),
                  onTap: () => context.push(AppRoutePaths.settingsCourseImportWhu),
                ),
                SettingsFlatTile(
                  title: isZh ? 'Wakeup 分享口令/链接' : 'Wakeup Share Link/Code',
                  subtitle: isZh ? '从分享文本导入课程表' : 'Import from shared text',
                  leading: const Icon(AppIcons.import),
                  onTap: () => context.push(AppRoutePaths.settingsCourseImportWakeup),
                ),
              ],
            ),

            // ── 课程表列表 ──
            SettingsFlatSection(
              title: isZh ? '课程表列表' : 'Timetables',
              children: [
                if (store.timetables.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      isZh ? '还没有课程表，先从上方导入或手动创建。' : 'No timetable yet. Import or create one first.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final timetable in store.timetables)
                    _TimetableListTile(timetable: timetable),
              ],
            ),

            // ── 时间方格设置 ──
            SettingsFlatSection(
              title: isZh ? '时间方格设置' : 'Time Grid Settings',
              children: [
                SettingsFlatTile(
                  title: l10n.settingsHomeDayStart,
                  subtitle: MaterialLocalizations.of(context).formatTimeOfDay(
                    settings.dayStartTime,
                  ),
                  leading: const Icon(AppIcons.clock),
                  onTap: () => _pickHomeStartTime(context, ref, settings),
                ),
                _StepperTile(
                  title: l10n.settingsHomeBlockDuration,
                  value: l10n.settingsMinutesValue(settings.blockDurationMinutes),
                  onDecrease: settings.blockDurationMinutes > 15
                      ? () => _save(ref, settings.copyWith(
                            blockDurationMinutes: settings.blockDurationMinutes - 15,
                          ))
                      : null,
                  onIncrease: () => _save(ref, settings.copyWith(
                        blockDurationMinutes: settings.blockDurationMinutes + 15,
                      )),
                ),
                _StepperTile(
                  title: l10n.settingsHomeBlockGap,
                  value: l10n.settingsMinutesValue(settings.blockGapMinutes),
                  onDecrease: settings.blockGapMinutes > 0
                      ? () => _save(ref, settings.copyWith(
                            blockGapMinutes: settings.blockGapMinutes - 5,
                          ))
                      : null,
                  onIncrease: () => _save(ref, settings.copyWith(
                        blockGapMinutes: settings.blockGapMinutes + 5,
                      )),
                ),
                _StepperTile(
                  title: l10n.settingsHomeBlockCount,
                  value: '${settings.blockCount}',
                  onDecrease: settings.blockCount > 1
                      ? () => _save(ref, settings.copyWith(
                            blockCount: settings.blockCount - 1,
                          ))
                      : null,
                  onIncrease: () => _save(ref, settings.copyWith(
                        blockCount: settings.blockCount + 1,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickHomeStartTime(
    BuildContext context,
    WidgetRef ref,
    HomeSettings settings,
  ) async {
    final result = await AppDateTimePickers.pickTime(
      context,
      initialTime: settings.dayStartTime,
    );
    if (result == null) return;
    await _save(ref, settings.copyWith(dayStartTime: result));
  }

  Future<void> _save(WidgetRef ref, HomeSettings settings) {
    return ref.read(settingsViewModelProvider.notifier).saveHomeSettings(settings);
  }

  Future<void> _createEmptyTimetable(BuildContext context, WidgetRef ref) async {
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
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
    if (result == null) return;
    await ref.read(courseTimetableRepositoryProvider.notifier).createTimetable(
      name: result,
      source: CourseTimetableSource.manual,
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

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.title,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String title;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return SettingsFlatTile(
      title: title,
      subtitle: value,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ui.IconButton.ghost(
            icon: const Icon(Icons.remove),
            onPressed: onDecrease,
          ),
          ui.IconButton.ghost(
            icon: const Icon(Icons.add),
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}
