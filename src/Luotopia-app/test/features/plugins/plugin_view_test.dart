import 'dart:async';
import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:luotopia/features/plugins/domain/plugin_error.dart';
import 'package:luotopia/features/plugins/domain/plugin_view.dart';
import 'package:luotopia/features/plugins/presentation/plugin_view_content.dart';

Map<String, dynamic> form() => {
  'title': '统计',
  'nodes': [
    {
      'type': 'input',
      'id': 'minutes',
      'label': '分钟',
      'value': '',
      'maxLength': 50,
    },
    {
      'type': 'number',
      'id': 'goal',
      'label': '目标',
      'value': 120,
      'min': 1,
      'max': 1440,
    },
    {'type': 'toggle', 'id': 'show', 'label': '显示', 'value': true},
    {
      'type': 'select',
      'id': 'unit',
      'label': '单位',
      'value': 'm',
      'options': [
        {'value': 'm', 'label': '分钟'},
      ],
    },
    {'type': 'button', 'id': 'calculate', 'label': '计算', 'actionId': 'sum'},
    {'type': 'text', 'id': 'hint', 'text': '输入学习时长'},
    {
      'type': 'list',
      'id': 'history',
      'items': [
        {'id': 'first', 'title': '历史', 'subtitle': '尚无记录'},
      ],
    },
  ],
};
Matcher error(String code) =>
    isA<PluginException>().having((e) => e.code, 'code', code);

void main() {
  test('all form values are checked, including missing and foreign fields', () {
    final view = PluginView.fromJson(form());
    final input = {'minutes': '30,45', 'goal': 120, 'show': false, 'unit': 'm'};
    expect(view.validateAction('sum', input), input);
    for (final invalid in [
      <String, dynamic>{},
      {...input, 'goal': double.nan},
      {...input, 'unit': 'hours'},
      {...input, 'secret': 'x'},
    ]) {
      expect(
        () => view.validateAction('sum', invalid),
        throwsA(error('INVALID_INPUT')),
      );
    }
  });
  test(
    'unknown fields, duplicate ids, malformed values and hostile JSON are rejected',
    () {
      for (final node in [
        {'type': 'text', 'id': 'x', 'text': 'hi', 'route': '/settings'},
        {
          'type': 'number',
          'id': 'x',
          'label': 'n',
          'value': double.infinity,
          'min': 0,
          'max': 9,
        },
        {'type': 'text', 'id': '', 'text': 'hi'},
        {
          'type': 'list',
          'id': 'x',
          'items': [
            {'id': 'a', 'title': 'a'},
            {'id': 'a', 'title': 'b'},
          ],
        },
      ]) {
        expect(
          () => PluginView.fromJson({
            'title': 'x',
            'nodes': [node],
          }),
          throwsA(error('INVALID_VIEW')),
        );
      }
      final duplicate = form();
      (duplicate['nodes'] as List).add((duplicate['nodes'] as List).first);
      expect(
        () => PluginView.fromJson(duplicate),
        throwsA(error('INVALID_VIEW')),
      );
      final cyclic = <String, dynamic>{};
      cyclic['self'] = cyclic;
      expect(
        () => PluginResult.fromJson({'state': cyclic, 'view': form()}),
        throwsA(error('INVALID_VIEW')),
      );
      expect(
        () => PluginResult.fromJson({'state': () {}, 'view': form()}),
        throwsA(error('INVALID_VIEW')),
      );
      expect(
        () => PluginResult.fromJson({'state': 'x' * 65536, 'view': form()}),
        throwsA(error('INVALID_VIEW')),
      );
      Object? deep;
      for (var i = 0; i < 17; i++) {
        deep = [deep];
      }
      expect(
        () => PluginResult.fromJson({'state': deep, 'view': form()}),
        throwsA(error('INVALID_VIEW')),
      );
      expect(
        PluginResult.fromJson({'state': null, 'view': form()}).view.title,
        '统计',
      );
    },
  );
  test('total payload, node and list count limits are enforced', () {
    final large = {
      'title': 'large',
      'nodes': [
        for (var i = 0; i < 70; i++)
          {'type': 'text', 'id': 'n$i', 'text': 'x' * 4096},
      ],
    };
    expect(
      () => PluginResult.fromJson({'state': null, 'view': large}),
      throwsA(error('INVALID_VIEW')),
    );
    expect(
      () => PluginView.fromJson({
        'title': 'x',
        'nodes': [
          for (var i = 0; i < 101; i++)
            {'type': 'text', 'id': 'n$i', 'text': ''},
        ],
      }),
      throwsA(error('INVALID_VIEW')),
    );
    expect(
      () => PluginView.fromJson({
        'title': 'x',
        'nodes': [
          {
            'type': 'list',
            'id': 'list',
            'items': [
              for (var i = 0; i < 201; i++) {'id': 'n$i', 'title': 'row'},
            ],
          },
        ],
      }),
      throwsA(error('INVALID_VIEW')),
    );
  });
  testWidgets(
    'editable values reach action once and async errors appear inline',
    (tester) async {
      var calls = 0;
      Map<String, dynamic>? submitted;
      final pending = Completer<void>();
      await tester.pumpWidget(
        ui.ShadcnApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: material.SingleChildScrollView(
            child: PluginViewContent(
              view: PluginView.fromJson(form()),
              onAction: (action, input) {
                calls++;
                submitted = input;
                return pending.future;
              },
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const material.ValueKey('plugin-field-minutes')),
        '30,45',
      );
      await tester.tap(find.text('计算'));
      await tester.pump();
      await tester.tap(find.text('计算'));
      expect(calls, 1);
      expect(submitted?['minutes'], '30,45');
      pending.completeError(const PluginException('SCRIPT_ERROR', '计算失败'));
      await tester.pumpAndSettle();
      expect(find.text('计算失败'), findsOneWidget);
      expect(find.text('30,45'), findsOneWidget);
    },
  );
}
