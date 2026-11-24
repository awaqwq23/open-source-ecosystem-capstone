import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/plugin_package.dart';
import 'package:luotopia/features/plugins/presentation/plugin_labels.dart';
import 'package:luotopia/features/plugins/presentation/plugin_market_page.dart';

void main() {
  test('personal timetable permission is clearly disclosed', () {
    expect(pluginPermissionLabel('schoolTimetable.read'), contains('个人课表'));
    expect(
      pluginPermissionLabel('schoolTimetable.read'),
      isNot(contains('HTTPS')),
    );
  });
  testWidgets(
    'offline catalogue returns the real bundled package for approval',
    (tester) async {
      PluginPackage? selected;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pluginManagerProvider.overrideWith((_) => PluginManager()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    selected = await Navigator.of(context).push<PluginPackage>(
                      MaterialPageRoute(
                        builder: (_) => const PluginMarketPage(),
                      ),
                    );
                  },
                  child: const Text('打开市场'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开市场'));
      await tester.pumpAndSettle();
      expect(find.text('学习时长统计'), findsOneWidget);
      expect(find.textContaining('离线可安装'), findsNWidgets(2));
      expect(find.text('我的教务课表'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.tap(find.text('预览并授权安装').first);
      await tester.pumpAndSettle();
      expect(selected?.manifest.id, 'org.example.study-time');
      expect(selected?.manifest.version, '1.0.0');
      expect(selected?.digest, matches(RegExp(r'^[a-f0-9]{64}$')));
      expect(find.text('打开市场'), findsOneWidget);
    },
  );
  testWidgets('matching installed package offers no failing update', (
    tester,
  ) async {
    final bytes = await rootBundle.load(
      'assets/market/study-time-1.0.0.luoplugin',
    );
    final package = PluginPackage.decode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    final manager = PluginManager();
    await manager.install(
      package,
      approvedPermissions: {},
      validate: (_) async {},
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pluginManagerProvider.overrideWith((_) => manager)],
        child: const MaterialApp(home: PluginMarketPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('已安装'), findsOneWidget);
    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, '已安装'),
    );
    expect(button.onPressed, isNull);
    expect(find.text('预览并授权安装'), findsOneWidget);
  });
}
