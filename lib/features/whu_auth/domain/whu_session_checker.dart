bool looksLikeWhuLoginRedirect(String body) {
  final lower = body.toLowerCase();
  return lower.contains('authserver/login') ||
      lower.contains('cas.whu.edu.cn') && lower.contains('login') ||
      lower.contains('var dlktsxx=');
}
