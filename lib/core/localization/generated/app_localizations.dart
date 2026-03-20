import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HuaJuan Agenda'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get navList;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAi;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Overview'**
  String get homeTitle;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'The table page will show week and month planning grids here.'**
  String get homeDescription;

  /// No description provided for @listTitle.
  ///
  /// In en, this message translates to:
  /// **'Items List'**
  String get listTitle;

  /// No description provided for @listDescription.
  ///
  /// In en, this message translates to:
  /// **'Task, schedule, memo and tag-based lists will be organized here.'**
  String get listDescription;

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiTitle;

  /// No description provided for @aiDescription.
  ///
  /// In en, this message translates to:
  /// **'AI conversations and schedule commands will be handled here.'**
  String get aiDescription;

  /// No description provided for @editorTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Item'**
  String get editorTitle;

  /// No description provided for @editorDescription.
  ///
  /// In en, this message translates to:
  /// **'The unified editor for schedule, task and memo will live here.'**
  String get editorDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Global, list, home and AI settings will be grouped here.'**
  String get settingsDescription;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Detail'**
  String get detailTitle;

  /// No description provided for @detailDescription.
  ///
  /// In en, this message translates to:
  /// **'This route is reserved for viewing a single item\'s details.'**
  String get detailDescription;

  /// No description provided for @timePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Picker'**
  String get timePickerTitle;

  /// No description provided for @timePickerDescription.
  ///
  /// In en, this message translates to:
  /// **'This route is reserved for the shared day, week and month picker.'**
  String get timePickerDescription;

  /// No description provided for @developmentTag.
  ///
  /// In en, this message translates to:
  /// **'Foundation UI'**
  String get developmentTag;

  /// No description provided for @themeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get themeSectionTitle;

  /// No description provided for @themeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeLabel;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageLabel;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @headerPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get headerPreviousPeriod;

  /// No description provided for @headerNextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get headerNextPeriod;

  /// No description provided for @headerOpenTimePicker.
  ///
  /// In en, this message translates to:
  /// **'Open time picker'**
  String get headerOpenTimePicker;

  /// No description provided for @headerOpenListTabs.
  ///
  /// In en, this message translates to:
  /// **'Open list tabs'**
  String get headerOpenListTabs;

  /// No description provided for @headerOpenListSettings.
  ///
  /// In en, this message translates to:
  /// **'Open list settings'**
  String get headerOpenListSettings;

  /// No description provided for @headerOpenItemTypePicker.
  ///
  /// In en, this message translates to:
  /// **'Open item type picker'**
  String get headerOpenItemTypePicker;

  /// No description provided for @homeScopePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Display range'**
  String get homeScopePickerTitle;

  /// No description provided for @homeScopeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get homeScopeWeek;

  /// No description provided for @homeScopeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get homeScopeMonth;

  /// No description provided for @listTabMyDay.
  ///
  /// In en, this message translates to:
  /// **'My Day'**
  String get listTabMyDay;

  /// No description provided for @listTabAllItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get listTabAllItems;

  /// No description provided for @listTabTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get listTabTasks;

  /// No description provided for @listTabSchedules.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get listTabSchedules;

  /// No description provided for @listTabMemos.
  ///
  /// In en, this message translates to:
  /// **'Memos'**
  String get listTabMemos;

  /// No description provided for @listTabImportant.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get listTabImportant;

  /// No description provided for @listMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch list tab'**
  String get listMenuTitle;

  /// No description provided for @listSettingsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'List settings'**
  String get listSettingsMenuTitle;

  /// No description provided for @listSettingsSort.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get listSettingsSort;

  /// No description provided for @listSettingsReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder tasks'**
  String get listSettingsReorder;

  /// No description provided for @listSettingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get listSettingsTheme;

  /// No description provided for @listSettingsMore.
  ///
  /// In en, this message translates to:
  /// **'More settings'**
  String get listSettingsMore;

  /// No description provided for @aiPeriodPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select time range'**
  String get aiPeriodPickerTitle;

  /// No description provided for @aiPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get aiPeriodDay;

  /// No description provided for @aiPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get aiPeriodWeek;

  /// No description provided for @aiPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get aiPeriodMonth;

  /// No description provided for @editorTypePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch item type'**
  String get editorTypePickerTitle;

  /// No description provided for @editorTypeTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get editorTypeTask;

  /// No description provided for @editorTypeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get editorTypeSchedule;

  /// No description provided for @editorTypeMemo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get editorTypeMemo;

  /// No description provided for @placeholderOpenPicker.
  ///
  /// In en, this message translates to:
  /// **'Open picker'**
  String get placeholderOpenPicker;

  /// No description provided for @placeholderOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get placeholderOpenMenu;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
