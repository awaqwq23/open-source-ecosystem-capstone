import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(context.l10n.settingsTitle),
          trailing: [
            ui.Tooltip(
              tooltip: (context) => Text(context.l10n.settingsSearchTooltip),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.search),
                onPressed: () => _openSearch(context, entries),
              ),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: SettingsFlatSection(
          children: entries
              .map(
                (entry) => SettingsFlatTile(
                  title: entry.title,
                  subtitle: entry.subtitle,
                  leading: Icon(entry.icon),
                  onTap: () => context.push(entry.route),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _openSearch(BuildContext context, List<_SettingsEntry> entries) async {
    final result = await showSearch<_SettingsEntry?>(
      context: context,
      delegate: _SettingsSearchDelegate(
        entries: entries,
        searchFieldLabel: context.l10n.settingsSearchHint,
      ),
    );
    if (result != null && context.mounted) {
      context.push(result.route);
    }
  }

  List<_SettingsEntry> _buildEntries(BuildContext context) {
    final l10n = context.l10n;
    return [
      _SettingsEntry(
        title: l10n.settingsGeneralEntryTitle,
        subtitle: l10n.settingsGeneralEntrySubtitle,
        route: AppRoutePaths.settingsGeneral,
        icon: AppIcons.settingsOutlined,
      ),
      _SettingsEntry(
        title: l10n.settingsHomeSectionTitle,
        subtitle: l10n.settingsHomeEntrySubtitle,
        route: AppRoutePaths.settingsHome,
        icon: AppIcons.homeOutlined,
      ),
      _SettingsEntry(
        title: l10n.settingsListEntryTitle,
        subtitle: l10n.settingsListEntrySubtitle,
        route: AppRoutePaths.settingsList,
        icon: AppIcons.listOutlined,
      ),
      _SettingsEntry(
        title: _isChinese(context) ? '课程表与导入' : 'Course Tables & Import',
        subtitle: _isChinese(context) ? '管理课程表、导入课程数据' : 'Manage timetables and import courses',
        route: AppRoutePaths.settingsCourseTimetables,
        icon: AppIcons.itemTypeCourse,
      ),
      _SettingsEntry(
        title: _isChinese(context) ? 'AI 设置' : 'AI Settings',
        subtitle: _isChinese(context) ? 'API 地址、密钥、模型与提示词' : 'API URL, key, model and system prompt',
        route: AppRoutePaths.settingsAi,
        icon: AppIcons.aiOutlined,
      ),
      _SettingsEntry(
        title: l10n.settingsAboutEntryTitle,
        subtitle: l10n.settingsAboutEntrySubtitle,
        route: AppRoutePaths.settingsAbout,
        icon: AppIcons.info,
      ),
    ];
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
  }
}

class _SettingsSearchDelegate extends SearchDelegate<_SettingsEntry?> {
  _SettingsSearchDelegate({
    required this.entries,
    required String searchFieldLabel,
  }) : super(searchFieldLabel: searchFieldLabel);

  final List<_SettingsEntry> entries;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.close),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(AppIcons.back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context, _filteredEntries);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context, _filteredEntries);
  }

  List<_SettingsEntry> get _filteredEntries {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return entries;
    }
    return entries
        .where(
          (entry) =>
              entry.title.toLowerCase().contains(keyword) ||
              entry.subtitle.toLowerCase().contains(keyword),
        )
        .toList(growable: false);
  }

  Widget _buildList(BuildContext context, List<_SettingsEntry> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(context.l10n.settingsSearchEmpty),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = results[index];
        return ListTile(
          leading: Icon(entry.icon),
          title: Text(entry.title),
          subtitle: Text(entry.subtitle),
          trailing: const Icon(AppIcons.drillIn, size: 18),
          onTap: () => close(context, entry),
        );
      },
    );
  }
}

class _SettingsEntry {
  const _SettingsEntry({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
}
