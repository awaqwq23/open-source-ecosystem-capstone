import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderPage(
      title: context.l10n.homeTitle,
      description: context.l10n.homeDescription,
      icon: Icons.calendar_view_week,
    );
  }
}
