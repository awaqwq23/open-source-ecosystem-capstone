class ScoreCalcItem {
  final String title;
  final String date;
  final String author;
  final int version;
  final String brief;
  final String updateBrief;
  final String desc;
  final ScoreCalcItemType type;
  final String url;
  final String script;

  const ScoreCalcItem({
    required this.title,
    required this.date,
    required this.author,
    required this.version,
    required this.brief,
    required this.updateBrief,
    required this.desc,
    required this.type,
    required this.url,
    this.script = '',
  });

  ScoreCalcItem copyWith({String? script}) {
    return ScoreCalcItem(
      title: title,
      date: date,
      author: author,
      version: version,
      brief: brief,
      updateBrief: updateBrief,
      desc: desc,
      type: type,
      url: url,
      script: script ?? this.script,
    );
  }

  factory ScoreCalcItem.fromJson(Map<String, dynamic> json) {
    return ScoreCalcItem(
      title: json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      author: json['author'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      brief: json['brief'] as String? ?? '',
      updateBrief: json['updateBrief'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      type: switch (json['type'] as String? ?? '') {
        'APP' => ScoreCalcItemType.app,
        'GITHUB' => ScoreCalcItemType.github,
        _ => ScoreCalcItemType.github,
      },
      url: json['url'] as String? ?? '',
      script: json['script'] as String? ?? '',
    );
  }
}

enum ScoreCalcItemType { app, github }
