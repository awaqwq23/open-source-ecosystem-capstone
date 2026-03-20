import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_action_button.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_header.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderPage(
      title: context.l10n.detailTitle,
      description: context.l10n.detailDescription,
      icon: Icons.article_outlined,
      header: AppPageHeader(
        title: AppPageHeaderTitle(
          text: context.l10n.detailTitle,
        ),
        leading: [
          AppPageActionButton(
            icon: Icons.arrow_back,
            tooltip: context.l10n.commonBack,
            onPressed: context.pop,
          ),
        ],
      ),
    );
  }
}
