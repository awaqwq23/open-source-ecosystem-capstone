import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/motion/app_motion_widgets.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/viewmodels/all_school_timetable_view_model.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/widgets/timetable_list_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AllSchoolTimetablePage extends ConsumerStatefulWidget {
  const AllSchoolTimetablePage({super.key});

  @override
  ConsumerState<AllSchoolTimetablePage> createState() =>
      _AllSchoolTimetablePageState();
}

class _AllSchoolTimetablePageState
    extends ConsumerState<AllSchoolTimetablePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(allSchoolTimetableViewModelProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    ref
        .read(allSchoolTimetableViewModelProvider.notifier)
        .setKeyword(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allSchoolTimetableViewModelProvider);
    final notifier = ref.read(allSchoolTimetableViewModelProvider.notifier);
    final theme = Theme.of(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('全校课表'),
          trailing: [
            ui.IconButton.ghost(
              onPressed: state.isSyncing ? null : () => notifier.sync(),
              icon: state.isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: ui.CircularProgressIndicator(size: 16),
                    )
                  : const Icon(Icons.sync, size: 20),
            ),
          ],
        ),
      ],
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _TermStatus(state: state),
          const SizedBox(height: 12),
          _SearchBar(
            controller: _searchController,
            hasKeyword: state.query.keyword.isNotEmpty,
            onClear: () {
              _searchController.clear();
              notifier.clearKeyword();
            },
            onSubmitted: (_) => _submitSearch(),
            onSearch: _submitSearch,
          ),
          const SizedBox(height: 10),
          _FilterStrip(state: state, notifier: notifier),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  state.isLoading
                      ? '正在查询'
                      : '${state.courseHeads.length} 门课 · 相关度优先',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (state.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: ui.CircularProgressIndicator(size: 16),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.errorMessage != null)
            _StatusCard(text: state.errorMessage!)
          else if (!state.hasLoaded ||
              state.isLoading && state.courseHeads.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: ui.CircularProgressIndicator()),
            )
          else if (state.courseHeads.isEmpty)
            _StatusCard(
              text: state.terms.isEmpty
                  ? '暂无全校课表数据，等待更新'
                  : state.query.keyword.isEmpty &&
                        !state.query.hasAdvancedFilters
                  ? '以上是当前学期信息，搜索或筛选以查看课程'
                  : '没有找到符合条件的课程',
            )
          else
            ...state.courseHeads.map(
              (head) => _CourseHeadTile(
                head: head,
                onTap: () => context.openSecondary(
                  AppRoutePaths.campusAllSchoolTimetableHead,
                  extra: CourseHeadPageArgs(head.termKey, head.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hasKeyword,
    required this.onClear,
    required this.onSubmitted,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool hasKeyword;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: '搜课程、老师、课程号、教室',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: hasKeyword
                  ? IconButton(
                      tooltip: '清空搜索',
                      icon: const Icon(Icons.close),
                      onPressed: onClear,
                    )
                  : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              filled: true,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(onPressed: onSearch, child: const Text('搜索')),
      ],
    );
  }
}

class _TermStatus extends StatelessWidget {
  const _TermStatus({required this.state});

  final AllSchoolTimetableState state;

  @override
  Widget build(BuildContext context) {
    final term = state.selectedTerm;
    final colors = Theme.of(context).colorScheme;
    final text = term == null
        ? '暂无本地全校课表数据'
        : '${term.schoolYear} 第${term.term}学期 · ${term.rowCount} 条教学班';
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({required this.state, required this.notifier});

  final AllSchoolTimetableState state;
  final AllSchoolTimetableViewModel notifier;

  @override
  Widget build(BuildContext context) {
    final query = state.query;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterPill(
            label: state.selectedTerm == null
                ? '学期'
                : '${state.selectedTerm!.schoolYear}-${state.selectedTerm!.term}',
            icon: Icons.calendar_month,
            active: state.selectedTerm != null,
            onTap: () => _showTermPicker(context),
          ),
          _FilterPill(
            label: query.courseNature.isEmpty ? '课程性质' : query.courseNature,
            icon: Icons.category_outlined,
            active: query.courseNature.isNotEmpty,
            onTap: () => _showOptionSheet(
              context: context,
              title: '课程性质',
              options: _courseNatureOptions,
              value: query.courseNature,
              onSelected: (value) => notifier.applyAdvancedFilters(
                courseName: query.courseName,
                teacher: query.teacher,
                teachingClass: query.teachingClass,
                openDepartment: query.openDepartment,
                studentCollege: query.studentCollege,
                grade: query.grade,
                major: query.major,
                courseCategory: query.courseCategory,
                departmentOrCollege: query.departmentOrCollege,
                openType: query.openType,
                courseNature: value,
              ),
            ),
          ),
          _FilterPill(
            label: '更多筛选',
            icon: Icons.tune,
            active: _hasMoreFilters(query),
            onTap: () => _showAdvancedFilters(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showTermPicker(BuildContext context) {
    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) => AppSheetEntrance(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择学期',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              for (final term in state.terms)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ui.CardButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () {
                      notifier.setTerm(term.termKey);
                      ui.closeSheet(sheetContext);
                    },
                    trailing: state.query.termKey == term.termKey
                        ? const Icon(Icons.check)
                        : null,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${term.schoolYear} 第${term.term}学期'),
                          const SizedBox(height: 2),
                          Text(
                            '${term.rowCount} 条教学班',
                            style: Theme.of(sheetContext).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    sheetContext,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOptionSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String value,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(
              title,
              style: Theme.of(
                sheetContext,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: options.contains(value) ? value : '',
              onChanged: (selected) {
                if (selected != null) {
                  onSelected(selected);
                  Navigator.of(sheetContext).pop();
                }
              },
              child: Column(
                children: [
                  for (final option in options)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: option,
                      title: Text(_optionLabel(option)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdvancedFilters(BuildContext context) {
    final query = state.query;
    final courseName = TextEditingController(text: query.courseName);
    final teacher = TextEditingController(text: query.teacher);
    final teachingClass = TextEditingController(text: query.teachingClass);
    final major = TextEditingController(text: query.major);
    var openDepartment = query.openDepartment;
    var studentCollege = query.studentCollege;
    var grade = query.grade;
    var courseCategory = query.courseCategory;
    var departmentOrCollege = query.departmentOrCollege;
    var openType = query.openType;
    var courseNature = query.courseNature;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '更多筛选',
                      style: Theme.of(sheetContext).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    _SheetTextField(label: '课程名称', controller: courseName),
                    _SheetTextField(label: '教师', controller: teacher),
                    _SheetTextField(label: '教学班', controller: teachingClass),
                    _SheetSelectField(
                      label: '开课部门',
                      value: openDepartment,
                      options: _departmentOptions,
                      onChanged: (value) =>
                          setSheetState(() => openDepartment = value),
                    ),
                    _SheetSelectField(
                      label: '学生学院',
                      value: studentCollege,
                      options: _departmentOptions,
                      onChanged: (value) =>
                          setSheetState(() => studentCollege = value),
                    ),
                    _SheetSelectField(
                      label: '年级',
                      value: grade,
                      options: _gradeOptions,
                      onChanged: (value) => setSheetState(() => grade = value),
                    ),
                    _SheetTextField(label: '专业', controller: major),
                    _SheetSelectField(
                      label: '课程类别',
                      value: courseCategory,
                      options: _courseCategoryOptions,
                      onChanged: (value) =>
                          setSheetState(() => courseCategory = value),
                    ),
                    _SheetSelectField(
                      label: '开课部门或学生学院',
                      value: departmentOrCollege,
                      options: _departmentOptions,
                      onChanged: (value) =>
                          setSheetState(() => departmentOrCollege = value),
                    ),
                    _SheetSelectField(
                      label: '开课类型',
                      value: openType,
                      options: _openTypeOptions,
                      onChanged: (value) =>
                          setSheetState(() => openType = value),
                    ),
                    _SheetSelectField(
                      label: '课程性质',
                      value: courseNature,
                      options: _courseNatureOptions,
                      onChanged: (value) =>
                          setSheetState(() => courseNature = value),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            notifier.clearAdvancedFilters();
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('清空'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            notifier.applyAdvancedFilters(
                              courseName: courseName.text.trim(),
                              teacher: teacher.text.trim(),
                              teachingClass: teachingClass.text.trim(),
                              openDepartment: openDepartment,
                              studentCollege: studentCollege,
                              grade: grade,
                              major: major.text.trim(),
                              courseCategory: courseCategory,
                              departmentOrCollege: departmentOrCollege,
                              openType: openType,
                              courseNature: courseNature,
                            );
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('查看结果'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      courseName.dispose();
      teacher.dispose();
      teachingClass.dispose();
      major.dispose();
    });
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class _SheetSelectField extends StatelessWidget {
  const _SheetSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = options.contains(value) ? value : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return DropdownMenu<String>(
            initialSelection: selectedValue,
            width: constraints.maxWidth,
            menuHeight: 360,
            label: Text(label),
            dropdownMenuEntries: [
              for (final option in options)
                DropdownMenuEntry(value: option, label: _optionLabel(option)),
            ],
            onSelected: (value) => onChanged(value ?? ''),
          );
        },
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: active,
        showCheckmark: false,
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _CourseHeadTile extends StatelessWidget {
  const _CourseHeadTile({required this.head, required this.onTap});

  final SchoolCourseHead head;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final credits = head.credits == null ? '' : '${head.credits} 学分';
    return TimetableListButton(
      title: head.courseName,
      meta:
          '${head.courseNo} · ${head.openCollege} · ${head.teachingClassCount} 个教学班',
      detail: [
        if (head.teacherSummary.isNotEmpty) head.teacherSummary,
        if (head.weekdaySummary.isNotEmpty) head.weekdaySummary,
      ].join(' · '),
      trailingLabel: credits,
      onPressed: onTap,
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

bool _hasMoreFilters(AllSchoolTimetableQuery query) {
  return query.courseName.isNotEmpty ||
      query.teacher.isNotEmpty ||
      query.teachingClass.isNotEmpty ||
      query.openDepartment.isNotEmpty ||
      query.studentCollege.isNotEmpty ||
      query.grade.isNotEmpty ||
      query.major.isNotEmpty ||
      query.courseCategory.isNotEmpty ||
      query.departmentOrCollege.isNotEmpty ||
      query.openType.isNotEmpty;
}

String _optionLabel(String option) => option.isEmpty ? '全部' : option;

class CourseHeadPageArgs {
  const CourseHeadPageArgs(this.termKey, this.courseHeadId);

  final String termKey;
  final String courseHeadId;
}

class TeachingClassDetailPageArgs {
  const TeachingClassDetailPageArgs(this.termKey, this.teachingClassId);

  final String termKey;
  final String teachingClassId;
}

const _courseCategoryOptions = [
  '',
  '创新创业课程',
  '核心课程',
  '一般通识',
  '无',
  '跨学院公共基础课',
  '核心通识',
  '专业课程',
  '大类平台',
];

const _openTypeOptions = [
  '',
  '专业教育课程',
  '微专业课程',
  '二学位',
  '辅修课程',
  '体育',
  '板块',
  '英语',
  '重修课程',
  '其它特殊课程',
  '通识课程',
  '其他课程（含学科竞赛培训、国际学生课程）',
  '通识必修课程',
  '跨专业选修课',
  '直考课程',
  '创新创业课程',
];

const _courseNatureOptions = [
  '',
  '公共基础必修',
  '公共基础选修',
  '通识教育必修',
  '通识教育选修',
  '专业教育必修',
  '专业教育选修',
  '公共必修',
  '公共选修',
  '专业必修',
  '专业选修',
];

final _gradeOptions = [
  '',
  for (var year = 2030; year >= 1999; year--) year.toString(),
];

const _departmentOptions = [
  '',
  '国家文化发展研究院',
  '高等研究院',
  '中国南极测绘研究中心',
  '工学部',
  'EMBA',
  'MBA',
  'WTO学院',
  '本科生院',
  '材料科学与工程学院',
  '测绘学院',
  '城市设计学院',
  '大学生心理健康中心',
  '大学英语部',
  '电气与自动化学院',
  '动力与机械学院',
  '发展研究院',
  '法学院',
  '高级研究中心',
  '工程图学中心',
  '公共化学教学',
  '公共力学',
  '公共数学教学',
  '公共卫生学院',
  '公共文学教学',
  '公共物理教学',
  '公共政治教学',
  '国际交流部',
  '国际教育学院',
  '国际软件学院',
  '国家网络安全学院',
  '国学院',
  '弘毅学堂',
  '护理学院',
  '化学与分子科学学院',
  '计算机学院',
  '计算中心',
  '健康学院',
  '教师教学发展中心',
  '教务部',
  '教育发展基金工作办',
  '教育科学研究院',
  '经济与管理学院',
  '学生就业指导与服务中心',
  '军官选拔办公室',
  '军事教研室',
  '口腔医学院',
  '历史学院',
  '七校联办',
  '其它',
  '全校',
  '社会学院',
  '生命科学学院',
  '数学与统计学院',
  '双学位',
  '水利水电学院',
  '台湾研究所',
  '体育部',
  '通识教育中心',
  '图书馆',
  '土木建筑工程学院',
  '外国语言文学学院',
  '物理科学与技术学院',
  '档案馆',
  '共青团武汉大学委员会',
  '信息管理学院',
  '形势与政策教育中心',
  '学工部',
  '训创中心',
  '遥感信息工程学院',
  '药学院',
  '医学部',
  '医学院',
  '印刷与包装系',
  '政治与公共管理学院',
  '职业培训学院',
  '中国边界与海洋研究院',
  '中国传统文化研究中心',
  '资源与环境科学学院',
  '中国中部发展研究院',
  '动物实验中心',
  '图像传播与印刷包装研究中心',
  '武汉大学杜伦大学联合学院',
  '地球与空间科学技术学院',
  '人工智能学院',
  '国家卓越工程师学院',
  '机器人学院',
  '集成电路学院',
  '马克思主义学院',
  '总务后勤部',
  '附属学校',
  '资产经营投资管理有限责任公司',
  '房地产管理部',
  '湖北珞珈实验室',
  '国际法研究所',
  '离退休工作处',
  '审计处',
  '采购与招投标管理中心',
  '党委巡视工作领导小组办公室',
  '党委宣传部',
  '实验室与设备管理处',
  '先进技术研究院',
  '人民武装部',
  '汉语国际推广教学资源研究与开发基地',
  '董辅礽经济社会发展研究院',
  '纪委、监察专员办',
  '党委组织部',
  '党校',
  '党委学生工作部',
  '机关与直属单位党委',
  '工会',
  '科学技术发展研究院',
  '保卫部',
  '保密委员会办公室',
  '医学职业技术学院',
  '广东研究院',
  '宜昌三峡研究院',
  '西南研究院',
  '湖北发展问题研究中心',
  '武汉先进光源研究中心建设工程项目工程建设指挥部办公室',
  '泰康生命医学中心',
  '科研公共服务条件平台',
  '国内合作部',
  '财政金融研究中心',
  '党内法规研究中心',
  '国家领土主权与海洋权益协同创新中心',
  '地球空间信息技术协同创新中心',
  '出版社有限责任公司',
  '珞珈学院',
  '党政办公室',
  '苏州研究院',
  '水工程科学研究院',
  '国际法治研究院',
  '中国发展战略与规划研究院',
  '发展规划与学科建设办公室',
  '党委研究生工作部',
  '党委统战部',
  '财务部',
  '新闻与传播学院',
  '武汉大学中国发展战略与规划研究院',
  '人事部',
  '前沿交叉学科研究院',
  '质量发展战略研究院',
  '测绘遥感信息工程全国重点实验室',
  '医学研究院',
  '泰康医学院(基础医学院)',
  '继续教育学院',
  '校友事务与发展联络处',
  '第一临床学院',
  '第二临床学院',
  '校医院',
  '国际问题研究院',
  '武汉数学与智能研究院',
  '新型电力系统与国际标准研究院',
  '简帛研究中心',
  '文化遗产智能计算实验室',
  '中华民族共同体法治研究院',
  '数据智能研究院',
  '水资源工程与调度全国重点实验室',
  '杂交水稻全国重点实验室',
  '电网环境保护全国重点实验室',
  '湖北应用数学中心',
  '口颌系统重建与再生全国重点实验室',
  '国家多媒体软件工程技术研究中心',
  '武汉大气遥感国家野外科学观测研究站',
  '卫星导航定位技术研究中心（国家卫星定位系统工程技术研究中心）',
  '《民藏》编纂与研究中心',
  '先进光源研究中心',
  '碳中和研究院',
  '复杂生命体代谢与调控全国重点实验室',
  '科技与产业学院',
  '涉外法治学院',
  '武汉大学武汉-本哈研究生院',
  '辛亥革命博物院-武汉大学国家革命文物协同研究中心',
  '高致病性病毒与生物安全全国重点实验室',
  '梁子湖湖泊生态系统国家野外科学观测站',
  '智慧校园部',
  '人文社会科学研究院',
  '计算机教研室01',
  '哲学学院',
  '基建管理部（文物保护管理处）',
  '科教融合创新园区建设指挥部办公室',
  '纪检监察研究院',
  '教育部法治国际组织联合研究院',
  '文学院',
  '艺术学院',
  '电子信息学院',
  '研究生院',
  '工业科学研究院',
];
