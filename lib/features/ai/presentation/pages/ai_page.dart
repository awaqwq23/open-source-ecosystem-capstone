import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/features/ai/presentation/viewmodels/ai_header_view_model.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_action_button.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_header.dart';
import 'package:huajuan_agenda/shared/widgets/app_sheet_scaffold.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';
import 'package:intl/intl.dart';

class AiPage extends ConsumerWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiHeaderViewModelProvider);

    return AppPlaceholderPage(
      title: context.l10n.aiTitle,
      description: context.l10n.aiDescription,
      icon: Icons.auto_awesome,
      header: AppPageHeader(
        title: AppPageHeaderTitle(
          text: context.l10n.aiTitle,
        ),
        trailing: [
          AppPageActionButton(
            icon: Icons.calendar_month,
            tooltip: context.l10n.headerOpenTimePicker,
            onPressed: () => _showPeriodPicker(context, ref),
          ),
        ],
      ),
      primaryActionLabel: _periodLabel(context, state),
      onPrimaryAction: () => _showPeriodPicker(context, ref),
      secondaryActionLabel: context.l10n.timePickerTitle,
      onSecondaryAction: () => context.push(AppRoutePaths.timePicker),
    );
  }

  String _periodLabel(BuildContext context, AiHeaderState state) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return switch (state.period) {
      AiHeaderPeriod.day => DateFormat.yMd(locale).format(state.anchor),
      AiHeaderPeriod.week => locale.startsWith('zh')
          ? '${DateFormat.yM(locale).format(state.anchor)} 第${_weekOfMonth(state.anchor)}周'
          : 'Week ${_weekOfMonth(state.anchor)} of ${DateFormat.yMMMM(locale).format(state.anchor)}',
      AiHeaderPeriod.month => DateFormat.yMMMM(locale).format(state.anchor),
    };
  }

  int _weekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final offset = firstDay.weekday - DateTime.monday;
    return ((date.day + offset - 1) ~/ 7) + 1;
  }

  Future<void> _showPeriodPicker(BuildContext context, WidgetRef ref) {
    final state = ref.read(aiHeaderViewModelProvider);
    final l10n = context.l10n;

    return showAppSheetScaffold(
      context: context,
      title: l10n.aiPeriodPickerTitle,
      child: RadioGroup<AiHeaderPeriod>(
        groupValue: state.period,
        onChanged: (value) {
          if (value == null) return;
          ref.read(aiHeaderViewModelProvider.notifier).select(value);
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AiHeaderPeriod>(
              value: AiHeaderPeriod.day,
              title: Text(l10n.aiPeriodDay),
            ),
            RadioListTile<AiHeaderPeriod>(
              value: AiHeaderPeriod.week,
              title: Text(l10n.aiPeriodWeek),
            ),
            RadioListTile<AiHeaderPeriod>(
              value: AiHeaderPeriod.month,
              title: Text(l10n.aiPeriodMonth),
            ),
          ],
        ),
      ),
    );
  }
}
