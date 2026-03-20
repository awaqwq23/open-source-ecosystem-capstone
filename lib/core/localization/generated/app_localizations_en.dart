// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HuaJuan Agenda';

  @override
  String get navHome => 'Home';

  @override
  String get navList => 'List';

  @override
  String get navAi => 'AI';

  @override
  String get navAdd => 'Add';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'Schedule Overview';

  @override
  String get homeDescription =>
      'The table page will show week and month planning grids here.';

  @override
  String get listTitle => 'Items List';

  @override
  String get listDescription =>
      'Task, schedule, memo and tag-based lists will be organized here.';

  @override
  String get aiTitle => 'AI Assistant';

  @override
  String get aiDescription =>
      'AI conversations and schedule commands will be handled here.';

  @override
  String get editorTitle => 'Create Item';

  @override
  String get editorDescription =>
      'The unified editor for schedule, task and memo will live here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDescription =>
      'Global, list, home and AI settings will be grouped here.';

  @override
  String get detailTitle => 'Item Detail';

  @override
  String get detailDescription =>
      'This route is reserved for viewing a single item\'s details.';

  @override
  String get timePickerTitle => 'Time Picker';

  @override
  String get timePickerDescription =>
      'This route is reserved for the shared day, week and month picker.';

  @override
  String get developmentTag => 'Foundation UI';

  @override
  String get themeSectionTitle => 'Display';

  @override
  String get themeModeLabel => 'Theme mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageLabel => 'App language';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageEnglish => 'English';
}
