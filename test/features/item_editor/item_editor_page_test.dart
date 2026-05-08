import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/core/localization/generated/app_localizations.dart';
import 'package:luotopia/core/localization/shadcn_localizations_fallback_delegate.dart';
import 'package:luotopia/features/pages/item_editor/presentation/pages/item_editor_page.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

void main() {
  testWidgets('切换到备忘后显示目标日期与预计时长字段', (tester) async {
    await tester.pumpWidget(const _TestApp(child: ItemEditorPage()));
    await tester.pumpAndSettle();

    expect(find.text('截止时间'), findsOneWidget);
    expect(find.text('目标日期'), findsNothing);

    await tester.tap(find.text('任务'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('备忘'));
    await tester.pumpAndSettle();

    expect(find.text('目标日期'), findsOneWidget);
    expect(find.text('预计完成时长'), findsOneWidget);
    expect(find.text('截止时间'), findsNothing);
  });

  testWidgets('正文单行表单项行高统一且详情输入更高', (tester) async {
    await tester.pumpWidget(const _TestApp(child: ItemEditorPage()));
    await tester.pumpAndSettle();

    final titleSize = tester.getSize(find.byKey(const ValueKey('item-editor-field-title')));
    final allDaySize = tester.getSize(find.byKey(const ValueKey('item-editor-row-all-day')));
    final startSize = tester.getSize(find.byKey(const ValueKey('item-editor-row-start')));
    final detailsSize = tester.getSize(find.byKey(const ValueKey('item-editor-field-details')));

    expect(titleSize.height, 56);
    expect(allDaySize.height, 56);
    expect(startSize.height, 56);
    expect(detailsSize.height, greaterThan(titleSize.height));
  });

  testWidgets('操作行左右内容分离并保持纵向居中', (tester) async {
    await tester.pumpWidget(const _TestApp(child: ItemEditorPage()));
    await tester.pumpAndSettle();

    final startRow = find.byKey(const ValueKey('item-editor-row-start'));
    final label = find.byKey(const ValueKey('item-editor-row-start-label'));
    final trailingGroup = find.byKey(const ValueKey('item-editor-row-start-trailing-group'));
    final value = find.byKey(const ValueKey('item-editor-row-start-value'));
    final chevron = find.byKey(const ValueKey('item-editor-row-start-chevron'));

    final rowRect = tester.getRect(startRow);
    final trailingGroupRect = tester.getRect(trailingGroup);
    final labelCenter = tester.getCenter(label);
    final valueCenter = tester.getCenter(value);
    final chevronCenter = tester.getCenter(chevron);

    expect(labelCenter.dx, lessThan(valueCenter.dx));
    expect(valueCenter.dx, lessThan(chevronCenter.dx));
    expect((rowRect.right - trailingGroupRect.right).abs(), lessThanOrEqualTo(1));
    expect((labelCenter.dy - rowRect.center.dy).abs(), lessThanOrEqualTo(1));
    expect((valueCenter.dy - rowRect.center.dy).abs(), lessThanOrEqualTo(1));
    expect((chevronCenter.dy - rowRect.center.dy).abs(), lessThanOrEqualTo(1));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ui.ShadcnApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ShadcnFallbackLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Material(
          child: ResponsiveBreakpoints.builder(
            breakpoints: const [
              Breakpoint(start: 0, end: 599, name: MOBILE),
              Breakpoint(start: 600, end: 1023, name: TABLET),
              Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
            ],
            child: child,
          ),
        ),
      ),
    );
  }
}
