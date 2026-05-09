import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/whu_auth/data/whu_auth_repository.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_state.dart';

final whuAuthProvider = NotifierProvider<WhuAuthNotifier, WhuAuthState>(
  WhuAuthNotifier.new,
);

class WhuAuthNotifier extends Notifier<WhuAuthState> {
  late final WhuAuthRepository _repository;

  @override
  WhuAuthState build() {
    _repository = const WhuAuthRepository();
    _loadCachedCookie();
    return const WhuAuthState(isLoading: true);
  }

  Future<void> _loadCachedCookie() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final cached = _repository.readCookie(prefs).trim();
    state = WhuAuthState(
      cookieHeader: cached,
      isLoading: false,
    );
  }

  Future<void> setCookie(String cookieHeader) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await _repository.writeCookie(prefs, cookieHeader);
    state = WhuAuthState(cookieHeader: cookieHeader);
  }

  Future<void> clearCookie() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await _repository.clearCookie(prefs);
    state = const WhuAuthState();
  }
}
