import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huajuan_agenda/app/app.dart';

void main() {
  testWidgets('app shell renders primary navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HuaJuanAgendaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('主页'), findsWidgets);
    expect(find.text('列表'), findsWidgets);
    expect(find.text('AI'), findsWidgets);
    expect(find.text('添加'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
  });
}
