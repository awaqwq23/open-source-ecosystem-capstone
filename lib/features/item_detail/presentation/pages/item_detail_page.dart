import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderPage(
      title: context.l10n.detailTitle,
      description: context.l10n.detailDescription,
      icon: Icons.article_outlined,
    );
  }
}
