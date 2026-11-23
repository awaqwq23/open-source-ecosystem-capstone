import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/features/components/wallpaper/data/bing_wallpaper_repository.dart';
import 'package:luotopia/features/components/wallpaper/domain/models/today_wallpaper.dart';
import 'package:luotopia/features/pages/campus/presentation/pages/campus_page.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class _NoWallpaper extends TodayWallpaperNotifier {
  @override
  AsyncValue<TodayWallpaper?> build() => const AsyncData(null);
}

void main() {
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'LUOTOPIA_API_BASE_URL=http://localhost',
    ),
  );
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

  testWidgets(
    'gap insertion previews neighbors before committing exact order',
    (tester) async {
      final registry = await manager();
      await pump(tester, registry);
      final source = find.byKey(const ValueKey('luotopia.timetable/card'));
      final seat = find.byKey(const ValueKey('luotopia.seat-reservation/card'));
      final library = find.byKey(const ValueKey('luotopia.library/card'));
      final sourcePosition = tester.getCenter(source);
      final seatPosition = tester.getCenter(seat);
      final libraryPosition = tester.getCenter(library);
      final gap = Offset(
        (tester.getRect(seat).right + tester.getRect(library).left) / 2,
        seatPosition.dy,
      );
      final original = registry
          .entries(ContributionSlot.campusCard)
          .map((entry) => entry.key)
          .toList();
      final before = registry.revision;
      final gesture = await tester.startGesture(sourcePosition);
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(gap);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getCenter(seat), sourcePosition);
      expect(tester.getCenter(library), libraryPosition);
      expect(registry.revision, before);
      expect(
        registry.entries(ContributionSlot.campusCard).map((entry) => entry.key),
        original,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(registry.revision, before + 1);
      expect(
        registry.entries(ContributionSlot.campusCard).map((entry) => entry.key),
        [
          'luotopia.seat-reservation/card',
          'luotopia.timetable/card',
          'luotopia.library/card',
          'luotopia.sports-reservation/card',
        ],
      );
      expect(tester.getCenter(source), seatPosition);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('canceling a gap preview restores layout without saving', (
    tester,
  ) async {
    final registry = await manager();
    await pump(tester, registry);
    final source = find.byKey(const ValueKey('luotopia.timetable/card'));
    final seat = find.byKey(const ValueKey('luotopia.seat-reservation/card'));
    final library = find.byKey(const ValueKey('luotopia.library/card'));
    final sourcePosition = tester.getCenter(source);
    final seatPosition = tester.getCenter(seat);
    final gap = Offset(
      (tester.getRect(seat).right + tester.getRect(library).left) / 2,
      seatPosition.dy,
    );
    final original = registry
        .entries(ContributionSlot.campusCard)
        .map((entry) => entry.key)
        .toList();
    final before = registry.revision;
    final gesture = await tester.startGesture(sourcePosition);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(gap);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getCenter(seat), sourcePosition);
    expect(registry.revision, before);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(tester.getCenter(source), sourcePosition);
    expect(tester.getCenter(seat), seatPosition);
    expect(registry.revision, before);
    expect(
      registry.entries(ContributionSlot.campusCard).map((entry) => entry.key),
      original,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('wide card moves between rows with matching preview and commit', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final registry = await manager();
    await registry.setContributionVisible('luotopia.campus-info/card', true);
    final original = [
      'luotopia.campus-info/card',
      'luotopia.timetable/card',
      'luotopia.seat-reservation/card',
      'luotopia.library/card',
      'luotopia.sports-reservation/card',
    ];
    await registry.reorder(ContributionSlot.campusCard, original);
    await pump(tester, registry);
    final wide = find.byKey(const ValueKey('luotopia.campus-info/card'));
    final first = find.byKey(const ValueKey('luotopia.timetable/card'));
    final last = find.byKey(const ValueKey('luotopia.sports-reservation/card'));
    final wideRect = tester.getRect(wide);
    final rowRect = tester.getRect(first);
    final before = registry.revision;
    expect(tester.getRect(last).bottom, lessThan(1400));
    final gesture = await tester.startGesture(wideRect.center);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(Offset(rowRect.center.dx, rowRect.bottom - 8));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final previewFirst = tester.getRect(first);
    final placeholder = tester.getRect(
      find.byKey(const ValueKey('moving-luotopia.campus-info/card')),
    );
    expect(previewFirst.top, wideRect.top);
    expect(placeholder.top, greaterThan(previewFirst.bottom));
    expect(placeholder.bottom, lessThan(tester.getRect(last).top));
    expect(registry.revision, before);
    expect(
      registry.entries(ContributionSlot.campusCard).map((entry) => entry.key),
      original,
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(registry.revision, before + 1);
    expect(
      registry.entries(ContributionSlot.campusCard).map((entry) => entry.key),
      [
        'luotopia.timetable/card',
        'luotopia.seat-reservation/card',
        'luotopia.library/card',
        'luotopia.campus-info/card',
        'luotopia.sports-reservation/card',
      ],
    );
    expect(tester.getRect(first).top, previewFirst.top);
    expect(tester.getRect(wide), placeholder);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small cards fill the row preceding a wide card', (tester) async {
    final registry = await manager();
    await registry.setContributionVisible('luotopia.campus-info/card', true);
    final order = registry
        .entries(ContributionSlot.campusCard)
        .map((c) => c.key)
        .toList();
    order.remove('luotopia.campus-info/card');
    order.insert(1, 'luotopia.campus-info/card');
    await registry.reorder(ContributionSlot.campusCard, order);
    await pump(tester, registry);
    final classes = tester.getRect(
      find.byKey(const ValueKey('luotopia.timetable/card')),
    );
    final sports = tester.getRect(
      find.byKey(const ValueKey('luotopia.library/card')),
    );
    final library = tester.getRect(
      find.byKey(const ValueKey('luotopia.campus-info/card')),
    );
    expect(sports.top, classes.top);
    expect(library.top, greaterThan(classes.bottom));
    expect(tester.takeException(), isNull);
  });
}
