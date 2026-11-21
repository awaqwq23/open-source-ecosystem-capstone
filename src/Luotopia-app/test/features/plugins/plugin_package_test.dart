import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/data/plugin_package.dart';
import 'plugin_manifest_test.dart' show exampleManifest, pluginError;

Uint8List zipPackage({
  String scriptName = 'main.js',
  String? script,
  String licenseName = 'LICENSE.txt',
  bool symlink = false,
}) {
  final archive = Archive();
  for (final entry in {
    'manifest.json': jsonEncode(exampleManifest()),
    scriptName: script ?? 'globalThis.luotopiaPlugin = {};',
    licenseName: 'MIT',
  }.entries) {
    final data = utf8.encode(entry.value);
    final file = ArchiveFile(entry.key, data.length, data);
    if (symlink && entry.key == scriptName) file.symbolicLink = 'elsewhere.js';
    archive.addFile(file);
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

// ZIP headers are public binary format. Patching both central and local headers
// lets these fixtures model malformed third-party archives the encoder forbids.
List<int> headerOffsets(Uint8List bytes, int signature) {
  final data = ByteData.sublistView(bytes);
  return [
    for (var i = 0; i <= bytes.length - 4; i++)
      if (data.getUint32(i, Endian.little) == signature) i,
  ];
}

void main() {
  test('valid ZIP retains script, license and stable digest', () {
    final bytes = zipPackage();
    final value = PluginPackage.decode(bytes);
    expect(value.manifest.id, 'org.example.study-time');
    expect(value.script, 'globalThis.luotopiaPlugin = {};');
    expect(value.license, 'MIT');
    expect(value.digest, matches(RegExp(r'^[a-f0-9]{64}$')));
    expect(PluginPackage.decode(bytes).digest, value.digest);
  });
  test('oversized ZIP and declared script limits fail before installation', () {
    expect(
      () => PluginPackage.decode(Uint8List(PluginPackage.maxBytes + 1)),
      throwsA(pluginError('PACKAGE_LIMIT_EXCEEDED')),
    );
    expect(
      () =>
          PluginPackage.decode(zipPackage(script: 'x' * (2 * 1024 * 1024 + 1))),
      throwsA(pluginError('PACKAGE_LIMIT_EXCEEDED')),
    );
  });
  test(
    'traversal, absolute, backslash, case variants and links are rejected',
    () {
      for (final name in [
        '../main.js',
        '/main.js',
        'C:/main.js',
        'dir\\main.js',
        'MAIN.JS',
      ]) {
        expect(
          () => PluginPackage.decode(zipPackage(scriptName: name)),
          throwsA(pluginError('INVALID_PACKAGE')),
          reason: name,
        );
      }
      expect(
        () => PluginPackage.decode(zipPackage(symlink: true)),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
    },
  );
  test(
    'duplicate and case-equivalent central entries cannot replace required files',
    () {
      // Duplicate manifest.json has the same length as replacement payload name.
      final bytes = zipPackage(licenseName: 'manifest.jsoN');
      final data = ByteData.sublistView(bytes);
      for (final offset in headerOffsets(bytes, 0x02014b50)) {
        final start = offset + 46;
        final length = data.getUint16(offset + 28, Endian.little);
        if (utf8.decode(bytes.sublist(start, start + length)) ==
            'manifest.jsoN') {
          final local = data.getUint32(offset + 42, Endian.little);
          bytes[start + length - 1] = 110;
          bytes[local + 30 + length - 1] = 110;
        }
      }
      expect(
        () => PluginPackage.decode(bytes),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
      final caseBytes = zipPackage(licenseName: 'MAIN.JS');
      expect(
        () => PluginPackage.decode(caseBytes),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
    },
  );
  test('actual inflated bytes cannot hide behind a tiny claimed size', () {
    final bytes = zipPackage(script: 'x' * (2 * 1024 * 1024 + 1));
    final data = ByteData.sublistView(bytes);
    for (final offset in headerOffsets(bytes, 0x02014b50)) {
      final length = data.getUint16(offset + 28, Endian.little);
      if (utf8.decode(bytes.sublist(offset + 46, offset + 46 + length)) ==
          'main.js') {
        data.setUint32(offset + 24, 1, Endian.little);
        data.setUint32(
          data.getUint32(offset + 42, Endian.little) + 22,
          1,
          Endian.little,
        );
      }
    }
    // archive's inflater rejects output beyond its claimed 1-byte size before
    // the host's independent 2 MiB budget, so this is a malformed ZIP error.
    expect(
      () => PluginPackage.decode(bytes),
      throwsA(pluginError('INVALID_PACKAGE')),
    );
  });
  test(
    'CRC mismatches and truncated ZIP fail rather than produce executable packages',
    () {
      final bytes = zipPackage();
      final data = ByteData.sublistView(bytes);
      final central = headerOffsets(bytes, 0x02014b50).first;
      final badCrc = data.getUint32(central + 16, Endian.little) ^ 0xffffffff;
      data.setUint32(central + 16, badCrc, Endian.little);
      data.setUint32(
        data.getUint32(central + 42, Endian.little) + 14,
        badCrc,
        Endian.little,
      );
      expect(
        () => PluginPackage.decode(bytes),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
      final original = zipPackage();
      expect(
        () => PluginPackage.decode(original.sublist(0, original.length ~/ 2)),
        throwsA(pluginError('INVALID_PACKAGE')),
      );
    },
  );
}
