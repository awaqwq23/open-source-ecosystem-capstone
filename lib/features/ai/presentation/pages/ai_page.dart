import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderPage(
      title: context.l10n.aiTitle,
      description: context.l10n.aiDescription,
      icon: Icons.auto_awesome,
    );
  }
}
