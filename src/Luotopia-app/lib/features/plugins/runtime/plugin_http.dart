import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../domain/plugin_manifest.dart';
import '../domain/plugin_error.dart';

bool isPublicPluginAddress(InternetAddress address) {
  final b = address.rawAddress;
  if (b.length == 4) {
    return !(b[0] == 0 ||
        b[0] == 10 ||
        b[0] == 127 ||
        b[0] >= 224 ||
        (b[0] == 100 && b[1] >= 64 && b[1] <= 127) ||
        (b[0] == 169 && b[1] == 254) ||
        (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
        (b[0] == 192 &&
            (b[1] == 168 || b[1] == 0 || (b[1] == 88 && b[2] == 99))) ||
        (b[0] == 198 &&
            (b[1] == 18 || b[1] == 19 || (b[1] == 51 && b[2] == 100))) ||
        (b[0] == 203 && b[1] == 0 && b[2] == 113));
  }
  // Global unicast only; exclude transition, documentation and special-use ranges.
  return b.length == 16 &&
      (b[0] & 0xe0) == 0x20 &&
      !(b[0] == 0x20 &&
          (b[1] == 0x02 ||
              (b[1] == 0x01 &&
                  (b[2] <= 1 || (b[2] == 0x0d && b[3] == 0xb8))))) &&
      !(b[0] == 0x3f && b[1] == 0xff);
}

class PluginHttpScope {
  PluginHttpScope(this.pluginId, this.hosts, this.checkActive);
  final String pluginId;
  final List<String> hosts;
  final void Function() checkActive;
  final _clients = <HttpClient>{};
  static int _globalRequests = 0, _globalBuffer = 0;
  static final _requests = <String, int>{}, _buffers = <String, int>{};
  int _calls = 0, _traffic = 0;
  int _held = 0;
  bool _closed = false;
  void _active() {
    requirePlugin(!_closed, '请求已取消', 'PLUGIN_DISABLED');
    checkActive();
  }

  void close() {
    if (_closed) return;
    _closed = true;
    for (final c in _clients) {
      c.close(force: true);
    }
    _clients.clear();
    // Include responses awaiting the JS bridge, not only open socket buffers.
    _globalBuffer -= _held;
    _buffers[pluginId] = (_buffers[pluginId] ?? _held) - _held;
    _held = 0;
  }

  Uri _uri(String url) {
    final uri = Uri.tryParse(url);
    requirePlugin(
      uri != null &&
          uri.scheme == 'https' &&
          uri.port == 443 &&
          uri.userInfo.isEmpty &&
          uri.fragment.isEmpty &&
          hosts.contains(uri.host) &&
          InternetAddress.tryParse(uri.host) == null,
      '网络目标未获授权',
      'PERMISSION_DENIED',
    );
    return uri!;
  }

  Future<Map<String, dynamic>> request(Object? raw) async {
    _active();
    requirePlugin(
      ++_calls <= 4 && _globalRequests < 8 && (_requests[pluginId] ?? 0) < 2,
      '网络请求数量超限',
      'RESOURCE_LIMIT_EXCEEDED',
    );
    final data = pluginObject(raw, 'INVALID_INPUT');
    pluginFields(data, {'url', 'method', 'headers', 'body'}, 'INVALID_INPUT');
    var uri = _uri(pluginText(data['url'], 4096, 'INVALID_INPUT'));
    final method = data['method'];
    requirePlugin(
      method == 'GET' || method == 'POST',
      '只支持 GET / POST',
      'INVALID_INPUT',
    );
    final body = data['body'] ?? '';
    requirePlugin(
      body is String && utf8.encode(body).length <= 256 * 1024,
      '请求内容过长',
      'INVALID_INPUT',
    );
    final headers = data['headers'] == null
        ? <String, dynamic>{}
        : pluginObject(data['headers'], 'INVALID_INPUT');
    requirePlugin(headers.length <= 16, '请求头过多', 'INVALID_INPUT');
    for (final e in headers.entries) {
      requirePlugin(
        {
              'accept',
              'content-type',
              'accept-language',
            }.contains(e.key.toLowerCase()) &&
            e.value is String &&
            (e.value as String).length <= 1024 &&
            !(e.value as String).contains(RegExp(r'[\r\n]')),
        '请求头不受支持',
        'PERMISSION_DENIED',
      );
    }
    _globalRequests++;
    _requests[pluginId] = (_requests[pluginId] ?? 0) + 1;
    final client = HttpClient()
      ..findProxy = ((_) => 'DIRECT')
      ..autoUncompress = false
      ..connectionTimeout = const Duration(seconds: 10);
    _clients.add(client);
    var finished = false;
    void checkRequest() {
      _active();
      requirePlugin(!finished, '网络请求已结束', 'NETWORK_ERROR');
    }

    void account(int bytes, {bool buffer = false}) {
      checkRequest();
      _traffic += bytes;
      requirePlugin(
        _traffic <= 2 * 1024 * 1024,
        '单次动作网络流量超限',
        'RESOURCE_LIMIT_EXCEEDED',
      );
      if (buffer) {
        requirePlugin(
          (_buffers[pluginId] ?? 0) + bytes <= 4 * 1024 * 1024 &&
              _globalBuffer + bytes <= 16 * 1024 * 1024,
          '网络缓冲超限',
          'RESOURCE_LIMIT_EXCEEDED',
        );
        _held += bytes;
        _buffers[pluginId] = (_buffers[pluginId] ?? 0) + bytes;
        _globalBuffer += bytes;
      }
    }

    try {
      return await (() async {
        for (var redirects = 0; redirects <= 3; redirects++) {
          checkRequest();
          final addresses = await InternetAddress.lookup(uri.host);
          checkRequest();
          requirePlugin(
            addresses.isNotEmpty && addresses.every(isPublicPluginAddress),
            '禁止访问非公网地址',
            'PERMISSION_DENIED',
          );
          final target = uri;
          client.connectionFactory = (url, proxyHost, proxyPort) async {
            checkRequest();
            requirePlugin(
              url.host == target.host && url.port == 443 && proxyHost == null,
              '连接目标不一致',
              'PERMISSION_DENIED',
            );
            // A custom connectionFactory must perform TLS itself. Lookup
            // addresses retain the DNS hostname for SNI/certificate validation.
            return SecureSocket.startConnect(addresses.first, 443);
          };
          final request = await client.openUrl(method as String, uri);
          checkRequest();
          request.followRedirects = false;
          request.persistentConnection = false;
          headers.forEach((k, v) => request.headers.set(k, v));
          request.headers.set('accept-encoding', 'identity');
          final bytes = utf8.encode(body as String);
          account(bytes.length);
          if (bytes.isNotEmpty) request.add(bytes);
          final response = await request.close();
          if ({301, 302, 303, 307, 308}.contains(response.statusCode)) {
            requirePlugin(
              redirects < 3 && response.headers.value('location') != null,
              '重定向次数超限',
              'NETWORK_ERROR',
            );
            uri = _uri(
              uri.resolve(response.headers.value('location')!).toString(),
            );
            // Do not drain an unbounded redirect body.
            final subscription = response.listen((_) {});
            await subscription.cancel();
            continue;
          }
          requirePlugin(
            response.contentLength <= 1024 * 1024,
            '响应超过 1 MiB',
            'RESOURCE_LIMIT_EXCEEDED',
          );
          final output = BytesBuilder(copy: false);
          await for (final chunk in response) {
            requirePlugin(
              output.length + chunk.length <= 1024 * 1024,
              '响应超过 1 MiB',
              'RESOURCE_LIMIT_EXCEEDED',
            );
            account(chunk.length, buffer: true);
            output.add(chunk);
          }
          checkRequest();
          return <String, dynamic>{
            'status': response.statusCode,
            'headers': {
              for (final name in [
                'content-type',
                'content-language',
                'etag',
                'last-modified',
              ])
                if (response.headers.value(name) != null)
                  name: response.headers.value(name),
            },
            'body': utf8.decode(output.takeBytes(), allowMalformed: true),
          };
        }
        throw const PluginException('NETWORK_ERROR', '网络重定向失败');
      })().timeout(const Duration(seconds: 10));
    } on PluginException {
      rethrow;
    } catch (_) {
      throw const PluginException('NETWORK_ERROR', '插件网络请求失败或超时');
    } finally {
      finished = true;
      client.close(force: true);
      _clients.remove(client);
      _globalRequests--;
      _requests[pluginId] = (_requests[pluginId] ?? 1) - 1;
    }
  }
}
