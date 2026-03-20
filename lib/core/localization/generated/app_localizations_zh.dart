// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '花卷日程';

  @override
  String get navHome => '主页';

  @override
  String get navList => '列表';

  @override
  String get navAi => 'AI';

  @override
  String get navAdd => '添加';

  @override
  String get navSettings => '设置';

  @override
  String get homeTitle => '日程总览';

  @override
  String get homeDescription => '这里将承载周视图与月视图的表格化规划主页。';

  @override
  String get listTitle => '事项列表';

  @override
  String get listDescription => '这里将承载任务、日程、备忘和标签页驱动的列表体验。';

  @override
  String get aiTitle => 'AI 助手';

  @override
  String get aiDescription => '这里将承载 AI 对话、事项创建和问答能力。';

  @override
  String get editorTitle => '新建事项';

  @override
  String get editorDescription => '这里将承载日程、任务、备忘的统一编辑页面。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsDescription => '这里将承载全局、主页、列表页和 AI 的设置入口。';

  @override
  String get detailTitle => '事项详情';

  @override
  String get detailDescription => '这个路由预留给单个事项的详情展示。';

  @override
  String get timePickerTitle => '时间选择';

  @override
  String get timePickerDescription => '这个路由预留给共享的日周月时间选择器。';

  @override
  String get developmentTag => '基础 UI';

  @override
  String get themeSectionTitle => '显示';

  @override
  String get themeModeLabel => '主题模式';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get languageSectionTitle => '语言';

  @override
  String get languageLabel => '应用语言';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => '英文';
}
