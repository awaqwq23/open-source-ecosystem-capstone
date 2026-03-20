import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/features/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_action_button.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_header.dart';
import 'package:huajuan_agenda/shared/widgets/app_sheet_scaffold.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeHeaderViewModelProvider);
    final viewModel = ref.read(homeHeaderViewModelProvider.notifier);

    return AppPlaceholderPage(
      title: context.l10n.homeTitle,
      description: context.l10n.homeDescription,
      icon: Icons.calendar_view_week,
      header: AppPageHeader(
        centerTitleWhenCompact: true,
        title: AppPageHeaderTitle(
          text: _formatPeriodLabel(context, state),
          center: true,
          showDropdownIndicator: true,
          onPressed: () => context.push(AppRoutePaths.timePicker),
        ),
        leading: [
          AppPageActionButton(
            icon: Icons.chevron_left,
            tooltip: context.l10n.headerPreviousPeriod,
            onPressed: viewModel.showPrevious,
          ),
        ],
        trailing: [
          AppPageActionButton(
            icon: Icons.chevron_right,
            tooltip: context.l10n.headerNextPeriod,
            onPressed: viewModel.showNext,
          ),
        ],
      ),
      primaryActionLabel: context.l10n.placeholderOpenPicker,
      onPrimaryAction: () => context.push(AppRoutePaths.timePicker),
      secondaryActionLabel: context.l10n.homeScopePickerTitle,
      onSecondaryAction: () => _showScopePicker(context, ref),
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

    return showAppSheetScaffold(
      context: context,
      title: l10n.homeScopePickerTitle,
      child: RadioGroup<HomeHeaderScope>(
        groupValue: state.scope,
        onChanged: (value) {
          if (value == null) return;
          ref.read(homeHeaderViewModelProvider.notifier).switchScope(value);
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    );
  }
}
