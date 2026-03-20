import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';

class ItemEditorPage extends StatelessWidget {
  const ItemEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderPage(
      title: context.l10n.editorTitle,
      description: context.l10n.editorDescription,
      icon: Icons.add_box,
    );
  }
}
