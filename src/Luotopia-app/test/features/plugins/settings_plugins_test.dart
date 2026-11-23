import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/shadcn_localizations_fallback_delegate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/core/localization/generated/app_localizations.dart';
import 'package:luotopia/features/components/wallpaper/data/bing_wallpaper_repository.dart';
import 'package:luotopia/features/components/wallpaper/domain/models/today_wallpaper.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_page.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/bundled_plugins.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_auth_state.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class _NoWallpaper extends TodayWallpaperNotifier {
  @override
  AsyncValue<TodayWallpaper?> build() => const AsyncData(null);
}

class _LocalAuth extends LuotopiaAuthNotifier {
  @override
  LuotopiaAuthState build() => const LuotopiaAuthState();
}

class _WhuAuth extends WhuAuthNotifier {
  @override
  WhuAuthState build() => const WhuAuthState();
}

void main() {
  test(
    'plugin management entry is protected and survives hiding attempts',
    () async {
      final manager = PluginManager();
      addTearDown(manager.dispose);
      const key = 'luotopia.settings/plugins';
      final row = manager.contribution(key);
      expect(row.protected, isTrue);
      expect(row.nativeRoute, '/settings/plugins');
      await expectLater(
        manager.setContributionVisible(key, false),
        throwsA(anything),
      );
      expect(manager.isVisible(key), isTrue);
      expect(manager.entries(ContributionSlot.settingsRow).first.key, key);
    },
  );

  for (final bundled in [false, true]) {
    testWidgets(
      'settings opens management and provider routes bundled=$bundled',
      (tester) async {
        final manager = PluginManager(
          bundledPackages: bundled ? await loadBundledPlugins() : const [],
        );
        await manager.setContributionVisible(
          'luotopia.notification/row',
          false,
        );
        final router = GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const SettingsPage()),
            GoRoute(
              path: '/plugins/luotopia.placeholder-1/row/main',
              builder: (_, _) => const Text('独立插件目的页'),
            ),
            GoRoute(
              path: '/settings/plugins',
              builder: (_, _) => const Text('插件管理目的页'),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              pluginManagerProvider.overrideWith((_) => manager),
              todayWallpaperProvider.overrideWith(_NoWallpaper.new),
              luotopiaAuthProvider.overrideWith(_LocalAuth.new),
              whuAuthProvider.overrideWith(_WhuAuth.new),
            ],
            child: ui.ShadcnApp.router(
              routerConfig: router,
              locale: const Locale('zh'),
              localizationsDelegates: const [
                ShadcnFallbackLocalizationsDelegate(),
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('插件管理'), findsOneWidget);
        expect(find.textContaining('核心功能 · 受保护'), findsWidgets);
        expect(find.textContaining('系统插件 · 可选'), findsWidgets);
        expect(find.text('可选功能示例 1'), findsOneWidget);
        expect(find.text('Lorem Ipsum'), findsNothing);
        if (bundled) {
          final source = find.byKey(
            const ValueKey('settings-row-luotopia.settings/plugins'),
          );
          final target = find.byKey(
            const ValueKey('settings-row-luotopia.settings/general'),
          );
          await tester.ensureVisible(source);
          final drag = await tester.startGesture(tester.getCenter(source));
          await tester.pump(const Duration(milliseconds: 650));
          await drag.moveTo(tester.getCenter(target));
          await tester.pump();
          await drag.up();
          await tester.pumpAndSettle();
          final keys = manager
              .entries(ContributionSlot.settingsRow)
              .map((r) => r.key)
              .toList();
          expect(
            keys.indexOf('luotopia.settings/plugins'),
            greaterThan(keys.indexOf('luotopia.settings/general')),
          );
        }
        await tester.ensureVisible(find.text('插件管理'));
        await tester.tap(find.text('插件管理'));
        await tester.pumpAndSettle();
        expect(find.text('插件管理目的页'), findsOneWidget);
        if (bundled) {
          router.pop();
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('可选功能示例 1'));
          await tester.tap(find.text('可选功能示例 1'));
          await tester.pumpAndSettle();
          expect(find.text('独立插件目的页'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
