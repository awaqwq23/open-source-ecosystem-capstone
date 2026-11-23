import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:luotopia/features/plugins/data/bundled_plugins.dart';
import 'package:path_provider/path_provider.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/data/plugin_store.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
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
  final support = await getApplicationSupportDirectory();
  final plugins = PluginManager(
    store: PluginStore(Directory('${support.path}/plugins-v1')),
    legacyAi: bootstrap.navigationSettings.middleTabMode == MiddleTabMode.ai,
    bundledPackages: Platform.isAndroid ? await loadBundledPlugins() : const [],
  );
  await plugins.load();

  runApp(
    ProviderScope(
      overrides: [
        pluginManagerProvider.overrideWith((ref) => plugins),
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
