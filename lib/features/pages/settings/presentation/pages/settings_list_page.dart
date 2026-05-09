import 'package:flutter/material.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsListPage extends StatelessWidget {
  const SettingsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: l10n.settingsListEntryTitle),
      ],
      child: const Center(
        child: Text('列表页的排序与布局设置在列表页右上角菜单中调整。'),
      ),
    );
  }
}
