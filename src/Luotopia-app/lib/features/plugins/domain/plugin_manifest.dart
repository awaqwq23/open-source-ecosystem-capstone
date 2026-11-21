import 'dart:convert';
import 'plugin_error.dart';

enum ContributionSlot { navigation, campusCard, settingsRow }

enum PluginSource { core, system, external }

const pluginIcons = {
  'timer',
  'tune',
  'home',
  'list',
  'forum',
  'school',
  'settings',
  'book',
  'calendar',
  'star',
  'code',
  'cloud',
  'chart',
  'info',
};
const pluginColors = {
  'sky',
  'blue',
  'green',
  'amber',
  'purple',
  'pink',
  'slate',
};
final localIdPattern = RegExp(r'^[a-z][a-z0-9_-]{0,47}$');

void requirePlugin(
  bool condition,
  String message, [
  String code = 'INVALID_PACKAGE',
]) {
  if (!condition) pluginFail(code, message);
}

Map<String, dynamic> pluginObject(
  Object? value, [
  String code = 'INVALID_PACKAGE',
]) {
  requirePlugin(value is Map<String, dynamic>, '需要 JSON 对象', code);
  return value as Map<String, dynamic>;
}

void pluginFields(
  Map<String, dynamic> value,
  Set<String> allowed, [
  String code = 'INVALID_PACKAGE',
]) {
  requirePlugin(value.keys.every(allowed.contains), '包含不支持的字段', code);
}

String pluginText(Object? value, int max, [String code = 'INVALID_PACKAGE']) {
  requirePlugin(
    value is String && value.isNotEmpty && value.length <= max,
    '文本为空或超出长度限制',
    code,
  );
  return value as String;
}

List<String> pluginStrings(Object? value, int max) {
  requirePlugin(
    value is List && value.length <= max && value.every((e) => e is String),
    '列表格式不正确',
  );
  final result = List<String>.from(value as List);
  requirePlugin(result.toSet().length == result.length, '列表不能包含重复值');
  return List.unmodifiable(result);
}

class PluginContribution {
  const PluginContribution({
    required this.pluginId,
    required this.id,
    required this.slot,
    required this.title,
    required this.icon,
    this.viewId = 'main',
    this.allowedViews = const ['main'],
    this.size = 'small',
    this.color = 'sky',
    this.nativeRoute,
    this.protected = false,
  });
  final String pluginId, id, title, icon, viewId, size, color;
  final ContributionSlot slot;
  final List<String> allowedViews;
  final String? nativeRoute;
  final bool protected;
  String get key => '$pluginId/$id';
  String get route => nativeRoute ?? '/plugins/$pluginId/$id/$viewId';
  PluginContribution present(Map<String, dynamic> override) => protected
      ? this
      : PluginContribution(
          pluginId: pluginId,
          id: id,
          slot: slot,
          title: override['title'] as String? ?? title,
          icon: override['icon'] as String? ?? icon,
          viewId: viewId,
          allowedViews: allowedViews,
          size: size,
          color: override['color'] as String? ?? color,
          nativeRoute: nativeRoute,
          protected: protected,
        );
  Map<String, dynamic> toJson() => {
    'id': id,
    'slot': slot.name,
    'title': title,
    'icon': icon,
    'viewId': viewId,
    'allowedViews': allowedViews,
    if (slot == ContributionSlot.campusCard) ...{'size': size, 'color': color},
    if (slot == ContributionSlot.settingsRow) 'group': 'extensions',
  };
}

class PluginManifest {
  PluginManifest._(this._json, this.contributions, this.config);
  final Map<String, dynamic> _json;
  final List<PluginContribution> contributions;
  final List<Map<String, dynamic>> config;
  String get id => _json['id'] as String;
  String get name => _json['name'] as String;
  String get version => _json['version'] as String;
  String get description => _json['description'] as String;
  List<String> get permissions =>
      List<String>.from(_json['permissions'] as List);
  List<String> get networkHosts =>
      List<String>.from(_json['networkHosts'] as List);
  List<String> get views => List<String>.from(_json['views'] as List);
  Map<String, dynamic> get defaultConfig => {
    for (final c in config) c['key'] as String: c['default'],
  };
  Map<String, dynamic> toJson() =>
      jsonDecode(jsonEncode(_json)) as Map<String, dynamic>;

  factory PluginManifest.fromJson(Object? value) {
    final m = pluginObject(value);
    pluginFields(m, {
      'schemaVersion',
      'apiVersion',
      'id',
      'name',
      'version',
      'entry',
      'description',
      'author',
      'license',
      'permissions',
      'networkHosts',
      'views',
      'contributions',
      'config',
    });
    requirePlugin(
      m['schemaVersion'] == 1 && m['apiVersion'] == 1,
      '插件接口版本不兼容',
      'UNSUPPORTED_API',
    );
    final id = pluginText(m['id'], 96);
    requirePlugin(!id.startsWith('luotopia.'), '内置插件标识不可使用', 'RESERVED_ID');
    requirePlugin(
      RegExp(r'^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$').hasMatch(id),
      '插件标识不正确',
    );
    for (final field in ['name', 'description', 'author', 'license']) {
      pluginText(m[field], field == 'description' ? 2000 : 128);
    }
    requirePlugin(
      RegExp(
        r'^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$',
      ).hasMatch(pluginText(m['version'], 32)),
      '版本应为 major.minor.patch',
    );
    requirePlugin(m['entry'] == 'main.js', '入口必须为 main.js');
    final permissions = pluginStrings(m['permissions'], 2);
    requirePlugin(
      permissions.every({'storage.self', 'network.https'}.contains),
      '权限不受支持',
    );
    final hosts = pluginStrings(m['networkHosts'], 16);
    requirePlugin(
      hosts.isEmpty || permissions.contains('network.https'),
      '网络主机必须声明网络权限',
    );
    requirePlugin(
      hosts.every(
        (h) =>
            h.length <= 253 &&
            RegExp(
              r'^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$',
            ).hasMatch(h),
      ),
      '仅接受精确的规范域名',
    );
    final views = pluginStrings(m['views'], 32);
    requirePlugin(
      views.isNotEmpty && views.every(localIdPattern.hasMatch),
      '页面标识不正确',
    );
    requirePlugin(
      m['contributions'] is List &&
          (m['contributions'] as List).isNotEmpty &&
          (m['contributions'] as List).length <= 32,
      '贡献数量应为 1–32',
    );
    final seen = <String>{};
    final contributions = <PluginContribution>[];
    for (final raw in m['contributions'] as List) {
      final c = pluginObject(raw);
      pluginFields(c, {
        'id',
        'slot',
        'title',
        'icon',
        'viewId',
        'allowedViews',
        'size',
        'color',
        'group',
      });
      final cid = pluginText(c['id'], 48);
      requirePlugin(localIdPattern.hasMatch(cid), '贡献标识不正确');
      requirePlugin(seen.add(cid), '贡献标识重复', 'DUPLICATE_CONTRIBUTION');
      requirePlugin(
        ContributionSlot.values.any((s) => s.name == c['slot']),
        '贡献位置不受支持',
      );
      final slot = ContributionSlot.values.byName(c['slot'] as String);
      final allowed = pluginStrings(c['allowedViews'], 32);
      requirePlugin(
        allowed.contains(c['viewId']) && allowed.every(views.contains),
        '贡献必须明确允许根页面及所有子页面',
      );
      requirePlugin(pluginIcons.contains(c['icon']), '图标不受支持');
      requirePlugin(
        c['size'] == null ||
            (slot == ContributionSlot.campusCard &&
                {'small', 'wide'}.contains(c['size'])),
        '卡片尺寸不正确',
      );
      requirePlugin(
        c['color'] == null ||
            (slot == ContributionSlot.campusCard &&
                pluginColors.contains(c['color'])),
        '卡片颜色不正确',
      );
      requirePlugin(
        c['group'] == null ||
            (slot == ContributionSlot.settingsRow &&
                c['group'] == 'extensions'),
        '设置分组不正确',
      );
      contributions.add(
        PluginContribution(
          pluginId: id,
          id: cid,
          slot: slot,
          title: pluginText(c['title'], 64),
          icon: c['icon'] as String,
          viewId: c['viewId'] as String,
          allowedViews: allowed,
          size: c['size'] as String? ?? 'small',
          color: c['color'] as String? ?? 'sky',
        ),
      );
    }
    requirePlugin(
      m['config'] is List && (m['config'] as List).length <= 32,
      '配置数量超限',
    );
    final configs = <Map<String, dynamic>>[];
    final keys = <String>{};
    for (final raw in m['config'] as List) {
      final c = pluginObject(raw);
      pluginFields(c, {
        'key',
        'type',
        'label',
        'default',
        'min',
        'max',
        'maxLength',
        'options',
      });
      final key = pluginText(c['key'], 48);
      requirePlugin(
        RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{0,47}$').hasMatch(key) && keys.add(key),
        '配置标识不正确或重复',
      );
      pluginText(c['label'], 128);
      validatePluginField(c, c['default'], 'INVALID_PACKAGE');
      configs.add(
        Map.unmodifiable({
          ...c,
          if (c['options'] is List)
            'options': List.unmodifiable(
              (c['options'] as List).map(
                (o) => Map<String, dynamic>.unmodifiable(
                  o as Map<String, dynamic>,
                ),
              ),
            ),
        }),
      );
    }
    return PluginManifest._(
      jsonDecode(jsonEncode(m)) as Map<String, dynamic>,
      List.unmodifiable(contributions),
      List.unmodifiable(configs),
    );
  }

  Map<String, dynamic> validateConfig(Map<String, dynamic> values) {
    requirePlugin(
      values.keys.every((k) => config.any((c) => c['key'] == k)),
      '未知配置项',
      'INVALID_INPUT',
    );
    final result = {...defaultConfig, ...values};
    for (final c in config) {
      validatePluginField(c, result[c['key']], 'INVALID_INPUT');
    }
    return result;
  }
}

void validatePluginField(
  Map<String, dynamic> field,
  Object? value,
  String code,
) {
  bool finite(Object? v) => v is num && v.isFinite;
  switch (field['type']) {
    case 'text':
    case 'input':
      requirePlugin(
        field['maxLength'] is int &&
            (field['maxLength'] as int) > 0 &&
            (field['maxLength'] as int) <= 4096 &&
            value is String &&
            value.length <= (field['maxLength'] as int),
        '文本超出长度限制',
        code,
      );
    case 'number':
      requirePlugin(
        finite(field['min']) &&
            finite(field['max']) &&
            (field['min'] as num) <= (field['max'] as num) &&
            finite(value) &&
            (value as num) >= (field['min'] as num) &&
            value <= (field['max'] as num),
        '数值不在允许范围内',
        code,
      );
    case 'boolean':
    case 'toggle':
      requirePlugin(value is bool, '需要布尔值', code);
    case 'choice':
    case 'select':
      final opts = field['options'];
      requirePlugin(
        opts is List && opts.isNotEmpty && opts.length <= 100,
        '选项不正确',
        code,
      );
      final keys = <String>{};
      for (final raw in opts as List) {
        final opt = pluginObject(raw, code);
        pluginFields(opt, {'value', 'label'}, code);
        requirePlugin(
          keys.add(pluginText(opt['value'], 128, code)),
          '选项重复',
          code,
        );
        pluginText(opt['label'], 128, code);
      }
      requirePlugin(value is String && keys.contains(value), '值不属于允许选项', code);
    default:
      pluginFail(code, '不支持的字段类型');
  }
}
