import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/list/presentation/viewmodels/list_header_view_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listHeaderViewModelProvider);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(_tabLabel(l10n, state.currentTab)),
          trailing: [
            ui.Tooltip(
              tooltip: (context) => Text(l10n.headerOpenListTabs),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.openListTabs),
                onPressed: () => _showTabSwitcher(context, ref),
              ),
            ),
            ui.Tooltip(
              tooltip: (context) => Text(l10n.headerOpenListSettings),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.moreActions),
                onPressed: () => _showSettingsMenu(context),
              ),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AppEntrance(
              child: ui.Card(
                child: AppSwitchingContent(
                  contentKey: state.currentTab,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              AppIcons.listFilled,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.listTitle,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  context.l10n.listDescription,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AppEntrance(
                        delay: AppMotion.fast,
                        offset: AppMotion.sectionOffset,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ui.PrimaryButton(
                              onPressed: () => _showTabSwitcher(context, ref),
                              child: Text(l10n.placeholderOpenMenu),
                            ),
                            ui.GhostButton(
                              onPressed: () => _showSettingsMenu(context),
                              child: Text(l10n.listSettingsMenuTitle),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _tabLabel(AppLocalizations l10n, ListHeaderTab tab) {
    return switch (tab) {
      ListHeaderTab.myDay => l10n.listTabMyDay,
      ListHeaderTab.allItems => l10n.listTabAllItems,
      ListHeaderTab.tasks => l10n.listTabTasks,
      ListHeaderTab.schedules => l10n.listTabSchedules,
      ListHeaderTab.memos => l10n.listTabMemos,
      ListHeaderTab.important => l10n.listTabImportant,
    };
  }

  Future<void> _showTabSwitcher(BuildContext context, WidgetRef ref) {
    final state = ref.read(listHeaderViewModelProvider);
    final l10n = context.l10n;

    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) {
        return AppSheetEntrance(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: RadioGroup<ListHeaderTab>(
              groupValue: state.currentTab,
              onChanged: (value) {
                if (value == null) return;
                ref.read(listHeaderViewModelProvider.notifier).switchTab(value);
                ui.closeDrawer(sheetContext);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.listMenuTitle,
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...ListHeaderTab.values.map(
                    (tab) => RadioListTile<ListHeaderTab>(
                      value: tab,
                      title: Text(_tabLabel(l10n, tab)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSettingsMenu(BuildContext context) {
    final l10n = context.l10n;

    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) {
        return AppSheetEntrance(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.listSettingsMenuTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(title: Text(l10n.listSettingsSort)),
                ListTile(title: Text(l10n.listSettingsReorder)),
                ListTile(title: Text(l10n.listSettingsTheme)),
                ListTile(title: Text(l10n.listSettingsMore)),
              ],
            ),
          ),
        );
      },
    );
  }
}
