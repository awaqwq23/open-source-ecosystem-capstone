import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import '../domain/plugin_error.dart';
import '../domain/plugin_manifest.dart';

class PluginPackage {
  PluginPackage(this.manifest, this.script, this.license, this.digest);
  final PluginManifest manifest;
  final String script, license, digest;
  static const maxBytes = 5 * 1024 * 1024;

  static Future<PluginPackage> loadBundledAsset(
    String path,
    AssetBundle bundle,
  ) async {
    requirePlugin(
      path.startsWith('assets/system_plugins/') &&
          path.endsWith('.luoplugin') &&
          !path.contains('..'),
      '不是应用内置插件路径',
    );
    final bytes = await bundle.load(path);
    return PluginPackage._decode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      bundledAsset: true,
    );
  }

  factory PluginPackage.decode(List<int> bytes) => PluginPackage._decode(bytes);

  static PluginPackage _decode(List<int> bytes, {bool bundledAsset = false}) {
    requirePlugin(
      bytes.length <= maxBytes,
      '插件压缩包超过 5 MiB',
      'PACKAGE_LIMIT_EXCEEDED',
    );
    try {
      final decoder = ZipDecoder();
      final archive = decoder.decodeBytes(bytes, verify: true);
      final headers = decoder.directory.fileHeaders;
      requirePlugin(
        headers.length == 3 && archive.length == 3,
        '插件包必须恰好包含三个文件',
      );
      final names = <String>{};
      var total = 0;
      final texts = <String, String>{};
      for (final header in headers) {
        final name = header.filename;
        requirePlugin(
          {'manifest.json', 'main.js', 'LICENSE.txt'}.contains(name) &&
              names.add(name.toLowerCase()),
          '非法路径、重复文件或未知文件',
        );
        requirePlugin(
          header.generalPurposeBitFlag & 1 == 0 &&
              {0, 8}.contains(header.compressionMethod),
          '不支持加密包或此压缩方式',
        );
        final type = (header.externalFileAttributes >> 16) & 0xf000;
        requirePlugin(type == 0 || type == 0x8000, '不允许链接或目录');
        final limit = name == 'manifest.json'
            ? 64 * 1024
            : name == 'main.js'
            ? 2 * 1024 * 1024
            : 1024 * 1024;
        requirePlugin(
          header.uncompressedSize <= limit,
          '插件文件超出大小限制',
          'PACKAGE_LIMIT_EXCEEDED',
        );
        final output = _BoundedOutput(limit);
        archive.findFile(name)!.writeContent(output);
        total += output.length;
        requirePlugin(
          total <= 10 * 1024 * 1024,
          '解压总量超限',
          'PACKAGE_LIMIT_EXCEEDED',
        );
        texts[name] = utf8.decode(output.getBytes(), allowMalformed: false);
      }
      requirePlugin(
        texts['main.js']!.trim().isNotEmpty &&
            texts['LICENSE.txt']!.trim().isNotEmpty,
        '脚本和许可不能为空',
      );
      return PluginPackage(
        PluginManifest.fromJson(
          _decodeManifest(texts['manifest.json']!),
          bundledAsset: bundledAsset,
        ),
        texts['main.js']!,
        texts['LICENSE.txt']!,
        sha256.convert(bytes).toString(),
      );
    } on PluginException {
      rethrow;
    } catch (_) {
      pluginFail('INVALID_PACKAGE', '无法读取插件包，请检查 ZIP、UTF-8、校验和与 manifest');
    }
  }
}

Object? _decodeManifest(String text) {
  final value = jsonDecode(text);
  // Dart's decoder accepts duplicate keys. Inspect JSON tokens as well so the
  // preview and other authoring tools cannot disagree about a manifest's meaning.
  final tokens = RegExp(
    r'"(?:[^"\\]|\\.)*"|[{}\[\]:,]|true|false|null|-?[0-9]+(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?',
  ).allMatches(text).map((m) => m.group(0)!).toList();
  var i = 0;
  void visit(int depth) {
    requirePlugin(depth <= 16, 'manifest 嵌套过深');
    final token = tokens[i++];
    if (token == '{') {
      final keys = <String>{};
      if (tokens[i] == '}') {
        i++;
        return;
      }
      while (true) {
        final key = jsonDecode(tokens[i++]) as String;
        requirePlugin(keys.add(key), 'manifest 存在重复 JSON 键');
        i++;
        visit(depth + 1);
        if (tokens[i++] == '}') break;
      }
    } else if (token == '[') {
      if (tokens[i] == ']') {
        i++;
        return;
      }
      while (true) {
        visit(depth + 1);
        if (tokens[i++] == ']') break;
      }
    }
  }

  visit(0);
  return value;
}

// Every output path is checked before allocation, including inflater back references.
class _BoundedOutput extends OutputMemoryStream {
  _BoundedOutput(this.limit);
  final int limit;
  void check(int size) =>
      requirePlugin(size <= limit, '解压实际内容超限', 'PACKAGE_LIMIT_EXCEEDED');
  @override
  void reserve(int total) {
    check(total);
    super.reserve(total);
  }

  @override
  void writeByte(int value) {
    check(length + 1);
    super.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    check(this.length + (length ?? bytes.length));
    super.writeBytes(bytes, length: length);
  }

  @override
  void writeBackReference(int distance, int count) {
    check(length + count);
    super.writeBackReference(distance, count);
  }

  @override
  void writeStream(InputStream stream) {
    final position = stream.position;
    try {
      final buffer = Uint8List(8192);
      while (!stream.isEOS) {
        final count = stream.readInto(buffer, 0, buffer.length);
        if (count <= 0) break;
        writeBytes(buffer, length: count);
      }
    } finally {
      stream.setPosition(position);
    }
  }
}
