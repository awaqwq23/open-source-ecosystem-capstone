// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Luotopia';

  @override
  String get navHome => '主页';

  @override
  String get navList => '日程';

  @override
  String get navForum => '论坛';

  @override
  String get navAi => 'AI';

  @override
  String get navCampus => '校园';

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
  String get forumTitle => '珞珈防空洞';

  @override
  String get campusTitle => '校园';

  @override
  String get editorTitle => '新建事项';

  @override
  String get editorDescription => '这里将承载日程、任务、备忘的统一编辑页面。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsDescription => '这里将承载全局、主页和列表页的设置入口。';

  @override
  String get settingsSearchTooltip => '搜索设置';

  @override
  String get settingsSearchHint => '搜索设置项';

  @override
  String get settingsSearchEmpty => '没有找到匹配的设置项';

  @override
  String get settingsGeneralEntryTitle => '通用设置';

  @override
  String get settingsGeneralEntrySubtitle => '主题、语言、小组件与导航栏';

  @override
  String get settingsHomeEntrySubtitle => '主页时间块、网格模式与宽屏显示范围';

  @override
  String get settingsListEntryTitle => '列表页设置';

  @override
  String get settingsListEntrySubtitle => '列表排序、重排与展示偏好';

  @override
  String get settingsAboutEntryTitle => '关于';

  @override
  String get settingsAboutEntrySubtitle => '应用信息、版本与许可';

  @override
  String get settingsGeneralWidgetsTitle => '桌面小组件';

  @override
  String get settingsAboutProductSubtitle => '全屏纵览表格化校园规划';

  @override
  String get settingsAboutVersionTitle => '版本';

  @override
  String get settingsQuickActionsTitle => '快捷定位';

  @override
  String get settingsHomeSectionTitle => '主页设置';

  @override
  String get settingsHomeSectionDescription => '配置主页的时间块切分规则，以及超宽屏默认显示的时间范围。';

  @override
  String get settingsHomeDayStart => '每天开始规划时间';

  @override
  String get settingsHomeBlockDuration => '单个规划块时长';

  @override
  String get settingsHomeBlockGap => '规划块间隔';

  @override
  String get settingsHomeBlockCount => '规划块数量';

  @override
  String get settingsHomeItemOpacity => '主页事项方块不透明度';

  @override
  String get settingsHomeGridMode => '网格模式';

  @override
  String get homeGridModeTime => '时间方格';

  @override
  String get homeGridModeCourse => '课程方格';

  @override
  String get settingsHomeWideLayout => '超宽屏默认范围';

  @override
  String settingsMinutesValue(int value) {
    return '$value 分钟';
  }

  @override
  String settingsPercentValue(int value) {
    return '$value%';
  }

  @override
  String get detailTitle => '事项详情';

  @override
  String get detailDescription => '展示单个事项的完整信息与快捷操作。';

  @override
  String get detailMissing => '没有找到这个事项，可能已经被删除。';

  @override
  String get detailTimeLabel => '时间';

  @override
  String get detailDeadlineLabel => '截止时间';

  @override
  String get detailLocationLabel => '地点';

  @override
  String get detailNotesLabel => '备注';

  @override
  String get detailReminderLabel => '提醒';

  @override
  String get detailRepeatLabel => '重复';

  @override
  String get detailMarkComplete => '标记完成';

  @override
  String get detailMarkIncomplete => '恢复未完成';

  @override
  String get detailDelete => '删除事项';

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

  @override
  String get commonBack => '返回';

  @override
  String get headerPreviousPeriod => '上一时间段';

  @override
  String get headerNextPeriod => '下一时间段';

  @override
  String get headerOpenTimePicker => '打开时间选择';

  @override
  String get headerOpenListTabs => '打开标签页选择';

  @override
  String get headerOpenListSettings => '打开列表页设置';

  @override
  String get headerOpenItemTypePicker => '打开事项类型切换';

  @override
  String get homeScopePickerTitle => '显示范围';

  @override
  String get homeScopeWeek => '周';

  @override
  String get homeScopeMonth => '月';

  @override
  String get listTabMyDay => '我的一天';

  @override
  String get listTabAllItems => '全部事项';

  @override
  String get listTabTasks => '任务列表';

  @override
  String get listTabSchedules => '日程列表';

  @override
  String get listTabMemos => '备忘列表';

  @override
  String get listMenuTitle => '切换标签页';

  @override
  String get listSettingsMenuTitle => '列表页设置';

  @override
  String get listSettingsSort => '排序依据';

  @override
  String get listSettingsReorder => '对任务重新排序';

  @override
  String get listSettingsMore => '更多设置';

  @override
  String listSummary(int pending, int completed) {
    return '未完成 $pending 项，已完成 $completed 项';
  }

  @override
  String listPendingSection(int count) {
    return '待处理 $count';
  }

  @override
  String listCompletedSection(int count) {
    return '已完成 $count';
  }

  @override
  String get listCompletedExpand => '展开已完成事项';

  @override
  String get listCompletedCollapse => '收起已完成事项';

  @override
  String get listEmptyTitle => '这里还没有事项';

  @override
  String get listEmptyDescription => '点击右下角加号，先创建第一条任务、日程或备忘。';

  @override
  String get listReorderHint => '当前已进入手动排序，拖动任务右侧的手柄即可重新排列。';

  @override
  String get listStaticItemsLabel => '其他事项';

  @override
  String get listActionEdit => '编辑';

  @override
  String get listActionDelete => '删除';

  @override
  String get listSortDueDate => '到期日期';

  @override
  String get listSortTodayFocus => '今天执行者';

  @override
  String get listSortAlphabetical => '字母顺序';

  @override
  String get listSortCreatedDate => '创建日期';

  @override
  String get listSortManual => '手动排序';

  @override
  String get listStatusPending => '未完成';

  @override
  String get listStatusCompleted => '已完成';

  @override
  String get editorTypePickerTitle => '切换事项类型';

  @override
  String get editorTypeTask => '任务';

  @override
  String get editorTypeSchedule => '日程';

  @override
  String get editorTypeMemo => '备忘';

  @override
  String get editorCreateTask => '创建任务';

  @override
  String get editorCreateSchedule => '创建日程';

  @override
  String get editorCreateMemo => '创建备忘';

  @override
  String get editorEditTask => '编辑任务';

  @override
  String get editorEditSchedule => '编辑日程';

  @override
  String get editorEditMemo => '编辑备忘';

  @override
  String get editorSectionBasic => '基本信息';

  @override
  String get editorSectionColor => '颜色';

  @override
  String get editorSectionTime => '日期与时间';

  @override
  String get editorSectionReminder => '提醒';

  @override
  String get editorSectionRepeat => '重复';

  @override
  String get editorSectionLocationNotes => '地点与备注';

  @override
  String get editorFieldTitle => '名称';

  @override
  String get editorFieldTitleName => '任务名称';

  @override
  String get editorFieldDetails => '详情';

  @override
  String get editorFieldLocation => '地点';

  @override
  String get editorFieldStart => '开始时间';

  @override
  String get editorFieldEnd => '结束时间';

  @override
  String get editorFieldDate => '日期';

  @override
  String get editorFieldStartDate => '开始日期';

  @override
  String get editorFieldStartTime => '开始时间';

  @override
  String get editorFieldEndDate => '结束日期';

  @override
  String get editorFieldEndTime => '结束时间';

  @override
  String get editorFieldDeadline => '截止时间';

  @override
  String get editorFieldDeadlineDate => '截止日期';

  @override
  String get editorFieldDeadlineTime => '截止时刻';

  @override
  String get editorFieldTargetDate => '目标日期';

  @override
  String get editorFieldEstimatedDuration => '预计时长';

  @override
  String get editorHintTitle => '这件事叫什么？';

  @override
  String get editorHintTaskTitle => '任务名称';

  @override
  String get editorHintScheduleTitle => '日程名称';

  @override
  String get editorHintMemoTitle => '备忘名称';

  @override
  String get editorHintCourseTitle => '课程名称';

  @override
  String get editorHintDetails => '备注';

  @override
  String get editorHintLocation => '地点';

  @override
  String get editorColorSky => '天蓝';

  @override
  String get editorColorJade => '翡翠绿';

  @override
  String get editorColorAmber => '琥珀';

  @override
  String get editorColorCoral => '珊瑚红';

  @override
  String get editorColorOrchid => '兰紫';

  @override
  String get editorColorSlate => '石板灰';

  @override
  String get editorColorRose => '玫瑰粉';

  @override
  String get editorColorLime => '酸橙绿';

  @override
  String get editorColorIndigo => '靛蓝';

  @override
  String get editorColorTeal => '鸭绿';

  @override
  String get editorColorCrimson => '绯红';

  @override
  String get editorColorViolet => '紫罗兰';

  @override
  String get editorColorPickerTitle => '选择事项颜色';

  @override
  String get editorAllDayTitle => '全天任务';

  @override
  String get editorAllDayDescription => '开启后只显示日期，不再单独设置具体时分。';

  @override
  String get editorReminderNone => '不提醒';

  @override
  String get editorReminderAtTime => '准时提醒';

  @override
  String get editorReminderFiveMinutes => '提前 5 分钟';

  @override
  String get editorReminderFifteenMinutes => '提前 15 分钟';

  @override
  String get editorReminderOneHour => '提前 1 小时';

  @override
  String get editorReminderOneDay => '提前 1 天';

  @override
  String get editorReminderPageTitle => '提醒设置';

  @override
  String get editorRepeatNone => '不重复';

  @override
  String get editorRepeatDaily => '每天';

  @override
  String get editorRepeatWeekdays => '工作日';

  @override
  String get editorRepeatWeekly => '每周';

  @override
  String get editorRepeatMonthly => '每月';

  @override
  String get editorRepeatYearly => '每年';

  @override
  String get editorRepeatPageTitle => '重复设置';

  @override
  String get editorRepeatPagePlaceholder => '复杂重复规则后续继续扩展。';

  @override
  String get editorDurationPickerTitle => '选择时长';

  @override
  String get editorDeadlineClear => '清除';

  @override
  String get editorDeadlineUnset => '未设置';

  @override
  String get editorPickerCancel => '取消';

  @override
  String get editorPickerConfirm => '确定';

  @override
  String get editorSubmitButton => '创建事项';

  @override
  String get editorSubmitInvalid => '请先修正高亮字段。';

  @override
  String get editorSubmitSuccess => '事项已保存。';

  @override
  String get editorErrorTitleRequired => '请输入名称。';

  @override
  String get editorErrorEndBeforeStart => '结束时间不能早于开始时间。';

  @override
  String get editorErrorDeadlineBeforeStart => '截止时间不能早于开始时间。';

  @override
  String get editorErrorDurationPositive => '时长必须大于 0。';

  @override
  String editorDurationHours(int hours) {
    return '$hours 小时';
  }

  @override
  String editorDurationMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String editorDurationHourMinute(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String detailRangeDate(Object start, Object end) {
    return '$start 至 $end';
  }

  @override
  String detailMemoDate(Object date, Object duration) {
    return '$date · 预计 $duration';
  }

  @override
  String get aiTitle => 'AI 助手';

  @override
  String get aiInputHint => '关于日程的任何问题...';

  @override
  String get settingsAiSectionTitle => 'AI 设置';

  @override
  String get settingsAiBaseUrlLabel => 'API 地址';

  @override
  String get settingsAiApiKeyLabel => 'API 密钥';

  @override
  String get settingsAiModelLabel => '模型';

  @override
  String get settingsAiSystemPromptLabel => '系统提示词';

  @override
  String get settingsAiTestButton => '测试连接';

  @override
  String get settingsAiTestingButton => '测试中...';

  @override
  String get settingsAiSaveButton => '保存 AI 设置';

  @override
  String get settingsAccountLocalTitle => 'Luotopia 账户';

  @override
  String get settingsAccountWhuTitle => '武大账户';

  @override
  String get settingsAccountWhuLoggedIn => '已认证';

  @override
  String get settingsAccountWhuNotLoggedIn => '未登录';

  @override
  String get settingsNavigationEntryTitle => '导航栏设置';

  @override
  String get settingsNavigationEntrySubtitle => '显示文字、中间标签页';

  @override
  String get settingsHomeCourseImport => '课程表导入';

  @override
  String get settingsHomeCourseManagement => '课程表管理';

  @override
  String get settingsHomeTimeGridSettings => '时间方格模式设置';

  @override
  String get settingsHomeCourseGridSettings => '课程方格模式设置';

  @override
  String get placeholderOpenPicker => '打开选择器';

  @override
  String get placeholderOpenMenu => '打开菜单';

  @override
  String get emptyClassroomTitle => '空闲教室';

  @override
  String get emptyClassroomFilterTitle => '筛选条件';

  @override
  String get emptyClassroomFilterCampus => '校区';

  @override
  String get emptyClassroomFilterBuilding => '教学楼';

  @override
  String get emptyClassroomFilterWeek => '周次';

  @override
  String get emptyClassroomFilterWeekDay => '星期';

  @override
  String get emptyClassroomQueryButton => '查询空闲教室';

  @override
  String get emptyClassroomLoginPrompt => '请先登录武大统一认证';

  @override
  String get emptyClassroomGoLogin => '去登录';

  @override
  String get emptyClassroomRetry => '重试';

  @override
  String get emptyClassroomNoResults => '该教学楼当前没有空闲教室';

  @override
  String get emptyClassroomQueryHint => '已选择筛选条件，点击上方按钮查询空闲教室';

  @override
  String emptyClassroomFloorSeats(Object floor, int available, int total) {
    return '$floor楼 · $available/$total 座';
  }

  @override
  String get emptyClassroomSectionHint => '点击节次添加自习';

  @override
  String get emptyClassroomFABTitle => '教室节次管理';

  @override
  String emptyClassroomFABExpanded(int expanded, int total) {
    return '已展开 $expanded / $total 个教室';
  }

  @override
  String get emptyClassroomFABHint => '点击教室右侧箭头展开节次，点击节次方块即可添加到日程';

  @override
  String get emptyClassroomExpandAll => '展开全部';

  @override
  String get emptyClassroomCollapseAll => '收起全部';

  @override
  String get emptyClassroomConflictTitle => '时间冲突';

  @override
  String get emptyClassroomConflictSingle => '该时段已有安排，是否确认加课？';

  @override
  String emptyClassroomConflictMulti(Object sections) {
    return '$sections 已有安排，是否确认加课？';
  }

  @override
  String get emptyClassroomConflictCancel => '取消';

  @override
  String get emptyClassroomConflictConfirm => '确认加课';

  @override
  String get emptyClassroomUndo => '撤销';

  @override
  String emptyClassroomAddedSingle(Object classroom, int section) {
    return '已添加$classroom第$section节课';
  }

  @override
  String emptyClassroomSectionLabel(int section) {
    return '第$section节';
  }

  @override
  String emptyClassroomWeekLabel(Object week) {
    return '第$week周';
  }
}
