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
}
