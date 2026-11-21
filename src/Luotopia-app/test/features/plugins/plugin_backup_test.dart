import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/plugin_package.dart';
import 'package:luotopia/features/plugins/domain/plugin_error.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/export/local_database_backup_service.dart';
import 'package:luotopia/shared/data/sync/sync_cursor_store.dart';
import 'plugin_manifest_test.dart' show exampleManifest, pluginError;

const _id = 'org.example.study-time';
PluginPackage _package({String id = _id}) => PluginPackage(
  PluginManifest.fromJson(exampleManifest()..['id'] = id),
  'globalThis.luotopiaPlugin = {};',
  'MIT',
  'a' * 64,
);
Future<void> _install(
  PluginManager manager, {
  bool reuseData = false,
  String id = _id,
}) => manager.install(
  _package(id: id),
  approvedPermissions: {'storage.self'},
  validate: (_) async {},
  reuseData: reuseData,
);
Map<String, dynamic> _copy(Map<String, dynamic> value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

void main() {
  test('sealed configuration survives repeated backup and restore', () async {
    final original = PluginManager();
    final intermediate = PluginManager();
    final restored = PluginManager();
    addTearDown(original.dispose);
    addTearDown(intermediate.dispose);
    addTearDown(restored.dispose);
    await _install(original);
    await original.updateConfig(_id, {'targetMinutes': 240});
    await intermediate.restoreBackup(original.exportBackup());
    await restored.restoreBackup(intermediate.exportBackup());
    await _install(restored, reuseData: true);
    expect(restored.configuration(_id), {'targetMinutes': 240});
  });
  test(
    'retained namespaces share the backup capacity and explicit deletion frees it',
    () async {
      final manager = PluginManager();
      for (var i = 0; i < 16; i++) {
        final id = 'org.example.plugin$i';
        await _install(manager, id: id);
        await manager.uninstall(id);
      }
      expect(
        () => PluginManager.validateBackup(manager.exportBackup()),
        returnsNormally,
      );
      await expectLater(
        _install(manager, id: 'org.example.plugin16'),
        throwsA(pluginError('RESOURCE_LIMIT_EXCEEDED')),
      );
      await manager.forgetRetainedData('org.example.plugin0');
      await _install(manager, id: 'org.example.plugin16');
      await manager.uninstall('org.example.plugin16', deleteData: true);
      await _install(manager, id: 'org.example.plugin17');
      expect(
        () => PluginManager.validateBackup(manager.exportBackup()),
        returnsNormally,
      );
      manager.dispose();
    },
  );
  test(
    'restoring an installed ID withdraws old code and never overwrites the restored snapshot on uninstall',
    () async {
      final manager = PluginManager();
      await _install(manager);
      await manager.storageWrite(
        _id,
        'minutes',
        75,
        expectedGeneration: manager.generation(_id),
      );
      final backup = manager.exportBackup();
      (backup['data'] as Map)[_id] = {'minutes': 90};
      await manager.restoreBackup(backup);
      expect(manager.list().any((p) => p.id == _id), isFalse);
      expect(manager.storageGet(_id, 'minutes'), isNull);
      await _install(manager);
      await manager.uninstall(_id);
      await _install(manager, reuseData: true);
      expect(manager.storageGet(_id, 'minutes'), 90);
      manager.dispose();
    },
  );
  TestWidgetsFlutterBinding.ensureInitialized();
  late PluginManager source;
  setUp(() {
    source = PluginManager();
  });
  tearDown(() => source.dispose());
  Future<Map<String, dynamic>> populated() async {
    await _install(source);
    await source.updateConfig(_id, {'targetMinutes': 240});
    await source.updatePresentation('$_id/card', {
      'title': 'Study log',
      'icon': 'book',
    });
    await source.setContributionVisible('luotopia.library/card', false);
    await source.storageWrite(
      _id,
      'minutes',
      75,
      expectedGeneration: source.generation(_id),
    );
    return source.exportBackup();
  }

  test(
    'backup contains layout/config/package identity/storage without executable code or grants',
    () async {
      final backup = await populated();
      expect((backup['layout'] as Map)['config'], {
        _id: {'targetMinutes': 240},
      });
      expect(
        (backup['layout'] as Map)['hidden'],
        contains('luotopia.library/card'),
      );
      expect(((backup['layout'] as Map)['presentation'] as Map)['$_id/card'], {
        'title': 'Study log',
        'icon': 'book',
      });
      expect(backup['packages'], {
        _id: {
          'id': _id,
          'name': '学习统计',
          'version': '1.0.0',
          'digest': 'a' * 64,
        },
      });
      expect(backup['data'], {
        _id: {'minutes': 75},
      });
      final encoded = jsonEncode(backup);
      for (final forbidden in [
        'script',
        'globalThis',
        'permissions',
        'approvedPermissions',
        'grants',
      ]) {
        expect(encoded, isNot(contains(forbidden)));
      }
      PluginManager.validateBackup(backup);
    },
  );
  test(
    'restore seals data/config and missing packages until explicit same-ID reimport reuse',
    () async {
      final backup = await populated();
      final restored = PluginManager();
      addTearDown(restored.dispose);
      await restored.restoreBackup(backup);
      expect(restored.pendingImports, [_id]);
      expect(
        restored.list().where((p) => p.source == PluginSource.external),
        isEmpty,
      );
      expect(restored.storageGet(_id, 'minutes'), isNull);
      expect(restored.hasRetainedData(_id), isTrue);
      expect(restored.retainedDigest(_id), 'a' * 64);
      await _install(restored, id: 'org.other.stats', reuseData: true);
      expect(restored.storageGet('org.other.stats', 'minutes'), isNull);
      expect(restored.hasRetainedData(_id), isTrue);
      await _install(restored);
      expect(restored.storageGet(_id, 'minutes'), isNull);
      expect(restored.configuration(_id), {'targetMinutes': 120});
      await restored.uninstall(_id);
      await _install(restored, reuseData: true);
      expect(restored.storageGet(_id, 'minutes'), 75);
      expect(restored.configuration(_id), {'targetMinutes': 240});
      expect(restored.hasRetainedData(_id), isFalse);
    },
  );
  test('malicious backup cannot change a core title or icon', () async {
    final backup = source.exportBackup();
    (backup['layout'] as Map)['presentation'] = {
      'luotopia.home/tab': {'title': 'forged', 'icon': 'code'},
    };
    final before = source.contribution('luotopia.home/tab');
    try {
      await source.restoreBackup(backup);
    } on PluginException {
      /* rejecting the whole backup is also safe */
    }
    final after = source.contribution('luotopia.home/tab');
    expect(after.title, before.title);
    expect(after.icon, before.icon);
  });
  test(
    'unknown permission/code fields in backups are rejected atomically',
    () async {
      final valid = await populated();
      for (final key in ['script', 'permissions', 'grants']) {
        for (final packageField in [false, true]) {
          final backup = _copy(valid);
          if (packageField) {
            ((backup['packages'] as Map)[_id] as Map)[key] = 'untrusted';
          } else {
            backup[key] = 'untrusted';
          }
          final restored = PluginManager();
          addTearDown(restored.dispose);
          await expectLater(
            restored.restoreBackup(backup),
            throwsA(pluginError('INVALID_INPUT')),
          );
          expect(restored.revision, 0);
          expect(restored.hasRetainedData(_id), isFalse);
        }
      }
    },
  );
  test(
    'storage namespace, key, size and package identity/digest are validated before restore',
    () async {
      final valid = await populated();
      final bad = <Map<String, dynamic>>[];
      for (final id in ['luotopia.home', '../escape', 'a' * 97]) {
        bad.add(
          _copy(valid)
            ..['data'] = {
              id: {'minutes': 75},
            },
        );
      }
      for (final key in ['../escape', '', 'a' * 129]) {
        bad.add(
          _copy(valid)
            ..['data'] = {
              _id: {key: 75},
            },
        );
      }
      bad.add(
        _copy(valid)
          ..['data'] = {
            _id: {'large': 'x' * (1024 * 1024)},
          },
      );
      for (final patch in [
        {'id': 'org.other.plugin'},
        {'digest': 'invalid'},
      ]) {
        final backup = _copy(valid);
        ((backup['packages'] as Map)[_id] as Map).addAll(patch);
        bad.add(backup);
      }
      for (final backup in bad) {
        final restored = PluginManager();
        addTearDown(restored.dispose);
        await expectLater(
          restored.restoreBackup(backup),
          throwsA(pluginError('INVALID_INPUT')),
        );
        expect(restored.revision, 0);
      }
    },
  );
  test(
    'restore defaults restores every builtin except AI and hides installed external entries',
    () async {
      await populated();
      await source.uninstall('luotopia.forum');
      await source.setEnabled('luotopia.timetable', false);
      await source.setContributionVisible('luotopia.ai/tab', true);
      await source.restoreDefaultLayout();
      final defaults = PluginManager();
      addTearDown(defaults.dispose);
      for (final slot in ContributionSlot.values) {
        expect(
          source.entries(slot).map((c) => c.key),
          defaults.entries(slot).map((c) => c.key),
        );
      }
      expect(source.details(_id).enabled, isTrue);
      expect(source.configuration(_id), {'targetMinutes': 240});
      expect(source.storageGet(_id, 'minutes'), 75);
      for (final entry in source.details(_id).contributions) {
        expect(source.isVisible(entry.key), isFalse);
      }
    },
  );
  test(
    'SQLite backup v4 carries sealed plugin backup and v3 without plugin table still imports',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'plugin-backup-test-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (call) async =>
                call.method == 'getTemporaryDirectory' ? temporary.path : null,
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final db = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      await populated();
      final service = LocalDatabaseBackupService(
        db: db,
        syncCursorStore: const SyncCursorStore(null),
        preferences: null,
        plugins: source,
      );
      final exported = await service.exportDatabase();
      await db.customStatement("ATTACH DATABASE ? AS inspection", [
        exported.path,
      ]);
      final metadata = await db
          .customSelect(
            "SELECT value FROM inspection._luotopia_backup_metadata WHERE key = 'format_version'",
          )
          .getSingle();
      expect(metadata.data['value'], '4');
      final payload = await db
          .customSelect('SELECT data FROM inspection._luotopia_plugin_data')
          .getSingle();
      expect(jsonDecode(payload.data['data'] as String), source.exportBackup());
      await db.customStatement('DETACH DATABASE inspection');
      final restored = PluginManager();
      addTearDown(restored.dispose);
      await LocalDatabaseBackupService(
        db: db,
        syncCursorStore: const SyncCursorStore(null),
        preferences: null,
        plugins: restored,
      ).importDatabase(exported.path);
      expect(restored.pendingImports, [_id]);
      expect(restored.storageGet(_id, 'minutes'), isNull);
      await db.customStatement('ATTACH DATABASE ? AS legacy', [exported.path]);
      await db.customStatement(
        "UPDATE legacy._luotopia_backup_metadata SET value = '3' WHERE key = 'format_version'",
      );
      await db.customStatement('DROP TABLE legacy._luotopia_plugin_data');
      await db.customStatement('DETACH DATABASE legacy');
      await service.importDatabase(exported.path);
      expect(source.storageGet(_id, 'minutes'), 75);
    },
  );
}
