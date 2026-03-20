import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';

class TimePickerPage extends StatelessWidget {
  const TimePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderPage(
      title: context.l10n.timePickerTitle,
      description: context.l10n.timePickerDescription,
      icon: Icons.calendar_month,
    );
  }
}
