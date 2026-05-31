import 'package:flutter/widgets.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/item_editor/presentation/widgets/option_card.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({
    required this.initialReminder,
    super.key,
  });

  final ReminderOption initialReminder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = ReminderOption.values;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.Tooltip(
              tooltip: (context) => Text(l10n.commonBack),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
          title: Text(l10n.editorReminderPageTitle),
        ),
      ],
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemBuilder: (context, index) {
          final reminder = options[index];
          return OptionCard<ReminderOption>(
            value: reminder,
            groupValue: initialReminder,
            title: _label(l10n, reminder),
            onChanged: (value) => Navigator.of(context).pop(value),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: options.length,
      ),
    );
  }

  String _label(AppLocalizations l10n, ReminderOption option) {
    return switch (option) {
      ReminderOption.none => l10n.editorReminderNone,
      ReminderOption.atTime => l10n.editorReminderAtTime,
      ReminderOption.fiveMinutesBefore => l10n.editorReminderFiveMinutes,
      ReminderOption.fifteenMinutesBefore => l10n.editorReminderFifteenMinutes,
      ReminderOption.oneHourBefore => l10n.editorReminderOneHour,
      ReminderOption.oneDayBefore => l10n.editorReminderOneDay,
    };
  }
}
