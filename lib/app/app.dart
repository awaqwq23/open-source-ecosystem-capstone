import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/router/app_router.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/localization/shadcn_localizations_fallback_delegate.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_factory.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class HuaJuanAgendaApp extends ConsumerWidget {
  const HuaJuanAgendaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return ui.ShadcnApp.router(
      title: 'HuaJuan Agenda',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        ShadcnFallbackLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      themeMode: themeMode,
      theme: AppThemeFactory.light(),
      darkTheme: AppThemeFactory.dark(),
      routerConfig: router,
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: const [
            Breakpoint(start: 0, end: 599, name: MOBILE),
            Breakpoint(start: 600, end: 1023, name: TABLET),
            Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
          ],
        );
      },
    );
  }
}
