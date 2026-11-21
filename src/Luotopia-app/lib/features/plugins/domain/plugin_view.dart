import 'dart:convert';
import 'dart:collection';
import 'plugin_manifest.dart';

// Walk before encoding, so cycles, non-JSON values and deep data cannot reach
// jsonEncode or a renderer unchecked.
void _jsonBudget(Object? value, int bytes, String code) {
  final active = HashSet<Object>.identity();
  void visit(Object? item, int depth) {
    requirePlugin(depth <= 16, 'JSON 嵌套过深', code);
    if (item == null || item is String || item is bool) return;
    if (item is num) {
      requirePlugin(item.isFinite, '数值必须有限', code);
      return;
    }
    requirePlugin(
      item is List || item is Map<String, dynamic>,
      '只接受 JSON 数据',
      code,
    );
    requirePlugin(active.add(item), 'JSON 不能包含循环引用', code);
    if (item is List) {
      for (final child in item) {
        visit(child, depth + 1);
      }
    } else {
      for (final child in (item as Map<String, dynamic>).values) {
        visit(child, depth + 1);
      }
    }
    active.remove(item);
  }

  visit(value, 0);
  requirePlugin(
    utf8.encode(jsonEncode(value)).length <= bytes,
    'JSON 数据超出大小限制',
    code,
  );
}

String _id(Object? value) => pluginText(value, 128, 'INVALID_VIEW');
String _text(Object? value, [int max = 4096]) {
  requirePlugin(
    value is String && value.length <= max,
    '文本超出长度限制',
    'INVALID_VIEW',
  );
  return value as String;
}

class PluginView {
  PluginView._(this.title, this.nodes);
  final String title;
  final List<Map<String, dynamic>> nodes;

  factory PluginView.fromJson(Object? value) {
    _jsonBudget(value, 256 * 1024, 'INVALID_VIEW');
    final object = pluginObject(value, 'INVALID_VIEW');
    pluginFields(object, {'title', 'nodes'}, 'INVALID_VIEW');
    final title = pluginText(object['title'], 128, 'INVALID_VIEW');
    requirePlugin(
      object['nodes'] is List && (object['nodes'] as List).length <= 100,
      '节点数量超限',
      'INVALID_VIEW',
    );
    final nodes = <Map<String, dynamic>>[];
    final ids = <String>{};
    for (final raw in object['nodes'] as List) {
      final node = pluginObject(raw, 'INVALID_VIEW');
      requirePlugin(ids.add(_id(node['id'])), '节点标识重复', 'INVALID_VIEW');
      final common = {'type', 'id'};
      switch (node['type']) {
        case 'text':
          pluginFields(node, {...common, 'text', 'tone'}, 'INVALID_VIEW');
          _text(node['text']);
          requirePlugin(
            !node.containsKey('tone') ||
                {'normal', 'muted', 'error'}.contains(node['tone']),
            '文本样式不受支持',
            'INVALID_VIEW',
          );
        case 'input':
        case 'number':
        case 'toggle':
        case 'select':
          final extra = switch (node['type']) {
            'input' => {'maxLength', 'multiline'},
            'number' => {'min', 'max'},
            'select' => {'options'},
            _ => <String>{},
          };
          pluginFields(node, {
            ...common,
            'label',
            'value',
            ...extra,
          }, 'INVALID_VIEW');
          pluginText(node['label'], 128, 'INVALID_VIEW');
          requirePlugin(
            !node.containsKey('multiline') || node['multiline'] is bool,
            'multiline 必须是布尔值',
            'INVALID_VIEW',
          );
          validatePluginField(node, node['value'], 'INVALID_VIEW');
        case 'button':
          pluginFields(node, {
            ...common,
            'label',
            'actionId',
            'style',
          }, 'INVALID_VIEW');
          pluginText(node['label'], 128, 'INVALID_VIEW');
          _id(node['actionId']);
          requirePlugin(
            !node.containsKey('style') ||
                {'primary', 'secondary'}.contains(node['style']),
            '按钮样式不受支持',
            'INVALID_VIEW',
          );
        case 'list':
          pluginFields(node, {...common, 'items'}, 'INVALID_VIEW');
          requirePlugin(
            node['items'] is List && (node['items'] as List).length <= 200,
            '列表行数超限',
            'INVALID_VIEW',
          );
          final itemIds = <String>{};
          for (final rawItem in node['items'] as List) {
            final item = pluginObject(rawItem, 'INVALID_VIEW');
            pluginFields(item, {'id', 'title', 'subtitle'}, 'INVALID_VIEW');
            requirePlugin(
              itemIds.add(_id(item['id'])),
              '列表标识重复',
              'INVALID_VIEW',
            );
            _text(item['title']);
            if (item.containsKey('subtitle')) _text(item['subtitle']);
          }
        default:
          requirePlugin(false, '不支持的节点类型', 'INVALID_VIEW');
      }
      // Snapshot nested options/items too, so plugin-owned maps cannot mutate
      // an already validated view after parsing.
      nodes.add(_freezeJson(node) as Map<String, dynamic>);
    }
    return PluginView._(title, List.unmodifiable(nodes));
  }

  Map<String, dynamic> validateAction(
    String actionId,
    Map<String, dynamic> input,
  ) {
    requirePlugin(
      nodes.any((n) => n['type'] == 'button' && n['actionId'] == actionId),
      '操作不属于当前界面',
      'INVALID_INPUT',
    );
    _jsonBudget(input, 64 * 1024, 'INVALID_INPUT');
    final fields = nodes.where(
      (n) => {'input', 'number', 'toggle', 'select'}.contains(n['type']),
    );
    final ids = fields.map((n) => n['id'] as String).toSet();
    requirePlugin(
      input.keys.toSet().containsAll(ids) && ids.containsAll(input.keys),
      '表单字段不完整或包含未知字段',
      'INVALID_INPUT',
    );
    for (final field in fields) {
      validatePluginField(field, input[field['id']], 'INVALID_INPUT');
    }
    return Map<String, dynamic>.unmodifiable(input);
  }
}

Object? _freezeJson(Object? value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.unmodifiable(
      value.map((key, item) => MapEntry(key, _freezeJson(item))),
    );
  }
  if (value is List) {
    return List<dynamic>.unmodifiable(value.map(_freezeJson));
  }
  return value;
}

class PluginResult {
  PluginResult._(this.state, this.view);
  final Object? state;
  final PluginView view;
  factory PluginResult.fromJson(Object? value) {
    _jsonBudget(value, 256 * 1024, 'INVALID_VIEW');
    final object = pluginObject(value, 'INVALID_VIEW');
    pluginFields(object, {'state', 'view'}, 'INVALID_VIEW');
    requirePlugin(
      object.containsKey('state') && object.containsKey('view'),
      '结果缺少 state 或 view',
      'INVALID_VIEW',
    );
    _jsonBudget(object['state'], 64 * 1024, 'INVALID_VIEW');
    return PluginResult._(
      _freezeJson(object['state']),
      PluginView.fromJson(object['view']),
    );
  }
}
