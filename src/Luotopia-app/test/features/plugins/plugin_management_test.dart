import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/bundled_plugins.dart';
import 'package:luotopia/features/plugins/presentation/plugin_management_page.dart';
import 'package:luotopia/features/plugins/runtime/plugin_engine.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

void main() {
  test('closed and unstarted engines leave no memory readings', () async {
    final engine = PluginEngine();
    expect(await PluginEngine.memoryUsage(), isEmpty);
    engine.close();
    expect(await engine.terminated, isTrue);
    expect(await PluginEngine.memoryUsage(), isEmpty);
  });

  testWidgets('filters every slot and removes position controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pluginManagerProvider.overrideWith((_) => PluginManager())],
        child: const ui.ShadcnApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PluginManagementPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('luotopia.settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('luotopia.campus-info')), findsNothing);
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
    expect(find.byIcon(Icons.arrow_downward), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, '校园卡片'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('luotopia.campus-info')), findsOneWidget);
    expect(find.byKey(const ValueKey('luotopia.settings')), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, '设置行'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('luotopia.settings')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('luotopia.settings')));
    await tester.pumpAndSettle();
    expect(find.textContaining('内存：宿主共享，无法单独统计'), findsWidgets);
    expect(find.text('导航栏 · 设置'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });
  testWidgets('bundled system scripts show QuickJS memory while collapsed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final manager = PluginManager(bundledPackages: await loadBundledPlugins());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pluginManagerProvider.overrideWith((_) => manager)],
        child: const ui.ShadcnApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PluginManagementPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '校园卡片'));
    await tester.pumpAndSettle();
    final tile = find.byKey(const ValueKey('luotopia.library'));
    expect(tile, findsOneWidget);
    expect(
      find.descendant(
        of: tile,
        matching: find.textContaining('QuickJS 内存：当前 0 KiB（未运行）'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: tile, matching: find.textContaining('宿主共享')),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
