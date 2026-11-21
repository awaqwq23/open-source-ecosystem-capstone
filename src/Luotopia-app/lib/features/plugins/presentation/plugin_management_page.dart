import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import '../application/plugin_manager.dart';
import '../data/plugin_package_picker.dart';
import '../domain/plugin_error.dart';
import '../domain/builtin_plugins.dart';
import '../domain/plugin_manifest.dart';
import '../runtime/plugin_session.dart';

class PluginManagementPage extends ConsumerStatefulWidget {
  const PluginManagementPage({super.key});
  @override
  ConsumerState<PluginManagementPage> createState() =>
      _PluginManagementPageState();
}

class _PluginManagementPageState extends ConsumerState<PluginManagementPage> {
  bool _busy = false;
  String? _message;
  Future<void> _run(Future<void> Function() task) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await task();
    } catch (e) {
      if (mounted) {
        setState(
          () => _message = e is PluginException ? e.toString() : '操作失败，请重试',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, Widget content) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _import() => _run(() async {
    final package = await pickPluginPackage();
    if (package == null) return;
    if (!mounted) return;
    final manager = ref.read(pluginManagerProvider);
    final update = manager.list().any((p) => p.id == package.manifest.id);
    var reuse = false;
    final retained = manager.hasRetainedData(package.manifest.id);
    final retainedDigest = manager.retainedDigest(package.manifest.id);
    final accepted = await _confirm(
      update ? '更新插件与授权' : '导入插件与授权',
      StatefulBuilder(
        builder: (context, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${package.manifest.name}  ${package.manifest.version}'),
            Text(package.manifest.id),
            const SizedBox(height: 12),
            Text(package.manifest.description),
            const SizedBox(height: 12),
            const Text('申请权限'),
            Text(
              package.manifest.permissions.isEmpty
                  ? '无'
                  : package.manifest.permissions
                        .map(
                          (p) =>
                              p == 'storage.self' ? '读写本插件数据' : '访问指定 HTTPS 网站',
                        )
                        .join('\n'),
            ),
            if (package.manifest.networkHosts.isNotEmpty)
              Text(package.manifest.networkHosts.join('\n')),
            const SizedBox(height: 12),
            const Text('新增入口'),
            for (final c in package.manifest.contributions)
              Text('${_slotName(c.slot)} · ${c.title}'),
            const SizedBox(height: 12),
            Text(
              'SHA-256：${package.digest}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Text('摘要用于识别文件，不证明作者身份。仅导入你信任来源的插件。'),
            if (retainedDigest != null && retainedDigest != package.digest)
              Text('注意：保留数据的原插件摘要为 $retainedDigest，本次文件不同。请核实来源后再决定是否复用数据。'),
            if (retained)
              CheckboxListTile(
                value: reuse,
                onChanged: (v) => setDialogState(() => reuse = v ?? false),
                title: const Text('允许此插件读取保留/恢复的数据'),
                subtitle: const Text('相同标识不能证明是同一作者，默认不允许'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
    if (!accepted) return;
    await manager.install(
      package,
      approvedPermissions: package.manifest.permissions.toSet(),
      validate: PluginSession.validatePackage,
      update: update,
      reuseData: reuse,
    );
    if (mounted) {
      setState(
        () => _message =
            '${package.manifest.name} 已${update ? '更新' : '导入'}，入口立即生效',
      );
    }
  });

  Future<void> _edit(PluginContribution c) async {
    final controller = TextEditingController(text: c.title);
    var icon = pluginIcons.contains(c.icon) ? c.icon : 'star';
    var color = pluginColors.contains(c.color) ? c.color : 'sky';
    try {
      final ok = await _confirm(
        '编辑入口',
        StatefulBuilder(
          builder: (context, update) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLength: 64,
                decoration: const InputDecoration(labelText: '显示名称'),
              ),
              DropdownButtonFormField<String>(
                initialValue: icon,
                decoration: const InputDecoration(labelText: '图标'),
                items: [
                  for (final value in pluginIcons)
                    DropdownMenuItem(value: value, child: Text(value)),
                ],
                onChanged: (v) => update(() => icon = v!),
              ),
              if (c.slot == ContributionSlot.campusCard)
                DropdownButtonFormField<String>(
                  initialValue: color,
                  decoration: const InputDecoration(labelText: '颜色'),
                  items: [
                    for (final value in pluginColors)
                      DropdownMenuItem(value: value, child: Text(value)),
                  ],
                  onChanged: (v) => update(() => color = v!),
                ),
            ],
          ),
        ),
      );
      if (ok && mounted) {
        await _run(
          () => ref.read(pluginManagerProvider).updatePresentation(c.key, {
            'title': controller.text.trim(),
            'icon': icon,
            if (c.slot == ContributionSlot.campusCard) 'color': color,
          }),
        );
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _configure(PluginSummary p) async {
    final fields = p.manifest!.config;
    final values = ref.read(pluginManagerProvider).configuration(p.id);
    final controllers = <String, TextEditingController>{
      for (final c in fields)
        if (c['type'] == 'text' || c['type'] == 'number')
          c['key'] as String: TextEditingController(
            text: '${values[c['key']]}',
          ),
    };
    try {
      final ok = await _confirm(
        '插件配置',
        StatefulBuilder(
          builder: (context, update) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final c in fields)
                if (c['type'] == 'boolean')
                  SwitchListTile(
                    title: Text(c['label'] as String),
                    value: values[c['key']] as bool,
                    onChanged: (v) =>
                        update(() => values[c['key'] as String] = v),
                  )
                else if (c['type'] == 'choice')
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: c['label'] as String,
                    ),
                    initialValue: values[c['key']] as String,
                    items: [
                      for (final o in c['options'] as List)
                        DropdownMenuItem(
                          value: o['value'] as String,
                          child: Text(o['label'] as String),
                        ),
                    ],
                    onChanged: (v) =>
                        update(() => values[c['key'] as String] = v),
                  )
                else
                  TextField(
                    controller: controllers[c['key']],
                    keyboardType: c['type'] == 'number'
                        ? const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          )
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: c['label'] as String,
                    ),
                    maxLength: c['type'] == 'text'
                        ? c['maxLength'] as int
                        : null,
                  ),
            ],
          ),
        ),
      );
      if (ok && mounted) {
        await _run(() async {
          for (final c in fields) {
            final text = controllers[c['key']]?.text;
            if (text != null) {
              values[c['key'] as String] = c['type'] == 'number'
                  ? num.tryParse(text)
                  : text;
            }
          }
          await ref.read(pluginManagerProvider).updateConfig(p.id, values);
        });
      }
    } finally {
      for (final c in controllers.values) {
        c.dispose();
      }
    }
  }

  Future<void> _move(PluginManager manager, PluginContribution c, int delta) =>
      _run(() async {
        final keys = manager.entries(c.slot).map((c) => c.key).toList();
        final index = keys.indexOf(c.key);
        final target = index + delta;
        if (target < 0 ||
            target >= keys.length ||
            manager.contribution(keys[target]).protected ||
            (c.slot == ContributionSlot.settingsRow &&
                settingsGroupFor(c.pluginId) !=
                    settingsGroupFor(
                      manager.contribution(keys[target]).pluginId,
                    ))) {
          return;
        }
        keys.removeAt(index);
        keys.insert(target, c.key);
        await manager.reorder(c.slot, keys, expectedRevision: manager.revision);
      });
  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(pluginManagerProvider);
    return ui.Scaffold(
      headers: [buildSecondaryAppBar(context, title: '插件管理')],
      child: Material(
        type: MaterialType.transparency,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ui.PrimaryButton(
                  onPressed: _busy ? null : _import,
                  child: const Text('导入外部插件'),
                ),
                ui.SecondaryButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() => manager.restoreDefaultLayout()),
                  child: const Text('恢复默认布局'),
                ),
              ],
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(12),
                child: LinearProgressIndicator(),
              ),
            if (manager.loadError != null) Text(manager.loadError!),
            for (final id in manager.pendingImports)
              ListTile(
                title: Text(id),
                subtitle: const Text('待重新导入 · 数据已封存，尚未授权新插件读取'),
                trailing: IconButton(
                  tooltip: '删除保留数据',
                  icon: const Icon(Icons.delete_forever_outlined),
                  onPressed: _busy
                      ? null
                      : () async {
                          if (await _confirm(
                                '永久删除保留数据',
                                Text('将删除 $id 的保留数据和恢复配置，此操作不能撤销。'),
                              ) &&
                              mounted) {
                            await _run(() => manager.forgetRetainedData(id));
                          }
                        },
                ),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_message!),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('已安装与系统插件'),
            ),
            for (final p in manager.list())
              Card(
                child: ExpansionTile(
                  key: ValueKey(p.id),
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.source == PluginSource.core
                        ? '核心 · 必须保留'
                        : p.source == PluginSource.system
                        ? '系统默认 · 可恢复'
                        : p.manifest!.version} · ${p.enabled ? '已启用' : '已停用'}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(p.id),
                          if (p.source == PluginSource.external) ...[
                            Text(p.manifest!.description),
                            Text('权限：${p.manifest!.permissions.join('、')}'),
                            if (p.manifest!.networkHosts.isNotEmpty)
                              Text('网站：${p.manifest!.networkHosts.join('、')}'),
                          ],
                          if (p.source != PluginSource.core)
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _run(
                                          () =>
                                              p.source == PluginSource.system &&
                                                  !p.enabled
                                              ? manager.restoreBuiltin(p.id)
                                              : manager.setEnabled(
                                                  p.id,
                                                  !p.enabled,
                                                ),
                                        ),
                                  child: Text(p.enabled ? '停用' : '启用 / 恢复'),
                                ),
                                TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () async {
                                          if (await _confirm(
                                                '删除插件',
                                                Text(
                                                  '${p.name} 的入口将移除，业务数据保留。系统插件可再次添加。',
                                                ),
                                              ) &&
                                              mounted) {
                                            await _run(
                                              () => manager.uninstall(p.id),
                                            );
                                          }
                                        },
                                  child: const Text('删除'),
                                ),
                                if (p.manifest?.config.isNotEmpty == true)
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _configure(p),
                                    child: const Text('配置'),
                                  ),
                              ],
                            ),
                          for (final original in p.contributions)
                            Builder(
                              builder: (context) {
                                final c = manager.contribution(original.key);
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${_slotName(c.slot)} · ${c.title}',
                                  ),
                                  subtitle: Text(
                                    c.protected
                                        ? '核心入口'
                                        : manager.isVisible(c.key)
                                        ? '显示中'
                                        : '已隐藏',
                                  ),
                                  trailing: c.protected
                                      ? const Icon(Icons.lock_outline)
                                      : Wrap(
                                          children: [
                                            IconButton(
                                              tooltip: '编辑 ${c.title}',
                                              onPressed: _busy
                                                  ? null
                                                  : () => _edit(c),
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: manager.isVisible(c.key)
                                                  ? '隐藏 ${c.title}'
                                                  : '显示 ${c.title}',
                                              onPressed: _busy
                                                  ? null
                                                  : () => _run(
                                                      () => manager
                                                          .setContributionVisible(
                                                            c.key,
                                                            !manager.isVisible(
                                                              c.key,
                                                            ),
                                                          ),
                                                    ),
                                              icon: Icon(
                                                manager.isVisible(c.key)
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            for (final slot in ContributionSlot.values) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('${_slotName(slot)}排序'),
              ),
              for (final c in manager.entries(slot))
                ListTile(
                  title: Text(c.title),
                  trailing: c.protected
                      ? const Icon(Icons.lock_outline)
                      : Wrap(
                          children: [
                            IconButton(
                              tooltip: '上移 ${c.title}',
                              onPressed: _busy
                                  ? null
                                  : () => _move(manager, c, -1),
                              icon: const Icon(Icons.arrow_upward),
                            ),
                            IconButton(
                              tooltip: '下移 ${c.title}',
                              onPressed: _busy
                                  ? null
                                  : () => _move(manager, c, 1),
                              icon: const Icon(Icons.arrow_downward),
                            ),
                          ],
                        ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

String _slotName(ContributionSlot slot) => switch (slot) {
  ContributionSlot.navigation => '导航栏',
  ContributionSlot.campusCard => '校园卡片',
  ContributionSlot.settingsRow => '设置行',
};
