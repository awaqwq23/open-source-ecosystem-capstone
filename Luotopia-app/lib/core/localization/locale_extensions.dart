import 'package:flutter/widgets.dart';
import 'package:luotopia/app/shell/app_shell_destination.dart';
import 'package:luotopia/core/localization/generated/app_localizations.dart';

export 'package:luotopia/core/localization/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension AppShellDestinationLabelX on AppShellDestination {
  String label(BuildContext context) {
    final l10n = context.l10n;

    return switch (this) {
      AppShellDestination.home => l10n.navHome,
      AppShellDestination.list => l10n.navList,
      AppShellDestination.forum => l10n.navForum,
      AppShellDestination.ai => l10n.navAi,
      AppShellDestination.campus => l10n.navCampus,
      AppShellDestination.settings => l10n.navSettings,
    };
  }
}
