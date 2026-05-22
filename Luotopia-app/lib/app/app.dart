import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_router.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/localization/shadcn_localizations_fallback_delegate.dart';
import 'package:luotopia/core/theme/theme_controller.dart';
import 'package:luotopia/core/theme/theme_factory.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class LuotopiaApp extends ConsumerWidget {
  const LuotopiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return ui.ShadcnApp.router(
      title: 'Luotopia',
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
        final shadTheme = ui.Theme.of(context);
        return Theme(
          data: _materialThemeFromShadcn(shadTheme),
          child: ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: const [
              Breakpoint(start: 0, end: 599, name: MOBILE),
              Breakpoint(start: 600, end: 1023, name: TABLET),
              Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
            ],
          ),
        );
      },
    );
  }
}

ThemeData _materialThemeFromShadcn(ui.ThemeData shadTheme) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: shadTheme.colorScheme.primary,
    brightness: shadTheme.brightness,
    surface: shadTheme.colorScheme.background,
    primary: shadTheme.colorScheme.primary,
    secondary: shadTheme.colorScheme.secondary,
    error: shadTheme.colorScheme.destructive,
  );
  final base = ThemeData.from(
    colorScheme: colorScheme,
    useMaterial3: true,
  );
  final borderColor = shadTheme.colorScheme.border;
  final overlayColor = shadTheme.colorScheme.popover;
  final foreground = shadTheme.colorScheme.foreground;

  return base.copyWith(
    scaffoldBackgroundColor: shadTheme.colorScheme.background,
    canvasColor: overlayColor,
    cardColor: shadTheme.colorScheme.card,
    dividerColor: borderColor,
    dialogTheme: base.dialogTheme.copyWith(
      backgroundColor: overlayColor,
      surfaceTintColor: Colors.transparent,
    ),
    popupMenuTheme: base.popupMenuTheme.copyWith(
      color: overlayColor,
      surfaceTintColor: Colors.transparent,
    ),
    dropdownMenuTheme: base.dropdownMenuTheme.copyWith(
      textStyle: base.textTheme.bodyMedium?.copyWith(color: foreground),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(overlayColor),
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: borderColor),
        ),
        surfaceTintColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: shadTheme.colorScheme.primary,
      selectionColor: shadTheme.colorScheme.primary.withValues(alpha: 0.3),
      selectionHandleColor: shadTheme.colorScheme.primary,
    ),
  );
}
