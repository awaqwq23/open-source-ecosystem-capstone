import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _appearanceSectionKey = GlobalKey();
  final GlobalKey _languageSectionKey = GlobalKey();
  final GlobalKey _homeSectionKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final l10n = context.l10n;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(l10n.settingsTitle),
          trailing: [
            ui.Tooltip(
              tooltip: (context) => Text(l10n.settingsQuickActionsTitle),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.quickActions),
                onPressed: () => _showQuickActions(context),
              ),
            ),
          ],
        ),
      ],
      child: Center(
        child: SizedBox.expand(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: AppEntrance(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(24),
                    ui.Card(
                      key: _appearanceSectionKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.themeSectionTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Gap(16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _OptionButton<ui.ThemeMode>(
                                label: l10n.themeSystem,
                                icon: AppIcons.themeSystem,
                                value: ui.ThemeMode.system,
                                selected: state.themeMode == ui.ThemeMode.system,
                                onTap: (value) {
                                  ref.read(settingsViewModelProvider.notifier).selectTheme(value);
                                },
                              ),
                              _OptionButton<ui.ThemeMode>(
                                label: l10n.themeLight,
                                icon: AppIcons.themeLight,
                                value: ui.ThemeMode.light,
                                selected: state.themeMode == ui.ThemeMode.light,
                                onTap: (value) {
                                  ref.read(settingsViewModelProvider.notifier).selectTheme(value);
                                },
                              ),
                              _OptionButton<ui.ThemeMode>(
                                label: l10n.themeDark,
                                icon: AppIcons.themeDark,
                                value: ui.ThemeMode.dark,
                                selected: state.themeMode == ui.ThemeMode.dark,
                                onTap: (value) {
                                  ref.read(settingsViewModelProvider.notifier).selectTheme(value);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    ui.Card(
                      key: _homeSectionKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.settingsHomeSectionTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Gap(8),
                          Text(
                            context.l10n.settingsHomeSectionDescription,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Gap(16),
                          _SettingsActionRow(
                            label: context.l10n.settingsHomeDayStart,
                            value: MaterialLocalizations.of(context)
                                .formatTimeOfDay(state.homeSettings.dayStartTime),
                            onTap: () => _pickHomeStartTime(context),
                          ),
                          _StepperRow(
                            label: context.l10n.settingsHomeBlockDuration,
                            value: context.l10n.settingsMinutesValue(
                              state.homeSettings.blockDurationMinutes,
                            ),
                            onDecrease: state.homeSettings.blockDurationMinutes > 15
                                ? () => _saveHomeSettings(
                                      state.homeSettings.copyWith(
                                        blockDurationMinutes:
                                            state.homeSettings.blockDurationMinutes - 15,
                                      ),
                                    )
                                : null,
                            onIncrease: () => _saveHomeSettings(
                              state.homeSettings.copyWith(
                                blockDurationMinutes:
                                    state.homeSettings.blockDurationMinutes + 15,
                              ),
                            ),
                          ),
                          _StepperRow(
                            label: context.l10n.settingsHomeBlockGap,
                            value: context.l10n.settingsMinutesValue(
                              state.homeSettings.blockGapMinutes,
                            ),
                            onDecrease: state.homeSettings.blockGapMinutes > 0
                                ? () => _saveHomeSettings(
                                      state.homeSettings.copyWith(
                                        blockGapMinutes:
                                            state.homeSettings.blockGapMinutes - 5,
                                      ),
                                    )
                                : null,
                            onIncrease: () => _saveHomeSettings(
                              state.homeSettings.copyWith(
                                blockGapMinutes: state.homeSettings.blockGapMinutes + 5,
                              ),
                            ),
                          ),
                          _StepperRow(
                            label: context.l10n.settingsHomeBlockCount,
                            value: '${state.homeSettings.blockCount}',
                            onDecrease: state.homeSettings.blockCount > 1
                                ? () => _saveHomeSettings(
                                      state.homeSettings.copyWith(
                                        blockCount: state.homeSettings.blockCount - 1,
                                      ),
                                    )
                                : null,
                            onIncrease: () => _saveHomeSettings(
                              state.homeSettings.copyWith(
                                blockCount: state.homeSettings.blockCount + 1,
                              ),
                            ),
                          ),
                          const Gap(12),
                          Text(
                            context.l10n.settingsHomeWideLayout,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const Gap(12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _OptionButton<HomeWideLayoutScope>(
                                label: context.l10n.homeScopeWeek,
                                icon: AppIcons.homeOutlined,
                                value: HomeWideLayoutScope.week,
                                selected: state.homeSettings.wideLayoutScope ==
                                    HomeWideLayoutScope.week,
                                onTap: (value) => _saveHomeSettings(
                                  state.homeSettings.copyWith(wideLayoutScope: value),
                                ),
                              ),
                              _OptionButton<HomeWideLayoutScope>(
                                label: context.l10n.homeScopeMonth,
                                icon: AppIcons.openTimePicker,
                                value: HomeWideLayoutScope.month,
                                selected: state.homeSettings.wideLayoutScope ==
                                    HomeWideLayoutScope.month,
                                onTap: (value) => _saveHomeSettings(
                                  state.homeSettings.copyWith(wideLayoutScope: value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    ui.Card(
                      key: _languageSectionKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.languageSectionTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Gap(16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _OptionButton<Locale>(
                                label: l10n.languageChinese,
                                icon: AppIcons.languageChinese,
                                value: AppLocale.chinese.locale,
                                selected: state.locale == AppLocale.chinese.locale,
                                onTap: (value) {
                                  ref.read(settingsViewModelProvider.notifier).selectLocale(value);
                                },
                              ),
                              _OptionButton<Locale>(
                                label: l10n.languageEnglish,
                                icon: AppIcons.languageEnglish,
                                value: AppLocale.english.locale,
                                selected: state.locale == AppLocale.english.locale,
                                onTap: (value) {
                                  ref.read(settingsViewModelProvider.notifier).selectLocale(value);
                                },
                              ),
                            ],
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
    );
  }

  Future<void> _showQuickActions(BuildContext context) {
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
                  l10n.settingsQuickActionsTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(AppIcons.appearanceSection),
                  title: Text(l10n.themeSectionTitle),
                  onTap: () {
                    ui.closeDrawer(sheetContext);
                    _scrollToSection(_appearanceSectionKey);
                  },
                ),
                ListTile(
                  leading: const Icon(AppIcons.homeOutlined),
                  title: Text(l10n.settingsHomeSectionTitle),
                  onTap: () {
                    ui.closeDrawer(sheetContext);
                    _scrollToSection(_homeSectionKey);
                  },
                ),
                ListTile(
                  leading: const Icon(AppIcons.languageChinese),
                  title: Text(l10n.languageSectionTitle),
                  onTap: () {
                    ui.closeDrawer(sheetContext);
                    _scrollToSection(_languageSectionKey);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToSection(GlobalKey sectionKey) {
    final sectionContext = sectionKey.currentContext;
    if (sectionContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  Future<void> _pickHomeStartTime(BuildContext context) async {
    final settings = ref.read(settingsViewModelProvider).homeSettings;
    final result = await showTimePicker(
      context: context,
      initialTime: settings.dayStartTime,
    );
    if (result == null) {
      return;
    }
    await _saveHomeSettings(settings.copyWith(dayStartTime: result));
  }

  Future<void> _saveHomeSettings(HomeSettings settings) {
    return ref.read(settingsViewModelProvider.notifier).saveHomeSettings(settings);
  }
}

class _OptionButton<T> extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final T value;
  final bool selected;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return ui.PrimaryButton(
        onPressed: () => onTap(value),
        leading: Icon(icon),
        child: Text(label),
      );
    }

    return ui.OutlineButton(
      onPressed: () => onTap(value),
      leading: Icon(icon),
      child: Text(label),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(AppIcons.drillIn),
      onTap: onTap,
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
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
