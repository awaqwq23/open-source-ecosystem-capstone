import 'package:flutter/widgets.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/item_editor/presentation/widgets/option_card.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';
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
      child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemBuilder: (context, index) {
            final rule = options[index];
            return OptionCard<RepeatRule>(
              value: rule,
              groupValue: initialRule,
              title: _label(l10n, rule),
              subtitle:
                  index == 0 ? l10n.editorRepeatPagePlaceholder : null,
              onChanged: (value) => Navigator.of(context).pop(value),
            );
          },
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemCount: options.length,
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
