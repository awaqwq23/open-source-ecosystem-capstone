import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../domain/plugin_error.dart';
import 'plugin_package.dart';

Future<PluginPackage?> pickPluginPackage() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    throw const PluginException('UNSUPPORTED_RUNTIME', '外部插件运行目前支持 Android');
  }
  try {
    final bytes = await const MethodChannel(
      'luotopia/plugin_import',
    ).invokeMethod<Uint8List>('pick');
    // Android providers may rewrite filename extensions. Package content is the
    // trust boundary; the native reader and decoder both enforce the byte limit.
    return bytes == null ? null : PluginPackage.decode(bytes);
  } on PlatformException catch (e) {
    throw PluginException(e.code, e.message ?? '读取插件文件失败');
  }
}
