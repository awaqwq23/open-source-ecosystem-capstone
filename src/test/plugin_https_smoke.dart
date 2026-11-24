import '../Luotopia-app/lib/features/plugins/runtime/plugin_http.dart';

/// Manual network check; excluded from offline CI because it uses a public site.
Future<void> main() async {
  final scope = PluginHttpScope('org.example.smoke', ['gridstackjs.com'], () {});
  try {
    final response = await scope.request({
      'url': 'https://gridstackjs.com/',
      'method': 'GET',
    });
    final body = response['body'] as String;
    if (response['status'] != 200 || !body.toLowerCase().contains('gridstack')) {
      throw StateError('HTTPS check failed: status=${response['status']}');
    }
    print('Pinned HTTPS GET passed: status=200, response chars=${body.length}');
  } finally {
    scope.close();
  }
}
