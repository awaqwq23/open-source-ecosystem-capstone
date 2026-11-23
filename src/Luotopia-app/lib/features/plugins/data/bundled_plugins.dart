import 'package:flutter/services.dart';
import '../domain/plugin_manifest.dart';
import '../domain/builtin_plugins.dart';
import 'plugin_package.dart';

Future<List<PluginPackage>> loadBundledPlugins({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(assets);
  final paths =
      manifest
          .listAssets()
          .where(
            (path) =>
                path.startsWith('assets/system_plugins/') &&
                path.endsWith('.luoplugin'),
          )
          .toList()
        ..sort();
  final packages = <PluginPackage>[];
  final ids = <String>{};
  for (final path in paths) {
    final package = await PluginPackage.loadBundledAsset(path, assets);
    requirePlugin(
      package.manifest.id.startsWith('luotopia.') &&
          !builtinPlugins.any(
            (p) => p.id == package.manifest.id && p.source == PluginSource.core,
          ) &&
          ids.add(package.manifest.id),
      '内置插件身份无效或重复',
    );
    packages.add(package);
  }
  return List.unmodifiable(packages);
}
