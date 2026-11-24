import 'package:flutter/material.dart';
import 'package:luotopia/app/shell/app_shell.dart';
import 'package:luotopia/core/theme/theme_factory.dart';
import 'package:luotopia/core/localization/generated/app_localizations.dart';
import 'package:luotopia/core/localization/shadcn_localizations_fallback_delegate.dart';
import 'package:luotopia/features/pages/ai/domain/repositories/ai_runtime_providers.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/features/components/wallpaper/data/bing_wallpaper_repository.dart';
import 'package:luotopia/features/components/wallpaper/domain/models/today_wallpaper.dart';
import 'package:luotopia/features/pages/campus/presentation/pages/campus_page.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/bundled_plugins.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class _NoWallpaper extends TodayWallpaperNotifier {
  @override
  AsyncValue<TodayWallpaper?> build() => const AsyncData(null);
}

void main() {
  Future<PluginManager> manager() async {
    final result = PluginManager();
    for (final c in result.entries(ContributionSlot.campusCard)) {
      if (!{
        'luotopia.timetable',
        'luotopia.seat-reservation',
        'luotopia.library',
        'luotopia.sports-reservation',
      }.contains(c.pluginId)) {
        await result.setContributionVisible(c.key, false);
      }
    }
    return result;
  }

  Future<void> pump(WidgetTester tester, PluginManager manager) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const CampusPage()),
        GoRoute(
          path: '/plugins/luotopia.library/card/main',
          builder: (_, _) => const Text('library plugin destination'),
        ),
        GoRoute(
          path: '/campus/timetable',
          builder: (_, _) => const Text('timetable destination'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pluginManagerProvider.overrideWith((_) => manager),
          todayWallpaperProvider.overrideWith(_NoWallpaper.new),
        ],
        child: ui.ShadcnApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('migrated campus card routes to independent script provider', (
    tester,
  ) async {
    final registry = PluginManager(bundledPackages: await loadBundledPlugins());
    for (final c in registry.entries(ContributionSlot.campusCard)) {
      if (c.pluginId != 'luotopia.library') {
        await registry.setContributionVisible(c.key, false);
      }
    }
    await pump(tester, registry);
    await tester.tap(find.text('图书借阅'));
    await tester.pumpAndSettle();
    expect(find.text('library plugin destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'renaming a campus card preserves its native route and hiding updates layout',
    (tester) async {
      final registry = await manager();
      await registry.updatePresentation('luotopia.timetable/card', {
        'title': 'My classes',
      });
      await registry.updatePresentation('luotopia.library/card', {
        'icon': 'school',
        'color': 'sky',
      });
      await pump(tester, registry);
      final libraryIcon = tester.widget<Icon>(
        find
            .descendant(
              of: find.byKey(const ValueKey('luotopia.library/card')),
              matching: find.byIcon(Icons.school_outlined),
            )
            .first,
      );
      expect(libraryIcon.color, const Color(0xFF4DA3FF));
      expect(find.text('My classes'), findsOneWidget);
      await registry.setContributionVisible('luotopia.library/card', false);
      await tester.pumpAndSettle();
      expect(find.text('图书借阅'), findsNothing);
      await tester.tap(find.text('My classes'));
      await tester.pumpAndSettle();
      expect(find.text('timetable destination'), findsOneWidget);
    },
  );
  testWidgets('long press drag across rows saves full stable order', (
    tester,
  ) async {
    final registry = await manager();
    await pump(tester, registry);
    final before = registry.revision;
    final start = tester.getCenter(find.text('课程表'));
    final target = tester.getCenter(find.text('运动场馆'));
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(target);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(registry.revision, before + 1);
    expect(
      registry.entries(ContributionSlot.campusCard).last.pluginId,
      'luotopia.timetable',
    );
  });
  testWidgets('cancelled drag leaves saved order unchanged', (tester) async {
    final registry = await manager();
    await pump(tester, registry);
    final before = registry.revision;
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('课程表')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(tester.getCenter(find.text('自习预约')));
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(registry.revision, before);
    expect(
      registry.entries(ContributionSlot.campusCard).first.pluginId,
      'luotopia.timetable',
    );
  });
  testWidgets(
    'dragging near bottom scrolls the campus and cancellation does not save',
    (tester) async {
      final registry = PluginManager();
      await registry.setContributionVisible('luotopia.campus-info/card', false);
      await pump(tester, registry);
      final before = registry.revision;
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('课程表')),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(const Offset(750, 570));
      await tester.pump(const Duration(milliseconds: 300));
      final list = tester.widget<ListView>(find.byType(ListView).first);
      expect(list.controller!.offset, greaterThan(0));
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(registry.revision, before);
    },
  );
  testWidgets(
    'navigation reordering uses branch identity and keeps AI activation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final registry = PluginManager();
      await registry.setContributionVisible('luotopia.ai/tab', true);
      final order = registry
          .entries(ContributionSlot.navigation)
          .map((c) => c.key)
          .toList();
      order.remove('luotopia.ai/tab');
      order.insert(1, 'luotopia.ai/tab');
      await registry.reorder(ContributionSlot.navigation, order);
      await registry.updatePresentation('luotopia.ai/tab', {
        'title': 'Study AI',
      });
      final container = ProviderContainer(
        overrides: [pluginManagerProvider.overrideWith((_) => registry)],
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (_, _, shell) => AppShell(navigationShell: shell),
            branches: [
              for (final path in [
                '/',
                '/list',
                '/forum',
                '/ai',
                '/campus',
                '/settings',
              ])
                StatefulShellBranch(
                  routes: [
                    GoRoute(path: path, builder: (_, _) => Text('page $path')),
                  ],
                ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ui.ShadcnApp.router(
            routerConfig: router,
            locale: const Locale('zh'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ShadcnFallbackLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => ResponsiveBreakpoints.builder(
              breakpoints: const [
                Breakpoint(start: 0, end: 599, name: MOBILE),
                Breakpoint(start: 600, end: double.infinity, name: DESKTOP),
              ],
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('compact-navigation-strip')),
        findsOneWidget,
      );
      final strip = find.byKey(const ValueKey('compact-navigation-strip'));
      final beforeDrag = registry.revision;
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('luotopia.home/tab'))),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(
        Offset(tester.getRect(strip).right - 2, tester.getCenter(strip).dy),
      );
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: strip, matching: find.byType(Scrollable)).first,
      );
      expect(scrollable.position.pixels, greaterThan(0));
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(registry.revision, beforeDrag);
      await tester.drag(strip, const Offset(500, 0));
      await tester.pumpAndSettle();
      final reorderGesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('luotopia.home/tab'))),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await reorderGesture.moveTo(
        tester.getCenter(find.byKey(const ValueKey('luotopia.settings/tab'))),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await reorderGesture.up();
      await tester.pumpAndSettle();
      expect(registry.revision, greaterThan(beforeDrag));
      expect(
        registry.entries(ContributionSlot.navigation).first.key,
        isNot('luotopia.home/tab'),
      );
      await tester.tap(find.byKey(const ValueKey('luotopia.ai/tab')));
      await tester.pumpAndSettle();
      expect(find.text('page /ai'), findsOneWidget);
      expect(container.read(aiPageActivationProvider), 1);
      await tester.tap(find.byKey(const ValueKey('luotopia.settings/tab')));
      await tester.pumpAndSettle();
      expect(find.text('page /settings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final dark in [false, true]) {
    for (final wide in [false, true]) {
      testWidgets(
        'default five navigation entries preserve layout and routes dark=$dark wide=$wide',
        (tester) async {
          tester.view.physicalSize = wide
              ? const Size(1280, 900)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final registry = PluginManager();
          final router = GoRouter(
            routes: [
              StatefulShellRoute.indexedStack(
                builder: (_, _, shell) => AppShell(navigationShell: shell),
                branches: [
                  for (final path in [
                    '/',
                    '/list',
                    '/forum',
                    '/ai',
                    '/campus',
                    '/settings',
                  ])
                    StatefulShellBranch(
                      routes: [
                        GoRoute(
                          path: path,
                          builder: (_, _) => Text('page $path'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [pluginManagerProvider.overrideWith((_) => registry)],
              child: ui.ShadcnApp.router(
                routerConfig: router,
                locale: const Locale('zh'),
                themeMode: dark ? ui.ThemeMode.dark : ui.ThemeMode.light,
                theme: AppThemeFactory.light(),
                darkTheme: AppThemeFactory.dark(),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ShadcnFallbackLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (_, child) => ResponsiveBreakpoints.builder(
                  breakpoints: const [
                    Breakpoint(start: 0, end: 599, name: MOBILE),
                    Breakpoint(start: 600, end: double.infinity, name: DESKTOP),
                  ],
                  child: child!,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(ui.NavigationItem), findsNWidgets(5));
          expect(find.byKey(const ValueKey('luotopia.ai/tab')), findsNothing);
          if (wide) {
            expect(find.byType(ui.NavigationSidebar), findsOneWidget);
          } else {
            final bar = tester.widget<ui.NavigationBar>(
              find.byType(ui.NavigationBar).first,
            );
            expect(bar.expandedSize, 72);
            expect(bar.labelType, ui.NavigationLabelType.none);
            final items = tester
                .widgetList<ui.NavigationItem>(find.byType(ui.NavigationItem))
                .toList();
            expect(items.map((item) => (item.key as ValueKey).value), [
              'luotopia.home/tab',
              'luotopia.campus/tab',
              'luotopia.settings/tab',
              'luotopia.list/tab',
              'luotopia.forum/tab',
            ]);
            for (final item in items) {
              expect((item.child as Icon).size, 28);
            }
          }
          for (final destination in [
            ('home', '/'),
            ('list', '/list'),
            ('forum', '/forum'),
            ('campus', '/campus'),
            ('settings', '/settings'),
          ]) {
            await tester.tap(
              find
                  .descendant(
                    of: find.byKey(ValueKey('luotopia.${destination.$1}/tab')),
                    matching: find.byType(Icon),
                  )
                  .first,
            );
            await tester.pumpAndSettle();
            expect(find.text('page ${destination.$2}'), findsOneWidget);
            final itemKey = ValueKey('luotopia.${destination.$1}/tab');
            if (wide) {
              expect(
                tester
                    .widget<ui.NavigationSidebar>(
                      find.byType(ui.NavigationSidebar),
                    )
                    .selectedKey,
                itemKey,
              );
            } else {
              expect(
                tester
                    .widget<ui.NavigationBar>(
                      find.byType(ui.NavigationBar).first,
                    )
                    .selectedKey,
                itemKey,
              );
            }
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }
}
