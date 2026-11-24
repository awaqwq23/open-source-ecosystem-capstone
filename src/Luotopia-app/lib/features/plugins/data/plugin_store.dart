import 'dart:convert';
import 'dart:io';
import '../domain/plugin_error.dart';

class PluginStore {
  PluginStore(this.directory);
  final Directory directory;
  File get _file => File('${directory.path}/state.json');
  File get _backup => File('${directory.path}/state.previous.json');

  Future<Map<String, dynamic>?> read() async {
    for (final file in [_file, _backup]) {
      if (!await file.exists()) continue;
      try {
        if (await file.length() > 64 * 1024 * 1024) continue;
        final state = jsonDecode(await file.readAsString());
        if (state is Map<String, dynamic> && state['schema'] == 1) return state;
      } catch (_) {
        /* Try last committed snapshot, never the staging file. */
      }
    }
    if (await _file.exists() || await _backup.exists()) {
      throw const PluginException('PERSISTENCE_FAILED', '插件配置损坏，原文件已保留，请恢复备份');
    }
    return null;
  }

  Future<void> write(Map<String, dynamic> state) async {
    final pending = File('${directory.path}/state.pending.json');
    try {
      await directory.create(recursive: true);
      final text = jsonEncode(state);
      if (utf8.encode(text).length > 64 * 1024 * 1024) {
        throw const PluginException(
          'RESOURCE_LIMIT_EXCEEDED',
          '插件总存储超过 64 MiB',
        );
      }
      await pending.writeAsString(text, flush: true);
      if (await _file.exists()) {
        if (await _backup.exists()) await _backup.delete();
        await _file.rename(_backup.path);
      }
      try {
        await pending.rename(_file.path);
      } catch (_) {
        if (!await _file.exists() && await _backup.exists()) {
          await _backup.copy(_file.path);
        }
        rethrow;
      }
    } on PluginException {
      rethrow;
    } catch (_) {
      throw const PluginException('PERSISTENCE_FAILED', '保存插件配置失败，原配置仍可恢复');
    }
  }
}
