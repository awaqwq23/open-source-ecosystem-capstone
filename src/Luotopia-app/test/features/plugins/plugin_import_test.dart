import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/data/plugin_package_picker.dart';
import 'plugin_manifest_test.dart' show pluginError;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('luotopia/plugin_import');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });
  test(
    'native picker accepts validated package bytes without relying on a provider suffix',
    () async {
      // Read the real author payload; do not mock a prevalidated package object.
      final archive = Archive();
      for (final name in ['manifest.json', 'main.js', 'LICENSE.txt']) {
        archive.add(
          ArchiveFile.bytes(
            name,
            await File('../samples/plugins/study-time/$name').readAsBytes(),
          ),
        );
      }
      final bytes = ZipEncoder().encode(archive);
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'pick');
        expect(call.arguments, isNull);
        return bytes;
      });
      final package = await pickPluginPackage();
      expect(package!.manifest.id, 'org.example.study-time');
      expect(package.manifest.contributions.length, 3);
    },
  );
  test('cancel, native limit errors and invalid bytes stay distinct', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    expect(await pickPluginPackage(), isNull);
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
        code: 'PACKAGE_LIMIT_EXCEEDED',
        message: '插件包超过 5 MiB',
      );
    });
    await expectLater(
      pickPluginPackage(),
      throwsA(pluginError('PACKAGE_LIMIT_EXCEEDED')),
    );
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => Uint8List.fromList([1, 2, 3]),
    );
    await expectLater(
      pickPluginPackage(),
      throwsA(pluginError('INVALID_PACKAGE')),
    );
  });
}
