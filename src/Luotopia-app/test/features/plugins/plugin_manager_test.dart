import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/plugin_package.dart';
import 'package:luotopia/features/plugins/data/plugin_store.dart';
import 'package:luotopia/features/plugins/domain/plugin_error.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'plugin_manifest_test.dart' show exampleManifest, pluginError;

PluginPackage package({
  String version = '1.0.0',
  void Function(Map<String, dynamic>)? change,
}) {
  final manifest = exampleManifest()..['version'] = version;
  change?.call(manifest);
  return PluginPackage(
    PluginManifest.fromJson(manifest),
    'globalThis.luotopiaPlugin = {};',
    'MIT',
    'digest-$version',
  );
}

Future<void> install(
  PluginManager manager,
  PluginPackage value, {
  bool update = false,
  bool reuseData = false,
}) => manager.install(
  value,
  approvedPermissions: {'storage.self'},
  validate: (_) async {},
  update: update,
  reuseData: reuseData,
);
List<String> navigation(PluginManager manager) =>
    manager.entries(ContributionSlot.navigation).map((c) => c.key).toList();

class FailingStore extends PluginStore {
  FailingStore(super.directory);
  bool failNext = false;
  @override
  Future<void> write(Map<String, dynamic> state) async {
    if (failNext) {
      failNext = false;
      throw const PluginException(
        'PERSISTENCE_FAILED',
        'injected write failure',
      );
    }
    await super.write(state);
  }
}

void main() {
  test(
    'settings ordering protects core positions and original groups',
    () async {
      final manager = PluginManager();
      addTearDown(manager.dispose);
      final original = manager
          .entries(ContributionSlot.settingsRow)
          .map((c) => c.key)
          .toList();
      List<String> swapped(String a, String b) {
        final next = [...original];
        final first = next.indexOf(a), second = next.indexOf(b);
        next[first] = b;
        next[second] = a;
        return next;
      }

      await expectLater(
        manager.reorder(
          ContributionSlot.settingsRow,
          swapped('luotopia.settings/general', 'luotopia.home-settings/row'),
        ),
        throwsA(pluginError('CORE_PLUGIN_LOCKED')),
      );
      await expectLater(
        manager.reorder(
          ContributionSlot.settingsRow,
          swapped('luotopia.home-settings/row', 'luotopia.placeholder-1/row'),
        ),
        throwsA(pluginError('INVALID_INPUT')),
      );
      final valid = swapped(
        'luotopia.home-settings/row',
        'luotopia.ai-settings/row',
      );
      await manager.reorder(ContributionSlot.settingsRow, valid);
      expect(
        manager.entries(ContributionSlot.settingsRow).map((c) => c.key),
        valid,
      );
      final backup = manager.exportBackup();
      ((backup['layout'] as Map)['order'] as Map)['settingsRow'] = original
          .reversed
          .toList();
      await manager.restoreBackup(backup);
      final restored = manager
          .entries(ContributionSlot.settingsRow)
          .map((c) => c.key)
          .toList();
      for (final key in [
        'luotopia.settings/accounts',
        'luotopia.settings/general',
        'luotopia.settings/data',
      ]) {
        expect(restored.indexOf(key), original.indexOf(key));
      }
      expect(
        restored.indexOf('luotopia.notification/row'),
        original.indexOf('luotopia.notification/row'),
      );
    },
  );
  late Directory temporary;
  late FailingStore store;
  late PluginManager manager;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('luotopia-manager-');
    store = FailingStore(temporary);
    manager = PluginManager(store: store);
  });
  tearDown(() async {
    manager.dispose();
    await temporary.delete(recursive: true);
  });

  test(
    'core plugins and entries cannot be disabled, removed or modified',
    () async {
      final before = navigation(manager);
      for (final id in [
        'luotopia.home',
        'luotopia.campus',
        'luotopia.settings',
      ]) {
        await expectLater(
          manager.setEnabled(id, false),
          throwsA(pluginError('CORE_PLUGIN_LOCKED')),
        );
        await expectLater(
          manager.uninstall(id),
          throwsA(pluginError('CORE_PLUGIN_LOCKED')),
        );
        for (final contribution in manager.details(id).contributions) {
          await expectLater(
            manager.setContributionVisible(contribution.key, false),
            throwsA(pluginError('CORE_PLUGIN_LOCKED')),
          );
          await expectLater(
            manager.updatePresentation(contribution.key, {'title': 'changed'}),
            throwsA(pluginError('CORE_PLUGIN_LOCKED')),
          );
        }
      }
      expect(navigation(manager), before);
      expect(manager.revision, 0);
    },
  );

  test(
    'optional removal restores its remembered order and legacy AI defaults',
    () async {
      final ai = PluginManager(legacyAi: true);
      addTearDown(ai.dispose);
      expect(navigation(ai), [
        'luotopia.home/tab',
        'luotopia.list/tab',
        'luotopia.ai/tab',
        'luotopia.campus/tab',
        'luotopia.settings/tab',
      ]);
      final order = [
        'luotopia.home/tab',
        'luotopia.forum/tab',
        'luotopia.list/tab',
        'luotopia.campus/tab',
        'luotopia.settings/tab',
      ];
      await manager.reorder(ContributionSlot.navigation, order);
      await manager.uninstall('luotopia.forum');
      expect(
        navigation(manager),
        order.where((key) => key != 'luotopia.forum/tab'),
      );
      expect(manager.redirectNative('/forum/topic'), '/');
      await manager.restoreBuiltin('luotopia.forum');
      expect(navigation(manager), order);
      expect(manager.redirectNative('/forum/topic'), isNull);
      final reloaded = PluginManager(store: store);
      addTearDown(reloaded.dispose);
      await reloaded.load();
      expect(navigation(reloaded), order);
    },
  );

  test(
    'reordering rejects stale revisions, incomplete, duplicate and unknown entries',
    () async {
      final order = navigation(manager);
      await manager.setContributionVisible('luotopia.forum/tab', true);
      await expectLater(
        manager.reorder(
          ContributionSlot.navigation,
          order,
          expectedRevision: 0,
        ),
        throwsA(pluginError('REVISION_CONFLICT')),
      );
      for (final invalid in [
        order.sublist(1),
        [...order, order.first],
        [...order.take(order.length - 1), 'unknown/tab'],
      ]) {
        await expectLater(
          manager.reorder(ContributionSlot.navigation, invalid),
          throwsA(pluginError('INVALID_INPUT')),
        );
      }
      await expectLater(
        manager.reorder(ContributionSlot.navigation, order.reversed.toList()),
        throwsA(pluginError('CORE_PLUGIN_LOCKED')),
      );
      expect(navigation(manager), order);
      expect(manager.revision, 1);
    },
  );

  test(
    'failed validation and stale installation preserve the installed version and data',
    () async {
      await install(manager, package());
      await manager.storageWrite(
        'org.example.study-time',
        'minutes',
        75,
        expectedGeneration: manager.generation('org.example.study-time'),
      );
      final before = await store.read();
      await expectLater(
        manager.install(
          package(version: '2.0.0'),
          approvedPermissions: {'storage.self'},
          update: true,
          validate: (_) async {
            throw const PluginException('SCRIPT_ERROR', 'trial failed');
          },
        ),
        throwsA(pluginError('SCRIPT_ERROR')),
      );
      expect(await store.read(), before);
      expect(
        manager.details('org.example.study-time').manifest!.version,
        '1.0.0',
      );
      expect(manager.storageGet('org.example.study-time', 'minutes'), 75);
      await expectLater(
        manager.install(
          package(version: '2.0.0'),
          approvedPermissions: {'storage.self'},
          update: true,
          validate: (_) async {
            await manager.updatePresentation('luotopia.list/tab', {
              'title': '清单新名',
            });
          },
        ),
        throwsA(pluginError('REVISION_CONFLICT')),
      );
      expect(
        manager.details('org.example.study-time').manifest!.version,
        '1.0.0',
      );
    },
  );

  test('same ID requires an explicit higher compatible update', () async {
    await install(manager, package());
    await manager.updateConfig('org.example.study-time', {
      'targetMinutes': 240,
    });
    for (final version in ['1.0.0', '0.9.9']) {
      await expectLater(
        install(manager, package(version: version), update: true),
        throwsA(pluginError('UPDATE_FAILED')),
      );
    }
    await expectLater(
      install(manager, package(version: '2.0.0')),
      throwsA(pluginError('UPDATE_FAILED')),
    );
    await expectLater(
      install(
        manager,
        package(
          version: '2.0.0',
          change: (m) => (m['config'] as List).first['max'] = 3000,
        ),
        update: true,
      ),
      throwsA(pluginError('UPDATE_FAILED')),
    );
    await install(manager, package(version: '1.0.1'), update: true);
    expect(manager.configuration('org.example.study-time'), {
      'targetMinutes': 240,
    });
    expect(
      manager.details('org.example.study-time').manifest!.version,
      '1.0.1',
    );
  });

  test(
    'uninstall seals data until explicit reimport confirmation and isolates namespaces',
    () async {
      const id = 'org.example.study-time';
      await install(manager, package());
      await manager.storageWrite(
        id,
        'minutes',
        75,
        expectedGeneration: manager.generation(id),
      );
      await manager.uninstall(id);
      expect(manager.hasRetainedData(id), isTrue);
      expect(manager.storageGet(id, 'minutes'), isNull);
      expect(manager.exportData()[id], {'minutes': 75});
      await install(manager, package());
      expect(manager.storageGet(id, 'minutes'), isNull);
      await manager.uninstall(id);
      await install(manager, package(), reuseData: true);
      expect(manager.storageGet(id, 'minutes'), 75);
      expect(manager.storageGet('org.other.plugin', 'minutes'), isNull);
      await manager.uninstall(id, deleteData: true);
      expect(manager.hasRetainedData(id), isFalse);
      expect(manager.exportData().containsKey(id), isFalse);
      await manager.restoreData({
        id: {'minutes': 90},
      });
      expect(manager.storageGet(id, 'minutes'), isNull);
      await install(manager, package(), reuseData: true);
      expect(manager.storageGet(id, 'minutes'), 90);
    },
  );

  test(
    'failed atomic persistence leaves memory and disk unchanged and subsequent writes work',
    () async {
      await manager.updatePresentation('luotopia.list/tab', {'title': 'saved'});
      final before = await store.read();
      final revision = manager.revision;
      store.failNext = true;
      await expectLater(
        manager.updatePresentation('luotopia.list/tab', {
          'title': 'must not commit',
        }),
        throwsA(pluginError('PERSISTENCE_FAILED')),
      );
      expect(manager.contribution('luotopia.list/tab').title, 'saved');
      expect(manager.revision, revision);
      expect(await store.read(), before);
      await manager.updatePresentation('luotopia.list/tab', {'title': 'next'});
      expect(manager.contribution('luotopia.list/tab').title, 'next');
      expect(manager.revision, revision + 1);
    },
  );

  test(
    'store recovers the last committed snapshot and ignores interrupted staging',
    () async {
      await store.write({'schema': 1, 'revision': 1});
      await store.write({'schema': 1, 'revision': 2});
      await File('${temporary.path}/state.json').writeAsString('{broken');
      await File(
        '${temporary.path}/state.pending.json',
      ).writeAsString(jsonEncode({'schema': 1, 'revision': 999}));
      expect(await store.read(), {'schema': 1, 'revision': 1});
      expect(
        await File('${temporary.path}/state.json').readAsString(),
        '{broken',
      );
    },
  );
}
