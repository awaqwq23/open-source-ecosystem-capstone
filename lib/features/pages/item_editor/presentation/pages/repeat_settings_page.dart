import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class RepeatSettingsPage extends StatelessWidget {
  const RepeatSettingsPage({
    required this.initialRule,
    super.key,
  });

  final RepeatRule initialRule;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = RepeatRule.values;

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
          title: Text(l10n.editorRepeatPageTitle),
        ),
      ],
      child: AppEntrance(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemBuilder: (context, index) {
            final rule = options[index];
            final selected = rule == initialRule;
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: selected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                  : Theme.of(context).colorScheme.surfaceContainerLowest,
              title: Text(_label(l10n, rule)),
              subtitle: index == 0 ? Text(l10n.editorRepeatPagePlaceholder) : null,
              trailing: selected
                  ? Icon(
                      AppIcons.selected,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Icon(AppIcons.drillIn),
              onTap: () => Navigator.of(context).pop(rule),
            );
          },
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemCount: options.length,
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n, RepeatRule rule) {
    return switch (rule) {
      RepeatRule.none => l10n.editorRepeatNone,
      RepeatRule.everyDay => l10n.editorRepeatDaily,
      RepeatRule.weekdays => l10n.editorRepeatWeekdays,
      RepeatRule.everyWeek => l10n.editorRepeatWeekly,
      RepeatRule.everyMonth => l10n.editorRepeatMonthly,
      RepeatRule.everyYear => l10n.editorRepeatYearly,
    };
  }
}
