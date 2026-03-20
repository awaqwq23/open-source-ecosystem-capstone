import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
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
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
          title: Text(l10n.editorReminderPageTitle),
        ),
      ],
      child: AppEntrance(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemBuilder: (context, index) {
            final reminder = options[index];
            final selected = reminder == initialReminder;
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: selected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                  : Theme.of(context).colorScheme.surfaceContainerLowest,
              title: Text(_label(l10n, reminder)),
              trailing: selected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(reminder),
            );
          },
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemCount: options.length,
        ),
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
