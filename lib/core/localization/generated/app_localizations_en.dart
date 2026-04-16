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
  String get settingsSearchTooltip => 'Search settings';

  @override
  String get settingsSearchHint => 'Search settings';

  @override
  String get settingsSearchEmpty => 'No matching settings found';

  @override
  String get settingsGeneralEntryTitle => 'General';

  @override
  String get settingsGeneralEntrySubtitle =>
      'Theme, language, sync, notifications and widgets';

  @override
  String get settingsHomeEntrySubtitle =>
      'Home time blocks and wide-screen range';

  @override
  String get settingsListEntryTitle => 'List settings';

  @override
  String get settingsListEntrySubtitle =>
      'Sort, reorder and list display preferences';

  @override
  String get settingsAiEntrySubtitle => 'API URL, key, model and system prompt';

  @override
  String get settingsAboutEntryTitle => 'About';

  @override
  String get settingsAboutEntrySubtitle => 'App info, version and license';

  @override
  String get settingsGeneralCapabilitiesTitle => 'Platform capabilities';

  @override
  String get settingsGeneralSyncTitle => 'Data sync';

  @override
  String get settingsGeneralNotificationTitle => 'Notifications';

  @override
  String get settingsGeneralWidgetsTitle => 'Home-screen widgets';

  @override
  String get settingsGeneralComingSoon =>
      'This capability will be available in a future release.';

  @override
  String get settingsAboutProductSubtitle =>
      'Grid-based planning at a glance with AI assistance';

  @override
  String get settingsAboutVersionTitle => 'Version';

  @override
  String get settingsAboutLicenseTitle => 'Open-source license';

  @override
  String get settingsQuickActionsTitle => 'Quick access';

  @override
  String get settingsHomeSectionTitle => 'Home settings';

  @override
  String get settingsHomeSectionDescription =>
      'Configure the home grid time blocks and the default range on ultra-wide screens.';

  @override
  String get settingsHomeDayStart => 'Day start time';

  @override
  String get settingsHomeBlockDuration => 'Block duration';

  @override
  String get settingsHomeBlockGap => 'Gap between blocks';

  @override
  String get settingsHomeBlockCount => 'Block count';

  @override
  String get settingsHomeDemoModeTitle => 'Demo data mode';

  @override
  String get settingsHomeDemoModeDescription =>
      'When enabled, the home page switches to built-in sample items for demos and walkthroughs.';

  @override
  String get settingsHomeWideLayout => 'Ultra-wide default range';

  @override
  String get settingsAiSectionTitle => 'AI settings';

  @override
  String get settingsAiSectionDescription =>
      'Configure the OpenAI-compatible base URL, API key, model, and system prompt.';

  @override
  String get settingsAiBaseUrlLabel => 'API URL';

  @override
  String get settingsAiApiKeyLabel => 'API key';

  @override
  String get settingsAiModelLabel => 'Model';

  @override
  String get settingsAiSystemPromptLabel => 'System prompt';

  @override
  String get settingsAiTestButton => 'Test connection';

  @override
  String get settingsAiTestingButton => 'Testing...';

  @override
  String get settingsAiSaveButton => 'Save AI settings';

  @override
  String settingsMinutesValue(int value) {
    return '$value min';
  }

  @override
  String get detailTitle => 'Item Detail';

  @override
  String get detailDescription =>
      'Shows a full item profile with quick actions.';

  @override
  String get detailMissing =>
      'This item could not be found. It may have been deleted.';

  @override
  String get detailTimeLabel => 'Time';

  @override
  String get detailDeadlineLabel => 'Deadline';

  @override
  String get detailLocationLabel => 'Location';

  @override
  String get detailNotesLabel => 'Notes';

  @override
  String get detailReminderLabel => 'Reminder';

  @override
  String get detailRepeatLabel => 'Repeat';

  @override
  String get detailMarkComplete => 'Mark complete';

  @override
  String get detailMarkIncomplete => 'Mark incomplete';

  @override
  String get detailMarkImportant => 'Mark important';

  @override
  String get detailUnmarkImportant => 'Remove importance';

  @override
  String get detailDelete => 'Delete item';

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

  @override
  String get commonBack => 'Back';

  @override
  String get headerPreviousPeriod => 'Previous period';

  @override
  String get headerNextPeriod => 'Next period';

  @override
  String get headerOpenTimePicker => 'Open time picker';

  @override
  String get headerOpenListTabs => 'Open list tabs';

  @override
  String get headerOpenListSettings => 'Open list settings';

  @override
  String get headerOpenItemTypePicker => 'Open item type picker';

  @override
  String get homeScopePickerTitle => 'Display range';

  @override
  String get homeScopeWeek => 'Week';

  @override
  String get homeScopeMonth => 'Month';

  @override
  String get homeDemoBanner =>
      'Demo data mode is enabled. The home page is showing built-in sample items.';

  @override
  String get listTabMyDay => 'My Day';

  @override
  String get listTabAllItems => 'All Items';

  @override
  String get listTabTasks => 'Tasks';

  @override
  String get listTabSchedules => 'Schedules';

  @override
  String get listTabMemos => 'Memos';

  @override
  String get listTabImportant => 'Important';

  @override
  String get listMenuTitle => 'Switch list tab';

  @override
  String get listSettingsMenuTitle => 'List settings';

  @override
  String get listSettingsSort => 'Sort by';

  @override
  String get listSettingsReorder => 'Reorder tasks';

  @override
  String get listSettingsTheme => 'Change theme';

  @override
  String get listSettingsMore => 'More settings';

  @override
  String listSummary(int pending, int completed) {
    return '$pending pending, $completed completed';
  }

  @override
  String listPendingSection(int count) {
    return 'Pending $count';
  }

  @override
  String listCompletedSection(int count) {
    return 'Completed $count';
  }

  @override
  String get listCompletedExpand => 'Expand completed items';

  @override
  String get listCompletedCollapse => 'Collapse completed items';

  @override
  String get listEmptyTitle => 'No items yet';

  @override
  String get listEmptyDescription =>
      'Use the add button to create your first task, schedule, or memo.';

  @override
  String get listReorderHint =>
      'Manual order is enabled. Drag the handle on each task to rearrange it.';

  @override
  String get listStaticItemsLabel => 'Other items';

  @override
  String get listActionEdit => 'Edit';

  @override
  String get listActionDelete => 'Delete';

  @override
  String get listSortImportance => 'Importance';

  @override
  String get listSortDueDate => 'Due date';

  @override
  String get listSortTodayFocus => 'Today focus';

  @override
  String get listSortAlphabetical => 'Alphabetical';

  @override
  String get listSortCreatedDate => 'Created date';

  @override
  String get listSortManual => 'Manual order';

  @override
  String get listThemeComingSoon =>
      'Tab themes are out of scope for this pass.';

  @override
  String get listStatusPending => 'Pending';

  @override
  String get listStatusCompleted => 'Completed';

  @override
  String get listImportantEnabled => 'Important';

  @override
  String get listImportantDisabled => 'Normal';

  @override
  String get aiPeriodPickerTitle => 'Select time range';

  @override
  String aiPeriodSummary(Object period, int count) {
    return 'Chat history grouped by $period. Current groups: $count.';
  }

  @override
  String get aiPeriodDay => 'Day';

  @override
  String get aiPeriodWeek => 'Week';

  @override
  String get aiPeriodMonth => 'Month';

  @override
  String get aiInputHint =>
      'Write a message for AI to create an item or answer a schedule question';

  @override
  String get aiSendButton => 'Send';

  @override
  String get aiSendingButton => 'Sending...';

  @override
  String get aiEmptyState => 'No chat history in the current time range.';

  @override
  String get editorTypePickerTitle => 'Switch item type';

  @override
  String get editorTypeTask => 'Task';

  @override
  String get editorTypeSchedule => 'Schedule';

  @override
  String get editorTypeMemo => 'Memo';

  @override
  String get editorCreateTask => 'Create task';

  @override
  String get editorCreateSchedule => 'Create schedule';

  @override
  String get editorCreateMemo => 'Create memo';

  @override
  String get editorEditTask => 'Edit task';

  @override
  String get editorEditSchedule => 'Edit schedule';

  @override
  String get editorEditMemo => 'Edit memo';

  @override
  String get editorSectionBasic => 'Basic info';

  @override
  String get editorSectionColor => 'Color';

  @override
  String get editorSectionTime => 'Date & time';

  @override
  String get editorSectionReminder => 'Reminder';

  @override
  String get editorSectionRepeat => 'Repeat';

  @override
  String get editorSectionLocationNotes => 'Location & notes';

  @override
  String get editorFieldTitle => 'Title';

  @override
  String get editorFieldTitleName => 'Task name';

  @override
  String get editorFieldDetails => 'Details';

  @override
  String get editorFieldLocation => 'Location';

  @override
  String get editorFieldStart => 'Start';

  @override
  String get editorFieldEnd => 'End';

  @override
  String get editorFieldStartDate => 'Start date';

  @override
  String get editorFieldStartTime => 'Start time';

  @override
  String get editorFieldEndDate => 'End date';

  @override
  String get editorFieldEndTime => 'End time';

  @override
  String get editorFieldDeadline => 'Deadline';

  @override
  String get editorFieldDeadlineDate => 'Deadline date';

  @override
  String get editorFieldDeadlineTime => 'Deadline time';

  @override
  String get editorFieldTargetDate => 'Target date';

  @override
  String get editorFieldEstimatedDuration => 'Estimated duration';

  @override
  String get editorFieldImportant => 'Important item';

  @override
  String get editorHintTitle => 'What needs to be done?';

  @override
  String get editorHintDetails => 'Add more context';

  @override
  String get editorHintLocation => 'Where does it happen?';

  @override
  String get editorColorSky => 'Sky';

  @override
  String get editorColorJade => 'Jade';

  @override
  String get editorColorAmber => 'Amber';

  @override
  String get editorColorCoral => 'Coral';

  @override
  String get editorColorOrchid => 'Orchid';

  @override
  String get editorColorSlate => 'Slate';

  @override
  String get editorColorPickerTitle => 'Choose color';

  @override
  String get editorAllDayTitle => 'All-day item';

  @override
  String get editorAllDayDescription =>
      'When enabled, only dates are shown and specific times are hidden.';

  @override
  String get editorReminderNone => 'No reminder';

  @override
  String get editorReminderAtTime => 'At time';

  @override
  String get editorReminderFiveMinutes => '5 minutes before';

  @override
  String get editorReminderFifteenMinutes => '15 minutes before';

  @override
  String get editorReminderOneHour => '1 hour before';

  @override
  String get editorReminderOneDay => '1 day before';

  @override
  String get editorReminderPageTitle => 'Reminder settings';

  @override
  String get editorRepeatNone => 'Does not repeat';

  @override
  String get editorRepeatDaily => 'Every day';

  @override
  String get editorRepeatWeekdays => 'Weekdays';

  @override
  String get editorRepeatWeekly => 'Every week';

  @override
  String get editorRepeatMonthly => 'Every month';

  @override
  String get editorRepeatYearly => 'Every year';

  @override
  String get editorRepeatPageTitle => 'Repeat settings';

  @override
  String get editorRepeatPagePlaceholder =>
      'Advanced repeat rules will be expanded later.';

  @override
  String get editorDurationPickerTitle => 'Choose duration';

  @override
  String get editorDeadlineClear => 'Clear';

  @override
  String get editorDeadlineUnset => 'Not set';

  @override
  String get editorPickerCancel => 'Cancel';

  @override
  String get editorPickerConfirm => 'Confirm';

  @override
  String get editorSubmitButton => 'Create item';

  @override
  String get editorSubmitInvalid => 'Please fix the highlighted fields first.';

  @override
  String get editorSubmitSuccess => 'Item saved.';

  @override
  String get editorErrorTitleRequired => 'Please enter a title.';

  @override
  String get editorErrorEndBeforeStart =>
      'End time cannot be earlier than start time.';

  @override
  String get editorErrorDeadlineBeforeStart =>
      'Deadline cannot be earlier than the start time.';

  @override
  String get editorErrorDurationPositive => 'Duration must be greater than 0.';

  @override
  String editorDurationHours(int hours) {
    return '$hours h';
  }

  @override
  String editorDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String editorDurationHourMinute(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String detailRangeDate(Object start, Object end) {
    return '$start to $end';
  }

  @override
  String detailMemoDate(Object date, Object duration) {
    return '$date · est. $duration';
  }

  @override
  String get placeholderOpenPicker => 'Open picker';

  @override
  String get placeholderOpenMenu => 'Open menu';
}
