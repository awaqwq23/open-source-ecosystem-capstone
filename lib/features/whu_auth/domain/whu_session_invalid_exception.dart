class WhuSessionInvalidException implements Exception {
  const WhuSessionInvalidException();

  @override
  String toString() => '教务会话已失效，请重新登录后再导入。';
}
