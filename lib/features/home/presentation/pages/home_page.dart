import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeHeaderViewModelProvider);
    final viewModel = ref.read(homeHeaderViewModelProvider.notifier);
    final theme = Theme.of(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          surfaceBlur: 0,
          surfaceOpacity: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SizedBox(
            height: 60,
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ui.Tooltip(
                          tooltip: (context) => Text(context.l10n.headerPreviousPeriod),
                          child: ui.IconButton.ghost(
                            icon: const Icon(AppIcons.previousPeriod),
                            onPressed: viewModel.showPrevious,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 72),
                        child: TextButton(
                          onPressed: () => context.push(AppRoutePaths.timePicker),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _formatPeriodLabel(context, state),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(AppIcons.expandSelection, size: 18),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ui.Tooltip(
                          tooltip: (context) => Text(context.l10n.headerNextPeriod),
                          child: ui.IconButton.ghost(
                            icon: const Icon(AppIcons.nextPeriod),
                            onPressed: viewModel.showNext,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 12,
                  color: theme.dividerColor.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AppEntrance(
              child: ui.Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSwitchingContent(
                      contentKey: 'home-title',
                      child: Text(
                        context.l10n.homeTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppSwitchingContent(
                      contentKey: 'home-description-${state.scope.name}',
                      child: Text(
                        context.l10n.homeDescription,
                        style: theme.textTheme.titleMedium,
                      ),
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
                            onPressed: () => context.push(AppRoutePaths.timePicker),
                            child: Text(context.l10n.placeholderOpenPicker),
                          ),
                          ui.GhostButton(
                            onPressed: () => _showScopePicker(context, ref),
                            child: Text(context.l10n.homeScopePickerTitle),
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

  String _formatPeriodLabel(BuildContext context, HomeHeaderState state) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return switch (state.scope) {
      HomeHeaderScope.week => locale.startsWith('zh')
          ? '${state.anchor.year}年第${_weekOfYear(state.anchor)}周'
          : 'Week ${_weekOfYear(state.anchor)}, ${state.anchor.year}',
      HomeHeaderScope.month => DateFormat.yMMMM(locale).format(state.anchor),
    };
  }

  int _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final offset = firstDay.weekday - DateTime.monday;
    final dayOfYear = date.difference(firstDay).inDays + 1;
    return ((dayOfYear + offset - 1) ~/ 7) + 1;
  }

  Future<void> _showScopePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.read(homeHeaderViewModelProvider);

    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) {
        return AppSheetEntrance(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: RadioGroup<HomeHeaderScope>(
              groupValue: state.scope,
              onChanged: (value) {
                if (value == null) return;
                ref.read(homeHeaderViewModelProvider.notifier).switchScope(value);
                ui.closeDrawer(sheetContext);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeScopePickerTitle,
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<HomeHeaderScope>(
                    value: HomeHeaderScope.week,
                    title: Text(l10n.homeScopeWeek),
                  ),
                  RadioListTile<HomeHeaderScope>(
                    value: HomeHeaderScope.month,
                    title: Text(l10n.homeScopeMonth),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
