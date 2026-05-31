import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/hot_update/data/hot_update_cache.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/notification/presentation/providers/notification_providers.dart';
import 'package:luotopia/features/unified_pull/data/pull_client.dart';
import 'package:luotopia/features/unified_pull/data/pull_state_store.dart';
import 'package:luotopia/features/unified_pull/domain/pull_service.dart';
import 'package:luotopia/features/weather/presentation/providers/weather_providers.dart';
import 'package:luotopia/shared/data/api_client.dart';
import 'package:luotopia/shared/data/sync/sync_cursor_store.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  String tokenProvider() {
    final auth = ref.read(luotopiaAuthProvider);
    return auth.accessToken ?? '';
  }
  final client = ApiClient(
    baseUrl: dotenv.get('LUOTOPIA_API_BASE_URL'),
    tokenProvider: tokenProvider,
  );
  ref.onDispose(client.dispose);
  return client;
});

final pullClientProvider = Provider<PullClient>((ref) {
  return PullClient(apiClient: ref.read(apiClientProvider));
});

final unifiedPullServiceProvider = Provider<UnifiedPullService>((ref) {
  return UnifiedPullService(
    pullClient: ref.read(pullClientProvider),
    stateStore: ref.read(pullStateStoreProvider),
    hotUpdateCache: ref.read(hotUpdateCacheProvider),
    syncCursorStore: ref.read(syncCursorStoreProvider),
  );
});

final manualPullProvider = Provider.autoDispose<Future<void> Function()>((ref) {
  return () async {
    final result = await ref.read(unifiedPullServiceProvider).pullScoped(
          trigger: 'manual',
          scopes: const ['notification', 'weather', 'hot_update', 'sync'],
        );
    if (result.isSuccess && result.response?.notification != null) {
      ref.invalidate(notificationProvider);
    }
    if (result.isSuccess && result.response?.weather != null) {
      ref.invalidate(weatherProvider);
    }
  };
});
