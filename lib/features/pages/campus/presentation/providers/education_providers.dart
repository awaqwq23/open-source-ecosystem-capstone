import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/data/education_service.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';

final educationApiServiceProvider = Provider<EducationService?>((ref) {
  final notifier = ref.read(whuAuthProvider.notifier);
  return EducationService(fastLogin: notifier.fastLogin);
});
