import 'sports_project.dart';

class SportsVenue {
  const SportsVenue({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.address,
    required this.campusTitle,
    required this.status,
    required this.sort,
    this.detail = '',
    this.images = const [],
    this.supportedProjects = const [],
  });

  final int id;
  final String title;
  final String imageUrl;
  final String address;
  final String campusTitle;
  final int status;
  final int sort;
  final String detail;
  final List<String> images;
  final List<SportsProject> supportedProjects;

  factory SportsVenue.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final rawProjects = json['supportedProjects'];
    return SportsVenue(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      address: json['address'] as String? ?? '',
      campusTitle: json['campusTitle'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      sort: json['sort'] as int? ?? 0,
      detail: json['detail'] as String? ?? '',
      images: rawImages is List
          ? rawImages.map((v) => '$v').toList(growable: false)
          : const [],
      supportedProjects: rawProjects is List
          ? rawProjects
                .whereType<Map<String, dynamic>>()
                .map(SportsProject.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'address': address,
      'campusTitle': campusTitle,
      'status': status,
      'sort': sort,
      'detail': detail,
      'images': images,
      'supportedProjects': supportedProjects.map((p) => p.toJson()).toList(),
    };
  }
}
