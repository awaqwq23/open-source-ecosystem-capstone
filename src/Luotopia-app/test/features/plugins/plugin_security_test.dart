import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/data/plugin_package.dart';
import 'package:luotopia/features/plugins/data/plugin_store.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:luotopia/features/plugins/runtime/plugin_http.dart';
import 'plugin_manifest_test.dart' show exampleManifest, pluginError;

void main() {
  test(
    'a failed database commit restores the prior plugin file and in-memory layout',
    () async {
      final temp = await Directory.systemTemp.createTemp(
        'plugin-backup-rollback-',
      );
      final store = PluginStore(temp);
      final manager = PluginManager(store: store);
      await manager.updatePresentation('luotopia.list/tab', {
        'title': 'Original',
      });
      final backup = PluginManager().exportBackup();
      await expectLater(
        manager.restoreBackupWithDatabase(backup, (writePlugins) async {
          await writePlugins();
          throw StateError('simulated database commit failure');
        }),
        throwsStateError,
      );
      expect(manager.contribution('luotopia.list/tab').title, 'Original');
      final reloaded = PluginManager(store: store);
      await reloaded.load();
      expect(reloaded.contribution('luotopia.list/tab').title, 'Original');
      await manager.restoreBackupWithDatabase(backup, (writePlugins) async {
        await writePlugins();
      });
      expect(
        manager.hasPresentationOverride('luotopia.list/tab', 'title'),
        isFalse,
      );
      manager.dispose();
      reloaded.dispose();
      await temp.delete(recursive: true);
    },
  );
  test(
    'manifest duplicate keys cannot give preview and execution different meanings',
    () {
      final json = jsonEncode(
        exampleManifest(),
      ).replaceFirst('"apiVersion":1', '"apiVersion":2,"apiVersion":1');
      final archive = Archive()
        ..add(ArchiveFile.string('manifest.json', json))
        ..add(ArchiveFile.string('main.js', 'void 0'))
        ..add(ArchiveFile.string('LICENSE.txt', 'MIT'));
      expect(
        () => PluginPackage.decode(ZipEncoder().encode(archive)),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
    },
  );
  test(
    'manifest configuration is a deep snapshot of the inspected contract',
    () {
      final raw = exampleManifest()
        ..['config'] = [
          {
            'key': 'choice',
            'type': 'choice',
            'label': 'Choice',
            'default': 'ok',
            'options': [
              {'value': 'ok', 'label': 'OK'},
            ],
          },
        ];
      final manifest = PluginManifest.fromJson(raw);
      ((raw['config'] as List).first['options'] as List).first['value'] =
          'injected';
      expect(
        () => manifest.validateConfig({'choice': 'injected'}),
        throwsA(pluginError('INVALID_INPUT')),
      );
      expect(
        () => (manifest.config.first['options'] as List).first['value'] =
            'injected',
        throwsUnsupportedError,
      );
      expect(manifest.validateConfig({}), {'choice': 'ok'});
    },
  );
  test(
    'network gate rejects private, loopback, multicast, transition and documentation IPs',
    () {
      for (final ip in [
        '0.0.0.0',
        '10.0.0.1',
        '127.0.0.1',
        '100.64.0.1',
        '169.254.169.254',
        '172.16.0.1',
        '192.168.1.1',
        '192.0.2.1',
        '198.18.0.1',
        '198.51.100.1',
        '203.0.113.1',
        '224.0.0.1',
        '255.255.255.255',
        '::1',
        '::ffff:127.0.0.1',
        'fc00::1',
        'fe80::1',
        '2001:db8::1',
        '2002:7f00:1::',
        '3fff::1',
      ]) {
        expect(isPublicPluginAddress(InternetAddress(ip)), isFalse, reason: ip);
      }
      for (final ip in ['1.1.1.1', '8.8.8.8', '2606:4700:4700::1111']) {
        expect(isPublicPluginAddress(InternetAddress(ip)), isTrue, reason: ip);
      }
    },
  );
  test(
    'host/port/credential and header gates reject before any network lookup',
    () async {
      for (final url in [
        'http://example.com',
        'https://127.0.0.1',
        'https://example.com:444',
        'https://user:pass@example.com',
        'https://other.example.com',
        'https://example.com/#fragment',
      ]) {
        final scope = PluginHttpScope('org.example.test', [
          'example.com',
        ], () {});
        await expectLater(
          scope.request({'url': url, 'method': 'GET'}),
          throwsA(pluginError('PERMISSION_DENIED')),
        );
        scope.close();
      }
      for (final header in [
        'Cookie',
        'Authorization',
        'Host',
        'Proxy-Authorization',
        'X-Private',
      ]) {
        final scope = PluginHttpScope('org.example.test', [
          'example.com',
        ], () {});
        await expectLater(
          scope.request({
            'url': 'https://example.com',
            'method': 'GET',
            'headers': {header: 'secret'},
          }),
          throwsA(pluginError('PERMISSION_DENIED')),
        );
        scope.close();
      }
    },
  );
  test(
    'cancelled scope refuses work instead of allocating new HTTP clients',
    () async {
      final scope = PluginHttpScope('org.example.test', ['example.com'], () {});
      scope.close();
      await expectLater(
        scope.request({'url': 'https://example.com', 'method': 'GET'}),
        throwsA(pluginError('PLUGIN_DISABLED')),
      );
    },
  );
}
