import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/app/app.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: LuotopiaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('compact shell renders page header and bottom navigation', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, const Size(390, 844));

    expect(find.byType(ui.NavigationBar), findsOneWidget);
    expect(find.text('主页'), findsWidgets);
    expect(find.text('列表'), findsWidgets);
    expect(find.text('AI'), findsWidgets);
    expect(find.text('添加'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.textContaining('周'), findsWidgets);
  });

  testWidgets('expanded shell renders navigation rail and content', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, const Size(1280, 900));

    expect(find.byType(ui.NavigationSidebar), findsOneWidget);
    expect(find.text('主页'), findsWidgets);
    expect(find.text('列表'), findsWidgets);
    expect(find.text('AI'), findsWidgets);
    expect(find.text('添加'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.textContaining('/'), findsWidgets);
  });
}
