import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/features/list/presentation/viewmodels/list_header_view_model.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_action_button.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_header.dart';
import 'package:huajuan_agenda/shared/widgets/app_sheet_scaffold.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listHeaderViewModelProvider);
    final l10n = context.l10n;

    return AppPlaceholderPage(
      title: context.l10n.listTitle,
      description: context.l10n.listDescription,
      icon: Icons.checklist_rtl,
      header: AppPageHeader(
        centerTitleWhenCompact: true,
        title: AppPageHeaderTitle(
          text: _tabLabel(l10n, state.currentTab),
          center: true,
        ),
        leading: [
          AppPageActionButton(
            icon: Icons.menu,
            tooltip: l10n.headerOpenListTabs,
            onPressed: () => _showTabSwitcher(context, ref),
          ),
        ],
        trailing: [
          AppPageActionButton(
            icon: Icons.more_horiz,
            tooltip: l10n.headerOpenListSettings,
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      primaryActionLabel: l10n.placeholderOpenMenu,
      onPrimaryAction: () => _showTabSwitcher(context, ref),
      secondaryActionLabel: l10n.listSettingsMenuTitle,
      onSecondaryAction: () => _showSettingsMenu(context),
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

    return showAppSheetScaffold(
      context: context,
      title: l10n.listMenuTitle,
      child: RadioGroup<ListHeaderTab>(
        groupValue: state.currentTab,
        onChanged: (value) {
          if (value == null) return;
          ref.read(listHeaderViewModelProvider.notifier).switchTab(value);
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ListHeaderTab.values.map((tab) {
            return RadioListTile<ListHeaderTab>(
              value: tab,
              title: Text(_tabLabel(l10n, tab)),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _showSettingsMenu(BuildContext context) {
    final l10n = context.l10n;

    return showAppSheetScaffold(
      context: context,
      title: l10n.listSettingsMenuTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(l10n.listSettingsSort)),
          ListTile(title: Text(l10n.listSettingsReorder)),
          ListTile(title: Text(l10n.listSettingsTheme)),
          ListTile(title: Text(l10n.listSettingsMore)),
        ],
      ),
    );
  }
}
