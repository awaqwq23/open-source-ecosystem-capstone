class PluginException implements Exception {
  const PluginException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => '$code: $message';
}

Never pluginFail(String code, String message) =>
    throw PluginException(code, message);
