import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/plugin_package.dart';
import 'package:luotopia/features/plugins/data/plugin_store.dart';
import 'package:luotopia/features/plugins/domain/plugin_error.dart';
import 'package:luotopia/features/plugins/runtime/plugin_engine.dart';
import 'package:luotopia/features/plugins/runtime/plugin_session.dart';

const _script = '''globalThis.luotopiaPlugin = {
 apiVersion:1, marker:75,
 render(r,c){return {state:null,view:{title:'Imported',nodes:[{type:'button',id:'run',label:'Run',actionId:'sum'}]}}},
 async onAction(r,c){await c.host.storage.set('total',this.marker);return {state:this.marker,view:{title:'75',nodes:[{type:'text',id:'result',text:String(await c.host.storage.get('total'))}]}}}
};''';
Map<String, dynamic> manifest({String version = '1.0.0'}) => {
  'schemaVersion': 1,
  'apiVersion': 1,
  'id': 'org.example.runtime',
  'name': 'Runtime',
  'version': version,
  'entry': 'main.js',
  'description': 'Device import test',
  'author': 'Test',
  'license': 'MIT',
  'permissions': ['storage.self'],
  'networkHosts': [],
  'views': ['main'],
  'config': [],
  'contributions': [
    for (final slot in ['navigation', 'campusCard', 'settingsRow'])
      {
        'id': slot.toLowerCase(),
        'slot': slot,
        'title': 'Runtime',
        'icon': 'timer',
        'viewId': 'main',
        'allowedViews': ['main'],
      },
  ],
};
PluginPackage package(String script, {String version = '1.0.0'}) {
  final archive = Archive()
    ..add(
      ArchiveFile.string(
        'manifest.json',
        jsonEncode(manifest(version: version)),
      ),
    )
    ..add(ArchiveFile.string('main.js', script))
    ..add(ArchiveFile.string('LICENSE.txt', 'MIT'));
  return PluginPackage.decode(ZipEncoder().encode(archive));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'same installed binary imports ZIP, executes async SPI, survives reload and rolls back bad update',
    (tester) async {
      final temp = await Directory.systemTemp.createTemp('luo-plugin-device-');
      final store = PluginStore(temp);
      final manager = PluginManager(store: store);
      final imported = package(_script);
      await manager.install(
        imported,
        approvedPermissions: {'storage.self'},
        validate: PluginSession.validatePackage,
      );
      final session = PluginSession(
        manager,
        manager.contribution('org.example.runtime/navigation'),
        'main',
      );
      expect((await session.open()).view.title, 'Imported');
      final result = await session.action('sum', {});
      expect(result.state, 75);
      expect(result.view.nodes.single['text'], '75');
      session.dispose();
      expect(await session.engine.terminated, isTrue);
      final reopened = PluginManager(store: store);
      await reopened.load();
      expect(reopened.storageGet('org.example.runtime', 'total'), 75);
      await expectLater(
        reopened.install(
          package('while(true){}', version: '2.0.0'),
          approvedPermissions: {'storage.self'},
          validate: PluginSession.validatePackage,
          update: true,
        ),
        throwsA(isA<PluginException>()),
      );
      expect(
        reopened.details('org.example.runtime').manifest!.version,
        '1.0.0',
      );
      expect(reopened.storageGet('org.example.runtime', 'total'), 75);
      await reopened.uninstall('org.example.runtime');
      await reopened.install(
        imported,
        approvedPermissions: {'storage.self'},
        validate: PluginSession.validatePackage,
      );
      expect(reopened.storageGet('org.example.runtime', 'total'), isNull);
      manager.dispose();
      reopened.dispose();
      await temp.delete(recursive: true);
    },
  );
  testWidgets('native interrupt stops load/call/microtask loops and heap exhaustion', (
    tester,
  ) async {
    for (final source in [
      'while(true){}',
      '''globalThis.luotopiaPlugin={apiVersion:1,render(){while(true){}},onAction(){}}''',
      '''globalThis.luotopiaPlugin={apiVersion:1,render(){return new Promise(()=>{const again=()=>Promise.resolve().then(again);again()})},onAction(){}}''',
      '''globalThis.luotopiaPlugin={apiVersion:1,render(){const x=[];while(true)x.push(new Array(100000).fill(1));},onAction(){}}''',
      '''globalThis.luotopiaPlugin={apiVersion:1,render(){return {state:null,get view(){while(true){}}}},onAction(){}}''',
    ]) {
      final watch = Stopwatch()..start();
      final engine = PluginEngine();
      await expectLater(() async {
        await engine.start('org.example.loop', source);
        await engine.invoke(
          'render',
          {'state': null},
          {},
          (_, _) async => null,
        );
      }(), throwsA(isA<PluginException>()));
      expect(watch.elapsedMilliseconds, lessThan(5000));
      engine.close();
      expect(
        await engine.terminated,
        isTrue,
        reason: 'native disposal must acknowledge release',
      );
    }
  });
  testWidgets(
    'no ambient network and generation revocation closes an active view',
    (tester) async {
      final manager = PluginManager();
      final source = _script.replaceFirst(
        "title:'Imported'",
        "title:typeof fetch+':'+typeof XMLHttpRequest+':'+typeof require+':'+typeof setTimeout+':'+typeof sendMessage",
      );
      await manager.install(
        package(source),
        approvedPermissions: {'storage.self'},
        validate: PluginSession.validatePackage,
      );
      final session = PluginSession(
        manager,
        manager.contribution('org.example.runtime/navigation'),
        'main',
      );
      expect(
        (await session.open()).view.title,
        'undefined:undefined:undefined:undefined:undefined',
      );
      await manager.setContributionVisible(
        'org.example.runtime/navigation',
        false,
      );
      await expectLater(
        session.action('sum', {}),
        throwsA(isA<PluginException>()),
      );
      expect(manager.storageGet('org.example.runtime', 'total'), isNull);
      session.dispose();
      expect(await session.engine.terminated, isTrue);
      manager.dispose();
    },
  );
  testWidgets(
    'detached microtasks and cancellation during startup still release the native engine',
    (tester) async {
      for (var i = 0; i < 6; i++) {
        final engine = PluginEngine();
        await engine.start(
          'org.example.cleanup',
          '''globalThis.luotopiaPlugin={apiVersion:1,render(){const spin=()=>Promise.resolve().then(spin);spin();return {state:null,view:{title:'done',nodes:[]}}},onAction(){}}''',
        );
        await engine.invoke(
          'render',
          {'state': null},
          {},
          (_, _) async => null,
        );
        engine.close();
        expect(await engine.terminated, isTrue);
      }
      for (var i = 0; i < 6; i++) {
        final engine = PluginEngine();
        final starting = engine.start('org.example.cancel', _script);
        engine.close();
        await expectLater(starting, throwsA(isA<PluginException>()));
        expect(await engine.terminated, isTrue);
      }
    },
  );
}
