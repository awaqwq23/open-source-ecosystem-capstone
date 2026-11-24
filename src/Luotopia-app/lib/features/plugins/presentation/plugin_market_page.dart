import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'plugin_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/plugin_manager.dart';
import '../data/plugin_market_service.dart';
import '../data/plugin_package.dart';
import '../domain/plugin_error.dart';

class PluginMarketPage extends ConsumerStatefulWidget {
  const PluginMarketPage({super.key});
  @override
  ConsumerState<PluginMarketPage> createState() => _PluginMarketPageState();
}

class _PluginMarketPageState extends ConsumerState<PluginMarketPage> {
  final _repository = TextEditingController();
  final _service = PluginMarketService();
  final List<PluginPackage> _local = [];
  List<String> _catalogue = [];
  List<PluginMarketAsset> _assets = [];
  final Map<String, PluginPackage> _previews = {};
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _run(() async {
      for (final file in ['study-time-1.0.0', 'school-timetable-1.0.0']) {
        final bytes = await rootBundle.load('assets/market/$file.luoplugin');
        final package = PluginPackage.decode(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
        if (!mounted) return;
        _local.add(package);
      }
    });
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() task) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await task();
    } catch (e) {
      if (mounted) _message = e is PluginException ? e.toString() : '操作失败，请重试';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _search() => _run(() async {
    _assets = [];
    _previews.clear();
    final assets = await _service.discover(_repository.text);
    if (!mounted) return;
    _assets = assets;
    if (assets.isEmpty) _message = '最近 20 个正式发布中没有 .luoplugin 文件';
  });

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(pluginManagerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('插件市场')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final package in _local)
            Builder(
              builder: (context) {
                final installed = manager
                    .list()
                    .where((p) => p.id == package.manifest.id)
                    .firstOrNull;
                final same =
                    installed?.digest == package.digest &&
                    installed?.manifest?.version == package.manifest.version;
                return Card(
                  child: ListTile(
                    title: Text(package.manifest.name),
                    subtitle: Text(
                      '随应用提供的 SDK 示例 · 离线可安装 · ${installed == null
                          ? '未安装'
                          : installed.enabled
                          ? '已安装 · 已启用'
                          : '已安装 · 已停用'}',
                    ),
                    trailing: TextButton(
                      onPressed: _busy || same
                          ? null
                          : () => Navigator.pop(context, package),
                      child: Text(same ? '已安装' : '预览并授权安装'),
                    ),
                  ),
                );
              },
            ),
          TextButton(
            onPressed: _busy
                ? null
                : () => _run(() async {
                    _catalogue = await _service.catalogue();
                    if (_catalogue.isEmpty) _message = '暂无公开目录结果，可填写仓库查找。';
                  }),
            child: const Text('浏览 GitHub 在线目录'),
          ),
          const Text(
            '浏览标记 luotopia-plugin 的 GitHub 仓库，或填写 owner/repo。第三方资源未经审核，下载预览后仍需确认权限。',
          ),
          for (final repo in _catalogue)
            ListTile(
              title: Text(repo),
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy
                  ? null
                  : () {
                      _repository.text = repo;
                      _search();
                    },
            ),
          TextField(
            controller: _repository,
            enabled: !_busy,
            decoration: const InputDecoration(labelText: 'GitHub owner/repo'),
            onSubmitted: (_) => _search(),
          ),
          FilledButton(
            onPressed: _busy ? null : _search,
            child: const Text('查找发布插件'),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_message != null) Text(_message!),
          for (final asset in _assets)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Builder(
                  builder: (context) {
                    final package = _previews[asset.url.toString()];
                    final installed = package == null
                        ? null
                        : manager
                              .list()
                              .where((p) => p.id == package.manifest.id)
                              .firstOrNull;
                    final same =
                        package != null &&
                        installed?.digest == package.digest &&
                        installed?.manifest?.version ==
                            package.manifest.version;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(asset.name),
                        Text('发布：${asset.release} · ${asset.size} 字节'),
                        if (package != null) ...[
                          Text(
                            '${package.manifest.name} ${package.manifest.version}',
                          ),
                          Text(package.manifest.description),
                          Text(
                            installed == null
                                ? '未安装'
                                : '已安装 ${installed.manifest?.version ?? ""} · ${installed.enabled ? "已启用" : "已停用"}',
                          ),
                          Text(
                            '申请权限：${package.manifest.permissions.isEmpty ? "无" : package.manifest.permissions.map(pluginPermissionLabel).join("、")}',
                          ),
                          if (package.manifest.networkHosts.isNotEmpty)
                            Text(
                              '网站：${package.manifest.networkHosts.join("、")}',
                            ),
                          SelectableText('SHA-256：${package.digest}'),
                          const Text('摘要不能证明作者身份。请核实来源。'),
                        ],
                        TextButton(
                          onPressed: _busy || same
                              ? null
                              : () {
                                  if (package != null) {
                                    Navigator.pop(context, package);
                                    return;
                                  }
                                  _run(() async {
                                    final preview = await _service.download(
                                      asset,
                                    );
                                    if (mounted) {
                                      _previews[asset.url.toString()] = preview;
                                    }
                                  });
                                },
                          child: Text(
                            package == null
                                ? '下载并预览'
                                : same
                                ? '已安装'
                                : '查看授权并安装 / 更新',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
