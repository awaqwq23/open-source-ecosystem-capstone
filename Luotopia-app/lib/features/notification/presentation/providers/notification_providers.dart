import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/notification/data/notification_api.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';

class NotificationState {
  final String? latestId;
  final String? title;
  final String? content;
  final bool hasNew;
  final int count;
  final bool loading;

  const NotificationState({
    this.latestId,
    this.title,
    this.content,
    this.hasNew = false,
    this.count = 0,
    this.loading = false,
  });
}

final notificationApiProvider = Provider<NotificationAPI>((ref) {
  return NotificationAPI(apiClient: ref.read(apiClientProvider));
});

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final api = ref.read(notificationApiProvider);
  return NotificationNotifier(api);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._api) : super(const NotificationState());

  final NotificationAPI _api;

  Future<void> checkLatest() async {
    try {
      final data = await _api.getLatest();
      final hasNew = data['has_new'] as bool? ?? false;
      if (hasNew) {
        state = NotificationState(
          latestId: data['latest_id'] as String?,
          title: data['title'] as String?,
          content: data['content'] as String?,
          hasNew: true,
          count: data['count'] as int? ?? 0,
        );
      } else {
        state = const NotificationState(hasNew: false);
      }
    } catch (_) {
      // Silently fail
    }
  }
}
