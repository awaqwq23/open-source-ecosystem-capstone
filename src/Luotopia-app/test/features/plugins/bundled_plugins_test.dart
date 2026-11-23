import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/bundled_plugins.dart';
import 'package:luotopia/features/plugins/data/plugin_package.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'plugin_manifest_test.dart' show pluginError;

class _Assets extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage({
        for (final f in Directory(
          'assets/system_plugins',
        ).listSync().whereType<File>())
          f.path.replaceAll(r'\', '/'): [
            {'asset': f.path.replaceAll(r'\', '/')},
          ],
      })!;
    }
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

class _ExtraAssets extends _Assets {
  _ExtraAssets(this.id);
  final String id;
  static const extraPath = 'assets/system_plugins/future-1.0.0.luoplugin';
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      final original =
          const StandardMessageCodec().decodeMessage(await super.load(key))
              as Map;
      return const StandardMessageCodec().encodeMessage({
        ...original,
        extraPath: [
          {'asset': extraPath},
        ],
      })!;
    }
    if (key == extraPath) {
      final manifest =
          jsonDecode(
                File(
                  '../samples/bundled-plugins/library/manifest.json',
                ).readAsStringSync(),
              )
              as Map;
      manifest['id'] = id;
      final archive = Archive();
      for (final entry in <String, String>{
        'manifest.json': jsonEncode(manifest),
        'main.js': 'globalThis.luotopiaPlugin = {};',
        'LICENSE.txt': 'MIT',
      }.entries) {
        final bytes = utf8.encode(entry.value);
        archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
      }
      return ByteData.sublistView(
        Uint8List.fromList(ZipEncoder().encode(archive)),
      );
    }
    return super.load(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'runtime asset manifest discovers system packages without loading market assets',
    () async {
      final packages = await loadBundledPlugins();
      expect(packages.length, 9);
      expect(
        packages.every((p) => p.manifest.id.startsWith('luotopia.')),
        isTrue,
      );
    },
  );
  test(
    'new shipped provider needs no Dart registry entry and cannot replace a core plugin',
    () async {
      final packages = await loadBundledPlugins(
        bundle: _ExtraAssets('luotopia.future'),
      );
      final manager = PluginManager(bundledPackages: packages);
      addTearDown(manager.dispose);
      expect(manager.details('luotopia.future').source, PluginSource.system);
      expect(
        manager.contribution('luotopia.future/card').route,
        '/plugins/luotopia.future/card/main',
      );
      await expectLater(
        loadBundledPlugins(bundle: _ExtraAssets('luotopia.settings')),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
    },
  );
  test(
    'shipped assets replace all nine providers without changing entry identities or order',
    () async {
      final packages = await loadBundledPlugins(bundle: _Assets());
      expect(packages.length, 9);
      final original = PluginManager();
      final migrated = PluginManager(bundledPackages: packages);
      addTearDown(original.dispose);
      addTearDown(migrated.dispose);
      for (final slot in ContributionSlot.values) {
        expect(
          migrated.entries(slot).map((c) => c.key),
          original.entries(slot).map((c) => c.key),
        );
      }
      for (final id in packages.map((p) => p.manifest.id)) {
        final plugin = migrated.details(id);
        expect(plugin.source, PluginSource.system);
        expect(plugin.script, contains('globalThis.luotopiaPlugin'));
        expect(plugin.manifest, isNotNull);
        expect(plugin.contributions.single.nativeRoute, isNull);
        expect(plugin.contributions.single.route, startsWith('/plugins/$id/'));
        expect(original.details(id).script, isNull);
      }
    },
  );

  test(
    'reserved shipped packages cannot enter the external install boundary',
    () async {
      final packages = await loadBundledPlugins(bundle: _Assets());
      final manager = PluginManager(bundledPackages: packages);
      addTearDown(manager.dispose);
      for (final package in packages) {
        expect(
          () => PluginManifest.fromJson(package.manifest.toJson()),
          throwsA(pluginError('RESERVED_ID')),
        );
        await expectLater(
          manager.install(
            package,
            approvedPermissions: {},
            validate: (_) async {},
          ),
          throwsA(pluginError('RESERVED_ID')),
        );
      }
      final path = Directory(
        'assets/system_plugins',
      ).listSync().whereType<File>().first.path;
      expect(
        () => PluginPackage.decode(File(path).readAsBytesSync()),
        throwsA(pluginError('RESERVED_ID')),
      );
    },
  );

  test(
    'bundled providers keep presentation and visibility through backup, uninstall and restore',
    () async {
      final packages = await loadBundledPlugins(bundle: _Assets());
      final manager = PluginManager(bundledPackages: packages);
      addTearDown(manager.dispose);
      const id = 'luotopia.library';
      const key = '$id/card';
      await manager.updatePresentation(key, {'title': '我的图书'});
      await manager.setContributionVisible(key, false);
      final backup = manager.exportBackup();
      await manager.restoreDefaultLayout();
      await manager.restoreBackup(backup);
      expect(manager.isVisible(key), isFalse);
      expect(manager.contribution(key).title, '我的图书');
      await manager.uninstall(id);
      expect(manager.details(id).enabled, isFalse);
      await manager.restoreBuiltin(id);
      expect(manager.details(id).enabled, isTrue);
      expect(manager.isVisible(key), isTrue);
      expect(manager.details(id).script, isNotNull);
      expect(manager.contribution(key).title, '我的图书');
    },
  );
}
