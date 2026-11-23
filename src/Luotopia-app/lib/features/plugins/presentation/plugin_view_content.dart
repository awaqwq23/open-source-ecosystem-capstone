import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import '../domain/plugin_error.dart';
import '../domain/plugin_view.dart';

class PluginViewContent extends StatefulWidget {
  const PluginViewContent({
    super.key,
    required this.view,
    required this.onAction,
    this.busy = false,
  });
  final PluginView view;
  final Future<void> Function(String actionId, Map<String, dynamic> input)
  onAction;
  final bool busy;

  @override
  State<PluginViewContent> createState() => _PluginViewContentState();
}

class _PluginViewContentState extends State<PluginViewContent> {
  final _controllers = <String, TextEditingController>{};
  final _values = <String, dynamic>{};
  bool _submitting = false;
  String? _error;
  bool get _busy => widget.busy || _submitting;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant PluginViewContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.view, widget.view)) _reset();
  }

  void _reset() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _values.clear();
    _error = null;
    for (final node in widget.view.nodes) {
      final id = node['id'] as String;
      if (node['type'] == 'input' || node['type'] == 'number') {
        _controllers[id] = TextEditingController(
          text: node['value'].toString(),
        );
      } else if (node['type'] == 'toggle' || node['type'] == 'select') {
        _values[id] = node['value'];
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(String actionId) async {
    if (_busy) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final input = <String, dynamic>{..._values};
      for (final node in widget.view.nodes) {
        final id = node['id'] as String;
        if (node['type'] == 'input') input[id] = _controllers[id]!.text;
        if (node['type'] == 'number') {
          final raw = _controllers[id]!.text;
          input[id] = num.tryParse(raw) ?? raw;
        }
      }
      await widget.onAction(
        actionId,
        widget.view.validateAction(actionId, input),
      );
    } on PluginException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = '操作失败，请重试。');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _node(Map<String, dynamic> node) {
    final id = node['id'] as String;
    final key = ValueKey('plugin-field-$id');
    switch (node['type']) {
      case 'text':
        final colors = ui.Theme.of(context).colorScheme;
        return Text(
          node['text'] as String,
          style: TextStyle(
            color: switch (node['tone']) {
              'error' => colors.destructive,
              'muted' => colors.mutedForeground,
              _ => colors.foreground,
            },
          ),
        );
      case 'input':
      case 'number':
        return TextField(
          key: key,
          controller: _controllers[id],
          enabled: !_busy,
          decoration: InputDecoration(labelText: node['label'] as String),
          keyboardType: node['type'] == 'number'
              ? const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                )
              : (node['multiline'] == true
                    ? TextInputType.multiline
                    : TextInputType.text),
          maxLines: node['multiline'] == true ? 4 : 1,
          // Validate on submit instead of silently truncating business input.
        );
      case 'toggle':
        return SwitchListTile(
          key: key,
          title: Text(node['label'] as String),
          value: _values[id] as bool,
          onChanged: _busy
              ? null
              : (value) => setState(() => _values[id] = value),
        );
      case 'select':
        return DropdownButtonFormField<String>(
          key: key,
          initialValue: _values[id] as String,
          decoration: InputDecoration(labelText: node['label'] as String),
          items: [
            for (final option in node['options'] as List)
              DropdownMenuItem(
                value: option['value'] as String,
                child: Text(option['label'] as String),
              ),
          ],
          onChanged: _busy
              ? null
              : (value) {
                  if (value != null) setState(() => _values[id] = value);
                },
        );
      case 'button':
        final child = Text(node['label'] as String);
        final action = _busy ? null : () => _submit(node['actionId'] as String);
        return node['style'] == 'secondary'
            ? ui.SecondaryButton(onPressed: action, child: child)
            : ui.PrimaryButton(onPressed: action, child: child);
      case 'list':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in node['items'] as List)
              ListTile(
                title: Text(item['title'] as String),
                subtitle: item['subtitle'] == null
                    ? null
                    : Text(item['subtitle'] as String),
              ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ui.Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                widget.view.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final node in widget.view.nodes)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _node(node),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(color: colors.destructive),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
