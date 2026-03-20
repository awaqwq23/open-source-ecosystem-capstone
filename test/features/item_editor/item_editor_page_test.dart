import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huajuan_agenda/core/localization/generated/app_localizations.dart';
import 'package:huajuan_agenda/core/localization/shadcn_localizations_fallback_delegate.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/item_editor/presentation/pages/item_editor_page.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

void main() {
  testWidgets('切换到备忘后显示目标日期与预计时长字段', (tester) async {
    await tester.pumpWidget(const _TestApp(child: ItemEditorPage()));
    await tester.pumpAndSettle();

    expect(find.text('截止时间'), findsOneWidget);
    expect(find.text('目标日期'), findsNothing);

    await tester.tap(find.text('备忘').last);
    await tester.pumpAndSettle();

    expect(find.text('目标日期'), findsAtLeastNWidgets(1));
    expect(find.text('预计完成时长'), findsAtLeastNWidgets(1));
    expect(find.text('截止时间'), findsNothing);
  });

  testWidgets('切换类型后概览卡同步更新', (tester) async {
    await tester.pumpWidget(const _TestApp(child: ItemEditorPage()));
    await tester.pumpAndSettle();

    expect(find.text('当前会优先突出执行区间与截止时间，方便你快速检查是否排得下。'), findsOneWidget);

    await tester.tap(find.text('日程').last);
    await tester.pumpAndSettle();
    expect(find.text('当前会优先突出起止时间和地点，适合安排确定发生的活动。'), findsOneWidget);

    await tester.tap(find.text('备忘').last);
    await tester.pumpAndSettle();
    expect(find.text('当前会优先突出目标日期与预计时长，适合收纳待记住和待完成的信息。'), findsOneWidget);
  });

  testWidgets('清除截止时间后显示未设置文案', (tester) async {
    final startAt = DateTime(2026, 3, 20, 9);
    final endAt = DateTime(2026, 3, 20, 10);
    final deadline = DateTime(2026, 3, 20, 11);

    await tester.pumpWidget(
      _TestApp(
        child: ItemEditorPage(
          prefill: ItemEditorPrefill(
            startAt: startAt,
            endAt: endAt,
            deadline: deadline,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('清除'), findsOneWidget);
    await tester.ensureVisible(find.text('清除'));
    await tester.tap(find.text('清除'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('暂未设置截止时间'));
    expect(find.text('暂未设置截止时间'), findsOneWidget);
    expect(find.text('清除'), findsNothing);
  });

  testWidgets('切换颜色后仍保留选中色指示和底部提交按钮', (tester) async {
    await tester.pumpWidget(const _TestApp(child: ItemEditorPage()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('珊瑚红').last);
    await tester.tap(find.text('珊瑚红').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('selected-color-indicator')), findsOneWidget);
    expect(find.text('创建事项'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

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
