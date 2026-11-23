import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/domain/plugin_error.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:luotopia/features/plugins/domain/plugin_view.dart';

Map<String, dynamic> exampleManifest() => {
  'schemaVersion': 1,
  'apiVersion': 1,
  'id': 'org.example.study-time',
  'name': '学习统计',
  'version': '1.0.0',
  'entry': 'main.js',
  'description': '统计分钟数',
  'author': 'Example',
  'license': 'MIT',
  'permissions': ['storage.self'],
  'networkHosts': <String>[],
  'views': ['main', 'preferences'],
  'contributions': [
    {
      'id': 'tab',
      'slot': 'navigation',
      'title': '统计',
      'icon': 'timer',
      'viewId': 'main',
      'allowedViews': ['main'],
    },
    {
      'id': 'card',
      'slot': 'campusCard',
      'title': '统计',
      'icon': 'timer',
      'viewId': 'main',
      'allowedViews': ['main'],
      'size': 'small',
      'color': 'sky',
    },
    {
      'id': 'settings',
      'slot': 'settingsRow',
      'title': '统计设置',
      'icon': 'tune',
      'viewId': 'preferences',
      'allowedViews': ['preferences'],
      'group': 'extensions',
    },
  ],
  'config': [
    {
      'key': 'targetMinutes',
      'type': 'number',
      'label': '目标',
      'default': 120,
      'min': 1,
      'max': 1440,
    },
  ],
};

Matcher pluginError(String code) =>
    isA<PluginException>().having((e) => e.code, 'code', code);

void main() {
  test('read-only school permission coexists with existing permissions', () {
    final manifest = PluginManifest.fromJson({
      ...exampleManifest(),
      'permissions': ['storage.self', 'network.https', 'schoolTimetable.read'],
    });
    expect(manifest.permissions, contains('schoolTimetable.read'));
  });
  test(
    'external package declares three stable entry identities and scoped views',
    () {
      final manifest = PluginManifest.fromJson(exampleManifest());
      expect(manifest.id, 'org.example.study-time');
      expect(manifest.contributions.map((c) => c.slot), [
        ContributionSlot.navigation,
        ContributionSlot.campusCard,
        ContributionSlot.settingsRow,
      ]);
      expect(manifest.contributions.first.key, 'org.example.study-time/tab');
      expect(manifest.contributions.first.allowedViews, ['main']);
      expect(manifest.defaultConfig, {'targetMinutes': 120});
      expect(
        PluginManifest.fromJson(jsonDecode(jsonEncode(manifest.toJson()))).id,
        manifest.id,
      );
    },
  );

  test('external packages cannot claim trusted identity or native entry', () {
    for (final field in ['core', 'nativeBuilder', 'protected', 'route']) {
      expect(
        () => PluginManifest.fromJson({...exampleManifest(), field: true}),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
    }
    expect(
      () => PluginManifest.fromJson({
        ...exampleManifest(),
        'id': 'luotopia.core.home',
      }),
      throwsA(pluginError('RESERVED_ID')),
    );
    final data = exampleManifest();
    (data['contributions'] as List).first['route'] = '/settings';
    expect(
      () => PluginManifest.fromJson(data),
      throwsA(pluginError('INVALID_PACKAGE')),
    );
  });

  test('API, version and namespace checks reject malformed contracts', () {
    expect(
      () => PluginManifest.fromJson({...exampleManifest(), 'apiVersion': 2}),
      throwsA(pluginError('UNSUPPORTED_API')),
    );
    for (final version in ['01.0.0', '1.0', '1.0.0-beta', '1.-1.0']) {
      expect(
        () =>
            PluginManifest.fromJson({...exampleManifest(), 'version': version}),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
    }
    expect(
      () => PluginManifest.fromJson({...exampleManifest(), 'id': '../outside'}),
      throwsA(pluginError('INVALID_PACKAGE')),
    );
  });

  test('contribution cannot use undeclared or duplicate identity or view', () {
    var data = exampleManifest();
    (data['contributions'] as List).first['allowedViews'] = ['preferences'];
    expect(
      () => PluginManifest.fromJson(data),
      throwsA(pluginError('INVALID_PACKAGE')),
    );
    data = exampleManifest();
    (data['contributions'] as List)[1]['id'] = 'tab';
    expect(
      () => PluginManifest.fromJson(data),
      throwsA(pluginError('DUPLICATE_CONTRIBUTION')),
    );
    data = exampleManifest();
    (data['contributions'] as List).first['allowedViews'] = ['main', 'missing'];
    expect(
      () => PluginManifest.fromJson(data),
      throwsA(pluginError('INVALID_PACKAGE')),
    );
  });

  test('network and configuration remain within declared bounds', () {
    expect(
      () => PluginManifest.fromJson({
        ...exampleManifest(),
        'permissions': ['account.cookies'],
      }),
      throwsA(pluginError('INVALID_PACKAGE')),
    );
    expect(
      () => PluginManifest.fromJson({
        ...exampleManifest(),
        'networkHosts': ['example.com'],
      }),
      throwsA(pluginError('INVALID_PACKAGE')),
    );
    final manifest = PluginManifest.fromJson(exampleManifest());
    expect(manifest.validateConfig({'targetMinutes': 240}), {
      'targetMinutes': 240,
    });
    expect(
      () => manifest.validateConfig({'targetMinutes': -1}),
      throwsA(pluginError('INVALID_INPUT')),
    );
    expect(
      () => manifest.validateConfig({'secret': 'unexpected'}),
      throwsA(pluginError('INVALID_INPUT')),
    );
  });

  test('view validates real input/action identities and bounds', () {
    final view = PluginView.fromJson({
      'title': '统计',
      'nodes': [
        {
          'type': 'input',
          'id': 'minutes',
          'label': '分钟',
          'value': '',
          'maxLength': 50,
        },
        {'type': 'button', 'id': 'calculate', 'label': '计算', 'actionId': 'sum'},
      ],
    });
    expect(view.validateAction('sum', {'minutes': '30,45'}), {
      'minutes': '30,45',
    });
    expect(
      () => view.validateAction('other', {'minutes': '30'}),
      throwsA(pluginError('INVALID_INPUT')),
    );
    expect(
      () => view.validateAction('sum', {'minutes': 'x' * 51}),
      throwsA(pluginError('INVALID_INPUT')),
    );
    expect(
      () => view.validateAction('sum', {'minutes': '30', 'token': 'extra'}),
      throwsA(pluginError('INVALID_INPUT')),
    );
    expect(
      () => PluginView.fromJson({
        'title': 'x',
        'nodes': [
          {'type': 'html', 'id': 'html', 'text': '<script>bad()</script>'},
        ],
      }),
      throwsA(pluginError('INVALID_VIEW')),
    );
  });
}
