import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huajuan_agenda/app/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: HuaJuanAgendaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('compact shell renders app bar and bottom navigation', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, const Size(390, 844));

    expect(find.text('主页'), findsWidgets);
    expect(find.text('列表'), findsWidgets);
    expect(find.text('AI'), findsWidgets);
    expect(find.text('添加'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
    expect(find.byIcon(Icons.tune), findsOneWidget);
  });

  testWidgets('expanded shell renders navigation rail and content', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, const Size(1280, 900));

    expect(find.text('主页'), findsWidgets);
    expect(find.text('列表'), findsWidgets);
    expect(find.text('AI'), findsWidgets);
    expect(find.text('添加'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
    expect(find.text('日程总览'), findsOneWidget);
  });
}
