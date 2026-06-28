class SportsProject {
  const SportsProject({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.areaType,
    required this.sort,
  });

  final int id;
  final String title;
  final String imageUrl;
  final int areaType;
  final int sort;

  factory SportsProject.fromJson(Map<String, dynamic> json) {
    return SportsProject(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      areaType: json['areaType'] as int? ?? 0,
      sort: json['sort'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'areaType': areaType,
      'sort': sort,
    };
  }
}
