import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/data/education_service.dart';
import 'package:luotopia/features/pages/campus/data/jwgl_client.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';

final jwglClientProvider = Provider<JwglClient?>((ref) {
  final state = ref.watch(whuAuthProvider);
  final cookie = state.sessionCookie;
  if (cookie == null || cookie.isEmpty) return null;

  return JwglClient(casCookie: cookie);
});

final educationApiServiceProvider = Provider<EducationService?>((ref) {
  final client = ref.watch(jwglClientProvider);
  if (client == null) return null;
  return EducationService(client: client);
});
