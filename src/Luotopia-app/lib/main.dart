import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/app.dart';
import 'package:luotopia/app/app_bootstrap.dart';
import 'package:luotopia/app/app_runtime_initializer.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/core/theme/theme_controller.dart';
import 'package:luotopia/features/pages/ai/data/ai_in_memory_data_source.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final preferences = await SharedPreferences.getInstance();
  final bootstrap = await AppBootstrapLoader.load(preferences);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appLocaleProvider.overrideWith((ref) => bootstrap.locale),
        appThemeModeProvider.overrideWith((ref) => bootstrap.themeMode),
        appHomeSettingsProvider.overrideWith((ref) => bootstrap.homeSettings),
        appAiSettingsProvider.overrideWith((ref) => bootstrap.aiSettings),
        appWidgetSettingsProvider.overrideWith(
          (ref) => bootstrap.widgetSettings,
        ),
        appNavigationSettingsProvider.overrideWith(
          (ref) => bootstrap.navigationSettings,
        ),
        aiChatBootstrapSessionStoreProvider.overrideWithValue(
          bootstrap.aiChatSessionStore,
        ),
      ],
      child: const AppRuntimeInitializer(child: LuotopiaApp()),
    ),
  );
}
