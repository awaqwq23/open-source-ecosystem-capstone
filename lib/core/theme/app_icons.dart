import 'package:flutter/material.dart';

/// 全局语义图标入口。
///
/// 当前统一映射到 Material Icons；后续若切换图标库，只调整这里。
abstract final class AppIcons {
  static const IconData homeOutlined = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;

  static const IconData listOutlined = Icons.checklist_rtl_outlined;
  static const IconData listFilled = Icons.checklist_rtl;

  static const IconData forumOutlined = Icons.garage_outlined;
  static const IconData forumFilled = Icons.garage;

  static const IconData campusOutlined = Icons.apps_outlined;
  static const IconData campusFilled = Icons.apps;

  static const IconData settingsOutlined = Icons.settings_outlined;
  static const IconData settingsFilled = Icons.settings;

  static const IconData back = Icons.arrow_back;
  static const IconData previousPeriod = Icons.chevron_left;
  static const IconData nextPeriod = Icons.chevron_right;
  static const IconData expandSelection = Icons.keyboard_arrow_down;
  static const IconData drillIn = Icons.chevron_right;
  static const IconData selected = Icons.check_circle;

  static const IconData openTimePicker = Icons.calendar_month;
  static const IconData itemDetail = Icons.article_outlined;
  static const IconData openListTabs = Icons.menu;
  static const IconData moreActions = Icons.more_horiz;
  static const IconData quickActions = Icons.tune;
  static const IconData search = Icons.search;

  static const IconData themeSystem = Icons.brightness_auto_outlined;
  static const IconData themeLight = Icons.light_mode_outlined;
  static const IconData themeDark = Icons.dark_mode_outlined;
  static const IconData languageChinese = Icons.translate_outlined;
  static const IconData languageEnglish = Icons.language_outlined;
  static const IconData appearanceSection = Icons.palette_outlined;

  static const IconData itemTypeTask = Icons.check_circle_outline;
  static const IconData itemTypeSchedule = Icons.calendar_month_outlined;
  static const IconData itemTypeMemo = Icons.sticky_note_2_outlined;
  static const IconData itemTypeCourse = Icons.school_outlined;
  static const IconData import = Icons.file_download_outlined;
  static const IconData web = Icons.public_outlined;
  static const IconData submitCreate = Icons.check;
  static const IconData add = Icons.add;
  static const IconData complete = Icons.check_circle;
  static const IconData incomplete = Icons.radio_button_unchecked;
  static const IconData delete = Icons.delete_outline;
  static const IconData edit = Icons.edit_outlined;
  static const IconData expandLess = Icons.expand_less;
  static const IconData expandMore = Icons.expand_more;
  static const IconData drag = Icons.drag_indicator;
  static const IconData info = Icons.info_outline;
  static const IconData person = Icons.person_outline;
  static const IconData calendar = Icons.event_outlined;
  static const IconData clock = Icons.schedule_outlined;
  static const IconData location = Icons.location_on_outlined;
}
