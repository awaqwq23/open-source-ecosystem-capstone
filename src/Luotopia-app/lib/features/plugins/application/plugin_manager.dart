import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plugin_package.dart';
import '../data/plugin_store.dart';
import '../domain/builtin_plugins.dart';
import '../domain/plugin_error.dart';
import '../domain/plugin_manifest.dart';

final pluginManagerProvider = ChangeNotifierProvider<PluginManager>(
  (ref) => PluginManager(),
);

class PluginSummary {
  const PluginSummary(
    this.id,
    this.name,
    this.source,
    this.enabled,
    this.contributions, {
    this.manifest,
    this.script,
    this.digest,
  });
  final String id, name;
  final PluginSource source;
  final bool enabled;
  final List<PluginContribution> contributions;
  final PluginManifest? manifest;
  final String? script, digest;
}

class PluginManager extends ChangeNotifier {
  PluginManager({
    this.store,
    bool legacyAi = false,
    this.bundledPackages = const [],
  }) : _state = _defaults(legacyAi);
  final PluginStore? store;
  final List<PluginPackage> bundledPackages;
  Map<String, dynamic> _state;
  List<PluginSummary>? _catalog;
  Future<void> _queue = Future.value();
  String? loadError;
  int get revision => _state['revision'] as int;
  static Map<String, dynamic> _defaults(bool ai) => {
    'schema': 1,
    'revision': 0,
    'disabled': <String>[],
    'removedSystem': <String>[],
    'hidden': [ai ? 'luotopia.forum/tab' : 'luotopia.ai/tab'],
    'external': <String, dynamic>{},
    'presentation': <String, dynamic>{},
    'config': <String, dynamic>{},
    'order': <String, dynamic>{},
    'data': <String, dynamic>{},
    'sealedData': <String, dynamic>{},
    'generations': <String, dynamic>{},
    'retainedPackages': <String, dynamic>{},
    'restoredConfig': <String, dynamic>{},
  };
  Map<String, dynamic> _map(String key) =>
      (_state[key] as Map).cast<String, dynamic>();
  bool hasPresentationOverride(String key, String field) =>
      (_map('presentation')[key] as Map? ?? {}).containsKey(field);
  List<String> _list(String key) => List<String>.from(_state[key] as List);

  Future<void> load() async {
    try {
      final saved = await store?.read();
      if (saved != null) {
        final old = _state;
        _state = {..._defaults(false), ...saved};
        _catalog = null;
        try {
          list();
          revision;
          for (final slot in ContributionSlot.values) {
            entries(slot);
          }
        } catch (_) {
          _state = old;
          _catalog = null;
          rethrow;
        }
      }
    } catch (_) {
      loadError = '插件配置读取失败，已使用安全的默认入口；原文件已保留。';
    }
  }

  List<PluginSummary> list() => _catalog ??= List.unmodifiable([
    for (final p in builtinPlugins) _builtinSummary(p),
    for (final p in bundledPackages)
      if (!builtinPlugins.any((b) => b.id == p.manifest.id)) _bundledSummary(p),
    for (final e in _map('external').entries) _externalSummary(e),
  ]);
  PluginSummary _builtinSummary(BuiltinPlugin builtin) {
    final matches = bundledPackages.where((p) => p.manifest.id == builtin.id);
    if (matches.isNotEmpty) {
      final p = matches.single;
      return _bundledSummary(p);
    }
    return PluginSummary(
      builtin.id,
      builtin.name,
      builtin.source,
      builtin.source == PluginSource.core ||
          !_list('disabled').contains(builtin.id),
      builtin.contributions,
    );
  }

  PluginSummary _bundledSummary(PluginPackage p) => PluginSummary(
    p.manifest.id,
    p.manifest.name,
    PluginSource.system,
    !_list('disabled').contains(p.manifest.id),
    p.manifest.contributions,
    manifest: p.manifest,
    script: p.script,
    digest: p.digest,
  );

  PluginSummary _externalSummary(MapEntry<String, dynamic> e) {
    final value = pluginObject(e.value);
    final m = PluginManifest.fromJson(value['manifest']);
    requirePlugin(m.id == e.key, '插件索引身份不一致');
    requirePlugin(
      value['script'] is String &&
          utf8.encode(value['script'] as String).length <= 2 * 1024 * 1024,
      '插件索引脚本大小不正确',
    );
    return PluginSummary(
      m.id,
      m.name,
      PluginSource.external,
      !_list('disabled').contains(m.id),
      m.contributions,
      manifest: m,
      script: value['script'] as String,
      digest: value['digest'] as String,
    );
  }

  PluginSummary details(String id) => list().firstWhere(
    (p) => p.id == id,
    orElse: () => pluginFail('PLUGIN_NOT_FOUND', '插件未安装'),
  );
  PluginContribution contribution(String key) {
    for (final p in list()) {
      for (final c in p.contributions) {
        if (c.key == key) {
          return c.present(
            Map<String, dynamic>.from(_map('presentation')[key] as Map? ?? {}),
          );
        }
      }
    }
    pluginFail('PLUGIN_NOT_FOUND', '入口不存在');
  }

  bool isVisible(String key) {
    try {
      final c = contribution(key);
      return c.protected ||
          (details(c.pluginId).enabled && !_list('hidden').contains(key));
    } on PluginException {
      return false;
    }
  }

  List<PluginContribution> entries(ContributionSlot slot) {
    final hidden = _list('hidden').toSet();
    final overrides = _map('presentation');
    final all = [
      for (final p in list())
        for (final c in p.contributions)
          if (c.slot == slot &&
              (c.protected || (p.enabled && !hidden.contains(c.key))))
            c.present(
              Map<String, dynamic>.from(overrides[c.key] as Map? ?? {}),
            ),
    ];
    if (slot == ContributionSlot.settingsRow) {
      final notification = all
          .where((c) => c.pluginId == 'luotopia.notification')
          .firstOrNull;
      if (notification != null) {
        all.remove(notification);
        all.insert(all.isEmpty ? 0 : 1, notification);
      }
    }
    if (slot == ContributionSlot.navigation) {
      final core = all.where((c) => c.protected).toList();
      all.removeWhere((c) => c.protected);
      all.insertAll(0, core);
    }
    final order = List<String>.from(_map('order')[slot.name] as List? ?? []);
    final original = {for (var i = 0; i < all.length; i++) all[i].key: i};
    int rank(PluginContribution c) {
      final i = order.indexOf(c.key);
      return i < 0 ? order.length + original[c.key]! : i;
    }

    all.sort((a, b) => rank(a).compareTo(rank(b)));
    return all;
  }

  int generation(String id) => _map('generations')[id] as int? ?? 0;
  Map<String, dynamic> configuration(String id) =>
      details(id).manifest?.validateConfig(
        Map<String, dynamic>.from(_map('config')[id] as Map? ?? {}),
      ) ??
      {};
  void checkAccess(String key, String viewId, [int? expectedGeneration]) {
    final c = contribution(key);
    requirePlugin(details(c.pluginId).enabled, '插件已停用', 'PLUGIN_DISABLED');
    requirePlugin(isVisible(key), '入口已隐藏', 'CONTRIBUTION_HIDDEN');
    requirePlugin(
      c.allowedViews.contains(viewId),
      '当前入口不允许访问此页面',
      'PERMISSION_DENIED',
    );
    requirePlugin(
      expectedGeneration == null ||
          generation(c.pluginId) == expectedGeneration,
      '插件已变更，请重新打开',
      'PLUGIN_DISABLED',
    );
  }

  String? redirectNative(String path) {
    final owners = [
      for (final p in list())
        for (final c in p.contributions)
          if (c.nativeRoute != null &&
              c.nativeRoute != '/' &&
              (path == c.nativeRoute || path.startsWith('${c.nativeRoute}/')))
            c,
    ];
    owners.sort(
      (a, b) => b.nativeRoute!.length.compareTo(a.nativeRoute!.length),
    );
    if (owners.isNotEmpty && !isVisible(owners.first.key)) return '/';
    return null;
  }

  Future<void> _mutate(
    void Function(Map<String, dynamic>) change, {
    int? expectedRevision,
  }) {
    final result = _queue.then((_) async {
      requirePlugin(
        loadError == null,
        '请先恢复插件配置，避免覆盖原文件',
        'PERSISTENCE_FAILED',
      );
      requirePlugin(
        expectedRevision == null || revision == expectedRevision,
        '布局已变化，请刷新后重试',
        'REVISION_CONFLICT',
      );
      final next = jsonDecode(jsonEncode(_state)) as Map<String, dynamic>;
      change(next);
      _checkCapacity(next);
      next['revision'] = revision + 1;
      await store?.write(next);
      _state = next;
      _catalog = null;
      notifyListeners();
    });
    _queue = result.catchError((Object _) {});
    return result;
  }

  void _bump(Map<String, dynamic> s, String id) =>
      (s['generations'] as Map)[id] = generation(id) + 1;
  void _editable(String id) => requirePlugin(
    details(id).source != PluginSource.core,
    '核心插件必须保留',
    'CORE_PLUGIN_LOCKED',
  );
  bool isRemoved(String id) => _list('removedSystem').contains(id);

  Future<void> setEnabled(String id, bool enabled) => _mutate((s) {
    _editable(id);
    requirePlugin(!isRemoved(id), '请先重新安装系统插件', 'PLUGIN_NOT_FOUND');
    final disabled = s['disabled'] as List;
    disabled.remove(id);
    if (!enabled) disabled.add(id);
    _bump(s, id);
  });
  Future<void> uninstall(String id, {bool deleteData = false}) => _mutate((s) {
    _editable(id);
    final previous = details(id);
    if (details(id).source == PluginSource.external) {
      (s['retainedPackages'] as Map)[id] = {
        'id': id,
        'name': previous.name,
        'version': previous.manifest!.version,
        'digest': previous.digest,
      };
      (s['external'] as Map).remove(id);
    } else {
      final removed = s['removedSystem'] as List;
      if (!removed.contains(id)) removed.add(id);
      (s['disabled'] as List).remove(id);
      (s['disabled'] as List).add(id);
    }
    if (deleteData) {
      (s['data'] as Map).remove(id);
      (s['sealedData'] as Map).remove(id);
      (s['retainedPackages'] as Map).remove(id);
      (s['restoredConfig'] as Map).remove(id);
      (s['config'] as Map).remove(id);
    } else if ((s['data'] as Map).containsKey(id)) {
      (s['sealedData'] as Map)[id] = (s['data'] as Map).remove(id);
    }
    _bump(s, id);
  });
  Future<void> restoreBuiltin(String id) => _mutate((s) {
    requirePlugin(details(id).source == PluginSource.system, '仅可恢复内置可选插件');
    (s['removedSystem'] as List).remove(id);
    (s['disabled'] as List).remove(id);
    if ((s['sealedData'] as Map).containsKey(id)) {
      (s['data'] as Map)[id] = (s['sealedData'] as Map).remove(id);
    }
    for (final c in details(id).contributions) {
      (s['hidden'] as List).remove(c.key);
    }
    _bump(s, id);
  });
  Future<void> setContributionVisible(String key, bool visible) => _mutate((s) {
    final c = contribution(key);
    requirePlugin(!c.protected, '核心入口必须保留', 'CORE_PLUGIN_LOCKED');
    final hidden = s['hidden'] as List;
    hidden.remove(key);
    if (!visible) hidden.add(key);
    _bump(s, c.pluginId);
  });
  Future<void> updatePresentation(String key, Map<String, dynamic> patch) =>
      _mutate((s) {
        final c = contribution(key);
        requirePlugin(!c.protected, '核心入口不可修改', 'CORE_PLUGIN_LOCKED');
        pluginFields(patch, {'title', 'icon', 'color'}, 'INVALID_INPUT');
        if (patch.containsKey('title')) {
          pluginText(patch['title'], 64, 'INVALID_INPUT');
        }
        requirePlugin(
          !patch.containsKey('icon') || pluginIcons.contains(patch['icon']),
          '未知图标',
          'INVALID_INPUT',
        );
        requirePlugin(
          !patch.containsKey('color') || pluginColors.contains(patch['color']),
          '未知颜色',
          'INVALID_INPUT',
        );
        (s['presentation'] as Map)[key] = {
          ...(_map('presentation')[key] as Map? ?? {}),
          ...patch,
        };
      });
  Future<void> updateConfig(String id, Map<String, dynamic> config) =>
      _mutate((s) {
        final m = details(id).manifest;
        requirePlugin(m != null, '此插件没有外部配置', 'INVALID_INPUT');
        (s['config'] as Map)[id] = m!.validateConfig(config);
        _bump(s, id);
      });
  Future<void> reorder(
    ContributionSlot slot,
    List<String> keys, {
    int? expectedRevision,
  }) => _mutate((s) {
    final current = entries(slot).map((c) => c.key).toList();
    requirePlugin(
      keys.length == current.length &&
          keys.toSet().length == keys.length &&
          keys.toSet().containsAll(current),
      '排序必须包括所有可见入口',
      'INVALID_INPUT',
    );
    (s['order'] as Map)[slot.name] = keys;
  }, expectedRevision: expectedRevision);
  Future<void> restoreDefaultLayout() => _mutate((s) {
    s['removedSystem'] = [];
    s['order'] = {};
    s['presentation'] = {};
    s['disabled'] = _list(
      'disabled',
    ).where((id) => !id.startsWith('luotopia.')).toList();
    s['hidden'] = [
      'luotopia.ai/tab',
      for (final p in list())
        if (p.source == PluginSource.external)
          ...p.contributions.map((c) => c.key),
    ];
    for (final p in list()) {
      _bump(s, p.id);
    }
  });

  bool hasRetainedData(String id) => _map('sealedData').containsKey(id);
  String? retainedDigest(String id) =>
      (_map('retainedPackages')[id] as Map?)?['digest'] as String?;
  List<String> get pendingImports => {
    ..._map('retainedPackages').keys,
    ..._map('sealedData').keys,
  }.where((id) => !_map('external').containsKey(id)).toList();
  Future<void> install(
    PluginPackage package, {
    required Set<String> approvedPermissions,
    required Future<void> Function(PluginPackage) validate,
    bool reuseData = false,
    bool update = false,
  }) async {
    requirePlugin(
      approvedPermissions.length == package.manifest.permissions.length &&
          approvedPermissions.containsAll(package.manifest.permissions),
      '请明确同意全部申请权限',
      'PERMISSION_DENIED',
    );
    // The external installation boundary never accepts shipped reserved IDs,
    // including a package object previously read from an app asset.
    PluginManifest.fromJson(package.manifest.toJson());
    final before = revision;
    await validate(package);
    await _mutate((s) {
      final id = package.manifest.id;
      final existing = _map('external')[id];
      requirePlugin(
        update == (existing != null),
        update ? '要更新的插件不存在' : '插件已安装，请选择更新',
        'UPDATE_FAILED',
      );
      if (existing != null) {
        final old = details(id).manifest!;
        final a = package.manifest.version.split('.').map(int.parse).toList();
        final b = old.version.split('.').map(int.parse).toList();
        var compare = 0;
        for (var i = 0; i < 3 && compare == 0; i++) {
          compare = a[i].compareTo(b[i]);
        }
        requirePlugin(compare > 0, '更新版本必须高于当前版本', 'UPDATE_FAILED');
        for (final field in old.config) {
          requirePlugin(
            package.manifest.config.any(
              (f) => jsonEncode(f) == jsonEncode(field),
            ),
            '更新改变了已有配置契约',
            'UPDATE_FAILED',
          );
        }
        package.manifest.validateConfig(configuration(id));
      } else {
        requirePlugin(
          _namespaceIds(_state).contains(id) ||
              _namespaceIds(_state).length < 16,
          '最多保留 16 个外部插件及数据，请先删除不再需要的保留数据',
          'RESOURCE_LIMIT_EXCEEDED',
        );
      }
      (s['external'] as Map)[id] = {
        'manifest': package.manifest.toJson(),
        'script': package.script,
        'license': package.license,
        'digest': package.digest,
      };
      (s['disabled'] as List).remove(id);
      if (reuseData && (s['sealedData'] as Map).containsKey(id)) {
        (s['data'] as Map)[id] = (s['sealedData'] as Map).remove(id);
      }
      if (reuseData && (s['restoredConfig'] as Map).containsKey(id)) {
        (s['config'] as Map)[id] = package.manifest.validateConfig(
          Map<String, dynamic>.from(
            (s['restoredConfig'] as Map).remove(id) as Map,
          ),
        );
      }
      _bump(s, id);
    }, expectedRevision: before);
  }

  Object? storageGet(String id, String key) {
    _storageKey(key);
    return (_map('data')[id] as Map? ?? {})[key];
  }

  void _storageKey(String key) => requirePlugin(
    RegExp(r'^[a-zA-Z0-9._-]{1,128}$').hasMatch(key),
    '存储键不合法',
    'INVALID_INPUT',
  );
  Future<void> storageWrite(
    String id,
    String key,
    Object? value, {
    required int expectedGeneration,
    bool remove = false,
  }) => _mutate((s) {
    _storageKey(key);
    requirePlugin(
      details(id).enabled && generation(id) == expectedGeneration,
      '插件已失效',
      'PLUGIN_DISABLED',
    );
    final data = Map<String, dynamic>.from(
      (s['data'] as Map)[id] as Map? ?? {},
    );
    if (remove) {
      data.remove(key);
    } else {
      data[key] = value;
    }
    requirePlugin(
      utf8.encode(jsonEncode(data)).length <= 1024 * 1024,
      '插件存储超过 1 MiB',
      'RESOURCE_LIMIT_EXCEEDED',
    );
    (s['data'] as Map)[id] = data;
  });
  Map<String, dynamic> exportData() =>
      jsonDecode(jsonEncode({..._map('sealedData'), ..._map('data')}))
          as Map<String, dynamic>;
  Map<String, dynamic> exportBackup() =>
      jsonDecode(
            jsonEncode({
              'schema': 1,
              'data': exportData(),
              'packages': {
                ..._map('retainedPackages'),
                for (final p in list())
                  if (p.source == PluginSource.external)
                    p.id: {
                      'id': p.id,
                      'name': p.name,
                      'version': p.manifest!.version,
                      'digest': p.digest,
                    },
              },
              'layout': {
                for (final field in [
                  'disabled',
                  'removedSystem',
                  'hidden',
                  'order',
                  'presentation',
                ])
                  field: _state[field],
                'config': {..._map('restoredConfig'), ..._map('config')},
              },
            }),
          )
          as Map<String, dynamic>;

  static void validateBackup(Map<String, dynamic> backup) {
    pluginFields(backup, {
      'schema',
      'data',
      'packages',
      'layout',
    }, 'INVALID_INPUT');
    requirePlugin(
      backup['schema'] == 1 &&
          utf8.encode(jsonEncode(backup)).length <= 18 * 1024 * 1024,
      '插件备份版本或大小不正确',
      'INVALID_INPUT',
    );
    validateBackupData(pluginObject(backup['data'], 'INVALID_INPUT'));
    final packages = pluginObject(backup['packages'], 'INVALID_INPUT');
    requirePlugin(packages.length <= 16, '备份插件数量超限', 'INVALID_INPUT');
    for (final e in packages.entries) {
      final m = pluginObject(e.value, 'INVALID_INPUT');
      pluginFields(m, {'id', 'name', 'version', 'digest'}, 'INVALID_INPUT');
      requirePlugin(
        e.key == m['id'] &&
            !e.key.startsWith('luotopia.') &&
            RegExp(r'^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$').hasMatch(e.key),
        '备份插件身份不正确',
        'INVALID_INPUT',
      );
      pluginText(m['name'], 128, 'INVALID_INPUT');
      pluginText(m['version'], 32, 'INVALID_INPUT');
      requirePlugin(
        m['digest'] is String &&
            RegExp(r'^[a-f0-9]{64}$').hasMatch(m['digest'] as String),
        '备份摘要不正确',
        'INVALID_INPUT',
      );
    }
    final layout = pluginObject(backup['layout'], 'INVALID_INPUT');
    pluginFields(layout, {
      'disabled',
      'removedSystem',
      'hidden',
      'order',
      'presentation',
      'config',
    }, 'INVALID_INPUT');
    requirePlugin(
      utf8.encode(jsonEncode(layout)).length <= 1024 * 1024,
      '布局备份过大',
      'INVALID_INPUT',
    );
    final disabled = pluginStrings(layout['disabled'], 1024);
    final removed = pluginStrings(layout['removedSystem'] ?? [], 1024);
    requirePlugin(
      removed.every(
        (id) => id.startsWith('luotopia.') && disabled.contains(id),
      ),
      '已移除插件状态无效',
      'INVALID_INPUT',
    );
    pluginStrings(layout['hidden'], 1024);
    final order = pluginObject(layout['order'], 'INVALID_INPUT');
    pluginFields(
      order,
      ContributionSlot.values.map((s) => s.name).toSet(),
      'INVALID_INPUT',
    );
    for (final value in order.values) {
      pluginStrings(value, 1024);
    }
    final presentation = pluginObject(layout['presentation'], 'INVALID_INPUT');
    for (final raw in presentation.values) {
      final p = pluginObject(raw, 'INVALID_INPUT');
      pluginFields(p, {'title', 'icon', 'color'}, 'INVALID_INPUT');
      if (p.containsKey('title')) pluginText(p['title'], 64, 'INVALID_INPUT');
      requirePlugin(
        !p.containsKey('icon') || pluginIcons.contains(p['icon']),
        '图标不正确',
        'INVALID_INPUT',
      );
      requirePlugin(
        !p.containsKey('color') || pluginColors.contains(p['color']),
        '颜色不正确',
        'INVALID_INPUT',
      );
    }
    final configs = pluginObject(layout['config'], 'INVALID_INPUT');
    for (final c in configs.values) {
      pluginObject(c, 'INVALID_INPUT');
    }
  }

  Future<void> restoreBackup(Map<String, dynamic> backup) =>
      _mutate((s) => _applyBackup(s, backup));

  /// Hold plugin writes while SQLite validates and commits its import. A handled
  /// database failure restores the old plugin snapshot before releasing the lock.
  Future<void> restoreBackupWithDatabase(
    Map<String, dynamic> backup,
    Future<void> Function(Future<void> Function() writePlugins) transaction,
  ) {
    final result = _queue.then((_) async {
      requirePlugin(loadError == null, '插件配置不可写，请先恢复原文件', 'PERSISTENCE_FAILED');
      final next = jsonDecode(jsonEncode(_state)) as Map<String, dynamic>;
      _applyBackup(next, backup);
      _checkCapacity(next);
      next['revision'] = revision + 1;
      var published = false;
      try {
        await transaction(() async {
          await store?.write(next);
          published = true;
        });
        requirePlugin(published, '数据库导入未提交插件快照', 'PERSISTENCE_FAILED');
        _state = next;
        _catalog = null;
        notifyListeners();
      } catch (_) {
        if (published) {
          try {
            await store?.write(_state);
          } catch (_) {
            loadError = '导入失败且磁盘无法恢复快照，原文件已保留，请恢复备份。';
            notifyListeners();
          }
        }
        rethrow;
      }
    });
    _queue = result.catchError((Object _) {});
    return result;
  }

  void _applyBackup(Map<String, dynamic> s, Map<String, dynamic> backup) {
    validateBackup(backup);
    final layout = backup['layout'] as Map;
    // Packages and grants are never restored from a backup; data remains sealed.
    s['sealedData'] = {...(s['sealedData'] as Map), ...(backup['data'] as Map)};
    s['retainedPackages'] = {
      ...(s['retainedPackages'] as Map),
      ...(backup['packages'] as Map),
    };
    // Withdraw code and grants for restored namespaces; their backup data stays
    // sealed until the same package ID is explicitly imported and approved again.
    for (final id in {
      ...(backup['packages'] as Map).keys,
      ...(backup['data'] as Map).keys,
    }) {
      (s['external'] as Map).remove(id);
      (s['data'] as Map).remove(id);
      (s['config'] as Map).remove(id);
    }
    s['disabled'] = [
      ..._list('disabled').where((id) => !id.startsWith('luotopia.')),
      ...(layout['disabled'] as List).where(
        (id) => (id as String).startsWith('luotopia.'),
      ),
    ];
    s['removedSystem'] = layout['removedSystem'] ?? [];
    s['hidden'] = layout['hidden'];
    s['order'] = layout['order'];
    s['presentation'] = layout['presentation'];
    // Configuration is inert metadata until an external package is imported again.
    s['restoredConfig'] = layout['config'];
    for (final p in list()) {
      _bump(s, p.id);
    }
  }

  static void validateBackupData(Map<String, dynamic> data) {
    requirePlugin(data.length <= 16, '备份插件数量超限', 'INVALID_INPUT');
    for (final e in data.entries) {
      requirePlugin(
        e.key.length <= 96 &&
            RegExp(r'^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$').hasMatch(e.key) &&
            !e.key.startsWith('luotopia.') &&
            e.value is Map<String, dynamic> &&
            utf8.encode(jsonEncode(e.value)).length <= 1024 * 1024,
        '插件备份格式不正确',
        'INVALID_INPUT',
      );
      requirePlugin(
        (e.value as Map).keys.every(
          (k) => k is String && RegExp(r'^[a-zA-Z0-9._-]{1,128}$').hasMatch(k),
        ),
        '备份存储键不合法',
        'INVALID_INPUT',
      );
    }
  }

  Future<void> restoreData(Map<String, dynamic> data) => _mutate((s) {
    validateBackupData(data);
    s['sealedData'] = {...(s['sealedData'] as Map), ...data};
    for (final id in data.keys) {
      final existing = _map('external')[id];
      if (existing != null) {
        final p = details(id);
        (s['retainedPackages'] as Map)[id] = {
          'id': id,
          'name': p.name,
          'version': p.manifest!.version,
          'digest': p.digest,
        };
      }
      (s['external'] as Map).remove(id);
      (s['data'] as Map).remove(id);
      (s['config'] as Map).remove(id);
      _bump(s, id);
    }
  });

  Set<String> _namespaceIds(Map<String, dynamic> state) => {
    for (final key in ['external', 'data', 'sealedData', 'retainedPackages'])
      ...(state[key] as Map).keys.cast<String>(),
  };
  void _checkCapacity(Map<String, dynamic> state) => requirePlugin(
    _namespaceIds(state).length <= 16,
    '活动和保留插件合计超过 16 个，请先清理保留数据',
    'RESOURCE_LIMIT_EXCEEDED',
  );
  Future<void> forgetRetainedData(String id) => _mutate((s) {
    (s['sealedData'] as Map).remove(id);
    (s['retainedPackages'] as Map).remove(id);
    (s['restoredConfig'] as Map).remove(id);
    if (!(s['external'] as Map).containsKey(id)) {
      (s['config'] as Map).remove(id);
    }
  });
}
