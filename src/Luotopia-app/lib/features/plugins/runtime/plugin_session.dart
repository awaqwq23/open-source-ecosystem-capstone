import 'dart:convert';
import '../application/plugin_manager.dart';
import '../data/plugin_package.dart';
import '../domain/plugin_manifest.dart';
import '../domain/plugin_view.dart';
import 'plugin_engine.dart';
import 'plugin_http.dart';

class PluginSession {
  PluginSession(
    this.manager,
    this.contribution,
    this.viewId, {
    this.locale = 'zh',
    this.theme = 'light',
  }) : generation = manager.generation(contribution.pluginId);
  final PluginManager manager;
  final PluginContribution contribution;
  final int generation;
  final String viewId, locale, theme;
  final engine = PluginEngine();
  PluginResult? result;
  PluginHttpScope? _http;
  String? nextView;
  bool _activeRequest = false, _disposed = false;
  int _calls = 0, _pending = 0;
  static int _globalPending = 0;
  static final _pluginPending = <String, int>{};
  void _check() {
    requirePlugin(!_disposed, '插件页面已关闭', 'PLUGIN_DISABLED');
    manager.checkAccess(contribution.key, viewId, generation);
  }

  Map<String, dynamic> get _context => {
    'pluginId': contribution.pluginId,
    'contributionId': contribution.id,
    'viewId': viewId,
    'locale': locale,
    'theme': theme,
    'config': manager.configuration(contribution.pluginId),
  };
  Future<PluginResult> open() async {
    _check();
    manager.addListener(_changed);
    await engine.start(
      contribution.pluginId,
      manager.details(contribution.pluginId).script!,
    );
    await _invoke('activate', {});
    return render();
  }

  void _changed() {
    try {
      _check();
    } catch (_) {
      dispose();
    }
  }

  Future<PluginResult> render() async {
    result = PluginResult.fromJson(
      await _invoke('render', {'state': result?.state}),
    );
    return result!;
  }

  Future<PluginResult> action(String id, Map<String, dynamic> input) async {
    _check();
    requirePlugin(result != null, '页面尚未就绪', 'INVALID_INPUT');
    final values = result!.view.validateAction(id, input);
    result = PluginResult.fromJson(
      await _invoke('onAction', {
        'actionId': id,
        'input': values,
        'state': result!.state,
      }),
    );
    return result!;
  }

  Future<Object?> _invoke(String method, Map<String, dynamic> payload) async {
    _check();
    requirePlugin(!_activeRequest, '正在处理上一次操作', 'RESOURCE_LIMIT_EXCEEDED');
    _activeRequest = true;
    _calls = 0;
    nextView = null;
    final id = contribution.pluginId;
    final manifest = manager.details(id).manifest!;
    _http = PluginHttpScope(id, manifest.networkHosts, () {
      _check();
      requirePlugin(_activeRequest, '动作已结束', 'PLUGIN_DISABLED');
    });
    try {
      final response = await engine.invoke(method, payload, _context, (
        name,
        args,
      ) async {
        _check();
        requirePlugin(_activeRequest, '动作已结束', 'PLUGIN_DISABLED');
        requirePlugin(
          ++_calls <= 32 &&
              _pending < 16 &&
              (_pluginPending[id] ?? 0) < 16 &&
              _globalPending < 64,
          '宿主调用过多',
          'RESOURCE_LIMIT_EXCEEDED',
        );
        requirePlugin(
          utf8.encode(jsonEncode(args)).length <= 256 * 1024,
          '调用参数过大',
          'INVALID_INPUT',
        );
        _pending++;
        _globalPending++;
        _pluginPending[id] = (_pluginPending[id] ?? 0) + 1;
        try {
          if (name.startsWith('storage.')) {
            requirePlugin(
              manifest.permissions.contains('storage.self'),
              '未授权插件存储',
              'PERMISSION_DENIED',
            );
            requirePlugin(
              args.length == (name == 'storage.set' ? 2 : 1) &&
                  args.first is String,
              '存储参数不正确',
              'INVALID_INPUT',
            );
            if (name == 'storage.get') {
              return manager.storageGet(id, args.first as String);
            }
            requirePlugin(
              method == 'onAction',
              '只能在用户操作时修改数据',
              'PERMISSION_DENIED',
            );
            requirePlugin(
              name == 'storage.set' || name == 'storage.remove',
              '未知存储方法',
              'PERMISSION_DENIED',
            );
            await manager.storageWrite(
              id,
              args.first as String,
              args.length == 2 ? args[1] : null,
              expectedGeneration: generation,
              remove: name == 'storage.remove',
            );
            return null;
          }
          requirePlugin(
            method == 'onAction',
            '只能在用户操作时调用此能力',
            'PERMISSION_DENIED',
          );
          if (name == 'http.request') {
            requirePlugin(
              manifest.permissions.contains('network.https'),
              '未授权网络访问',
              'PERMISSION_DENIED',
            );
            requirePlugin(args.length == 1, '网络参数不正确', 'INVALID_INPUT');
            return await _http!.request(args.first);
          }
          if (name == 'openView') {
            requirePlugin(
              args.length == 1 && args.first is String,
              '页面参数不正确',
              'INVALID_INPUT',
            );
            manager.checkAccess(
              contribution.key,
              args.first as String,
              generation,
            );
            nextView = args.first as String;
            return null;
          }
          requirePlugin(false, '不支持此宿主能力', 'PERMISSION_DENIED');
          return null;
        } finally {
          _pending--;
          _globalPending--;
          _pluginPending[id] = (_pluginPending[id] ?? 1) - 1;
        }
      });
      _check();
      return response;
    } finally {
      _activeRequest = false;
      _http?.close();
      _http = null;
    }
  }

  void dispose() {
    if (_disposed) return;
    final wasBusy = _activeRequest;
    _disposed = true;
    _activeRequest = false;
    manager.removeListener(_changed);
    _http?.close();
    if (!wasBusy && result != null && !engine.closed) {
      engine
          .invoke('deactivate', {}, {}, (_, _) async {
            requirePlugin(false, '清理时不能调用宿主能力', 'PERMISSION_DENIED');
            return null;
          })
          .timeout(const Duration(milliseconds: 100))
          .then((_) => engine.close(), onError: (Object _) => engine.close());
    } else {
      engine.close();
    }
  }

  static Future<void> validatePackage(PluginPackage package) async {
    final engine = PluginEngine();
    try {
      await engine.start(package.manifest.id, package.script);
      var activated = false;
      for (final c in package.manifest.contributions) {
        final context = {
          'pluginId': package.manifest.id,
          'contributionId': c.id,
          'viewId': c.viewId,
          'locale': 'zh',
          'theme': 'light',
          'config': package.manifest.defaultConfig,
        };
        Future<Object?> readOnly(String method, List<dynamic> args) async {
          requirePlugin(
            method == 'storage.get' &&
                package.manifest.permissions.contains('storage.self'),
            '试运行只能读取空存储',
            'PERMISSION_DENIED',
          );
          return null;
        }

        if (!activated) {
          await engine.invoke('activate', {}, context, readOnly);
          activated = true;
        }
        PluginResult.fromJson(
          await engine.invoke('render', {'state': null}, context, readOnly),
        );
      }
    } finally {
      engine.close();
      requirePlugin(
        await engine.terminated,
        '运行环境无法安全释放，请重启应用',
        'UNSUPPORTED_RUNTIME',
      );
    }
  }
}
