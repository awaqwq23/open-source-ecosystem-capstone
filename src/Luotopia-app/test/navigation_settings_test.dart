import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luotopia/app/app_bootstrap.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/pages/settings/data/settings_repository_impl.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'visible navigation count persists and old preferences default to five',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      expect(
        (await AppBootstrapLoader.load(prefs)).navigationSettings.visibleCount,
        5,
      );
      await container
          .read(settingsRepositoryProvider)
          .saveNavigationSettings(
            const NavigationSettings.defaults().copyWith(visibleCount: 8),
          );
      expect(
        (await AppBootstrapLoader.load(prefs)).navigationSettings.visibleCount,
        8,
      );
      await prefs.setString(
        AppBootstrapStorageKeys.navigationSettings,
        '{"visibleCount":100}',
      );
      expect(
        (await AppBootstrapLoader.load(prefs)).navigationSettings.visibleCount,
        8,
      );
    },
  );
}
