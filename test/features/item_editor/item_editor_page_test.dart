import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huajuan_agenda/core/localization/generated/app_localizations.dart';
import 'package:huajuan_agenda/core/localization/shadcn_localizations_fallback_delegate.dart';
import 'package:huajuan_agenda/features/item_editor/presentation/pages/item_editor_page.dart';
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
