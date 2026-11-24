import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../domain/plugin_error.dart';
import '../domain/plugin_manifest.dart';
import '../runtime/plugin_http.dart' show isPublicPluginAddress;
import 'plugin_package.dart';

class PluginMarketAsset {
  const PluginMarketAsset(this.name, this.release, this.url, this.size);
  final String name, release;
  final Uri url;
  final int size;
}

class PluginMarketService {
  static String repository(String input) {
    final value = input.trim();
    requirePlugin(
      RegExp(
            r'^[A-Za-z0-9][A-Za-z0-9-]{0,38}/[A-Za-z0-9_.-]{1,100}$',
          ).hasMatch(value) &&
          !{'.', '..'}.contains(value.split('/').last),
      '请输入 GitHub owner/repo，例如 Luotopia/Luotopia',
      'INVALID_INPUT',
    );
    return value;
  }

  static Uri validateUrl(Uri uri, {bool api = false}) {
    requirePlugin(
      uri.scheme == 'https' &&
          uri.port == 443 &&
          uri.userInfo.isEmpty &&
          uri.fragment.isEmpty &&
          (api
              ? uri.host == 'api.github.com'
              : {
                  'github.com',
                  'release-assets.githubusercontent.com',
                  'objects.githubusercontent.com',
                }.contains(uri.host)),
      '只允许 GitHub 的 HTTPS 发布资源',
      'NETWORK_ERROR',
    );
    return uri;
  }

  static List<PluginMarketAsset> parseReleases(Object? raw, String repo) {
    repository(repo);
    requirePlugin(
      raw is List && raw.length <= 20,
      '发布列表格式不正确',
      'NETWORK_ERROR',
    );
    final assets = <PluginMarketAsset>[];
    for (final release in raw as List) {
      requirePlugin(release is Map, '发布信息格式不正确', 'NETWORK_ERROR');
      if (release['draft'] == true || release['prerelease'] == true) continue;
      final entries = release['assets'];
      requirePlugin(
        entries is List && entries.length <= 100,
        '发布资源过多',
        'NETWORK_ERROR',
      );
      for (final asset in entries as List) {
        requirePlugin(asset is Map, '发布资源格式不正确', 'NETWORK_ERROR');
        final name = asset['name'];
        if (name is! String || !name.endsWith('.luoplugin')) continue;
        final size = asset['size'];
        requirePlugin(
          name.length <= 200 &&
              size is int &&
              size > 0 &&
              size <= PluginPackage.maxBytes,
          '插件资源超过 5 MiB 或元数据无效',
          'PACKAGE_LIMIT_EXCEEDED',
        );
        final url = Uri.tryParse('${asset['browser_download_url']}');
        requirePlugin(url != null, '插件下载地址无效', 'NETWORK_ERROR');
        validateUrl(url!);
        requirePlugin(
          url.host == 'github.com' &&
              url.path.toLowerCase().startsWith(
                '/${repo.toLowerCase()}/releases/download/',
              ),
          '下载资源不属于所选仓库',
          'NETWORK_ERROR',
        );
        final tag = release['tag_name'];
        requirePlugin(
          tag is String && tag.length <= 200,
          '发布标签无效',
          'NETWORK_ERROR',
        );
        requirePlugin(
          assets.length < 100,
          '插件资源数量超限',
          'RESOURCE_LIMIT_EXCEEDED',
        );
        assets.add(PluginMarketAsset(name, tag as String, url, size as int));
      }
    }
    return assets;
  }

  Future<List<String>> catalogue() async {
    final bytes = await _get(
      Uri.https('api.github.com', '/search/repositories', {
        'q': 'topic:luotopia-plugin',
        'per_page': '20',
      }),
      1024 * 1024,
      api: true,
    );
    try {
      final raw = jsonDecode(utf8.decode(bytes));
      requirePlugin(
        raw is Map &&
            raw['items'] is List &&
            (raw['items'] as List).length <= 20,
        '目录格式不正确',
        'NETWORK_ERROR',
      );
      return [
        for (final item in raw['items'] as List)
          repository(item['full_name'] as String),
      ];
    } on PluginException {
      rethrow;
    } catch (_) {
      pluginFail('NETWORK_ERROR', 'GitHub 插件目录无法解析');
    }
  }

  Future<List<PluginMarketAsset>> discover(String input) async {
    final repo = repository(input);
    final bytes = await _get(
      Uri.https('api.github.com', '/repos/$repo/releases', {'per_page': '20'}),
      1024 * 1024,
      api: true,
    );
    try {
      return parseReleases(jsonDecode(utf8.decode(bytes)), repo);
    } on PluginException {
      rethrow;
    } catch (_) {
      pluginFail('NETWORK_ERROR', 'GitHub 发布列表无法解析');
    }
  }

  Future<PluginPackage> download(PluginMarketAsset asset) async {
    validateUrl(asset.url);
    final bytes = await _get(asset.url, PluginPackage.maxBytes);
    requirePlugin(
      bytes.length == asset.size,
      '下载大小与发布信息不符，请刷新重试',
      'NETWORK_ERROR',
    );
    return PluginPackage.decode(bytes);
  }

  Future<Uint8List> _get(Uri initial, int limit, {bool api = false}) async {
    final client = HttpClient()..autoUncompress = false;
    client.findProxy = (_) => 'DIRECT';
    try {
      return await (() async {
        var uri = initial;
        for (var redirect = 0; redirect <= 3; redirect++) {
          validateUrl(uri, api: api);
          final addresses = await InternetAddress.lookup(uri.host);
          requirePlugin(
            addresses.isNotEmpty && addresses.every(isPublicPluginAddress),
            '禁止连接非公网地址',
            'NETWORK_ERROR',
          );
          final target = uri;
          client.connectionFactory = (url, proxyHost, proxyPort) async {
            requirePlugin(
              url.host == target.host && url.port == 443 && proxyHost == null,
              '连接目标无效',
              'NETWORK_ERROR',
            );
            return SecureSocket.startConnect(addresses.first, 443);
          };
          final request = await client.getUrl(uri);
          request.followRedirects = false;
          request.persistentConnection = false;
          request.headers.set('user-agent', 'Luotopia-plugin-market');
          request.headers.set(
            'accept',
            api ? 'application/vnd.github+json' : 'application/octet-stream',
          );
          request.headers.set('accept-encoding', 'identity');
          final response = await request.close();
          if ({301, 302, 303, 307, 308}.contains(response.statusCode)) {
            final location = response.headers.value('location');
            requirePlugin(
              redirect < 3 && location != null,
              '下载重定向超限',
              'NETWORK_ERROR',
            );
            uri = uri.resolve(location!);
            await response.listen((_) {}).cancel();
            continue;
          }
          requirePlugin(
            response.statusCode == 200,
            'GitHub 请求失败（${response.statusCode}），请检查仓库或稍后重试',
            'NETWORK_ERROR',
          );
          requirePlugin(
            response.contentLength <= limit,
            '下载内容超过大小限制',
            'RESOURCE_LIMIT_EXCEEDED',
          );
          final output = BytesBuilder(copy: false);
          await for (final chunk in response) {
            requirePlugin(
              output.length + chunk.length <= limit,
              '下载内容超过大小限制',
              'RESOURCE_LIMIT_EXCEEDED',
            );
            output.add(chunk);
          }
          return output.takeBytes();
        }
        pluginFail('NETWORK_ERROR', '重定向超限');
      })().timeout(const Duration(seconds: 30));
    } on PluginException {
      rethrow;
    } catch (_) {
      pluginFail('NETWORK_ERROR', '无法连接 GitHub，请检查网络后重试');
    } finally {
      client.close(force: true);
    }
  }
}
