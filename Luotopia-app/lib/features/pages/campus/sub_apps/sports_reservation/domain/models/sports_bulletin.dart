class SportsBulletin {
  const SportsBulletin({
    required this.id,
    required this.title,
    required this.content,
    this.publishedAt,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String content;
  final DateTime? publishedAt;
  final bool isRead;
}

class SportsBulletinListResult {
  const SportsBulletinListResult({
    required this.items,
    this.totalCount = 0,
    this.unreadCount = 0,
  });

  final List<SportsBulletin> items;
  final int totalCount;
  final int unreadCount;
}
