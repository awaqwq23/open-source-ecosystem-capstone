import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/pages/all_school_timetable_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/viewmodels/all_school_timetable_view_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class TeachingClassDetailPage extends ConsumerWidget {
  const TeachingClassDetailPage({required this.args, super.key});

  final TeachingClassDetailPageArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachingClassDetailProvider(args.teachingClassId));
    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('课程详情'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CenteredMessage(text: error.toString()),
        data: (data) {
          if (data == null) {
            return const _CenteredMessage(text: '未找到教学班');
          }
          return _TeachingClassDetailContent(
            teachingClass: data.teachingClass,
            meetings: data.meetings,
          );
        },
      ),
    );
  }
}

class _TeachingClassDetailContent extends StatelessWidget {
  const _TeachingClassDetailContent({
    required this.teachingClass,
    required this.meetings,
  });

  final SchoolTeachingClass teachingClass;
  final List<SchoolClassMeeting> meetings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(
          teachingClass.courseName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          [
            teachingClass.courseNo,
            teachingClass.teachingClassName,
            if (teachingClass.credits != null) '${teachingClass.credits} 学分',
          ].join(' · '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        _DetailSection(
          title: '课程信息',
          rows: [
            _InfoRow('开课学院', teachingClass.openCollege),
            _InfoRow('计划学院', teachingClass.planCollege),
            _InfoRow('课程性质', teachingClass.courseNature),
            _InfoRow('课程类别', teachingClass.courseCategory),
            _InfoRow('开课类型', teachingClass.openType),
            _InfoRow('年级专业', _gradeMajor(teachingClass)),
          ],
        ),
        _DetailSection(
          title: '教学班',
          rows: [
            _InfoRow('教师', _teacherLine(teachingClass)),
            _InfoRow('人数', teachingClass.peopleRaw),
            _InfoRow('理论', _hours(teachingClass.theoryHours)),
            _InfoRow('上机', _hours(teachingClass.computerHours)),
            _InfoRow('实验', _hours(teachingClass.experimentHours)),
            _InfoRow('实践', _hours(teachingClass.practiceHours)),
          ],
        ),
        _MeetingSection(meetings: meetings),
        _DetailSection(
          title: '教材备注',
          rows: [
            _InfoRow('选课备注', teachingClass.remark),
            _InfoRow('其他教师', teachingClass.otherTeachers),
            _InfoRow('教材名称', teachingClass.textbook),
            _InfoRow('出版社', teachingClass.publisher),
          ],
        ),
        _OriginalFieldsSection(fields: teachingClass.originalFields),
      ],
    );
  }

  String _teacherLine(SchoolTeachingClass value) {
    return [
      value.instructor,
      if (value.title.isNotEmpty) value.title,
    ].where((item) => item.isNotEmpty).join(' · ');
  }

  String _gradeMajor(SchoolTeachingClass value) {
    return [
      if (value.grade.isNotEmpty) '${value.grade}级',
      if (value.major.isNotEmpty) value.major,
    ].join(' · ');
  }

  String _hours(int? value) => value == null ? '' : '$value 学时';
}

class _MeetingSection extends StatelessWidget {
  const _MeetingSection({required this.meetings});

  final List<SchoolClassMeeting> meetings;

  @override
  Widget build(BuildContext context) {
    final rows = meetings
        .map(
          (item) => _InfoRow(
            item.weekdayLabel,
            [
              item.rawText,
              if (item.locationText.isNotEmpty) item.locationText,
            ].join('\n'),
          ),
        )
        .toList(growable: false);
    return _DetailSection(
      title: '时间地点',
      rows: rows.isEmpty ? const [_InfoRow('安排', '暂无')] : rows,
    );
  }
}

class _OriginalFieldsSection extends StatelessWidget {
  const _OriginalFieldsSection({required this.fields});

  final Map<String, String> fields;

  @override
  Widget build(BuildContext context) {
    const orderedFields = [
      _FieldLabel('xn', '学年'),
      _FieldLabel('xq', '学期'),
      _FieldLabel('jxbmc', '教学班'),
      _FieldLabel('yskch', '课程号'),
      _FieldLabel('kcmc', '课程名称'),
      _FieldLabel('skxy', '开课学院'),
      _FieldLabel('jhxy', '计划学院'),
      _FieldLabel('kcxf', '学分'),
      _FieldLabel('kcxzmc', '课程性质'),
      _FieldLabel('kclbmc', '课程类别名称'),
      _FieldLabel('kklxmc', '开课类型'),
      _FieldLabel('nj', '年级'),
      _FieldLabel('jszy', '专业'),
      _FieldLabel('jsxm', '成绩录入老师'),
      _FieldLabel('jszc', '职称'),
      _FieldLabel('skrs', '上课人数'),
      _FieldLabel('xsdm_01', '理论'),
      _FieldLabel('xsdm_02', '上机'),
      _FieldLabel('xsdm_03', '实验'),
      _FieldLabel('xsdm_04', '实践'),
      _FieldLabel('sun', '周日'),
      _FieldLabel('mon', '周一'),
      _FieldLabel('tue', '周二'),
      _FieldLabel('key', '主键'),
      _FieldLabel('wen', '周三'),
      _FieldLabel('thu', '周四'),
      _FieldLabel('kkbm_id', '开课部门代码'),
      _FieldLabel('jg_id', '学院代码'),
      _FieldLabel('fri', '周五'),
      _FieldLabel('sat', '周六'),
      _FieldLabel('zyh_id', '专业代码'),
      _FieldLabel('xkbz', '选课备注'),
      _FieldLabel('njdm_id', '年级代码'),
      _FieldLabel('xnm', '学年代码'),
      _FieldLabel('bz', '备注'),
      _FieldLabel('xqm', '学期代码'),
      _FieldLabel('kclbdm', '课程类别代码'),
      _FieldLabel('kkbm_id2', '条件'),
      _FieldLabel('qtjs', '其他教师'),
      _FieldLabel('jcmc', '教材名称'),
      _FieldLabel('cbs', '出版社'),
      _FieldLabel('kklxdm', '开课类型代码'),
      _FieldLabel('kcxzdm', '课程性质代码'),
    ];
    final orderedKeys = orderedFields.map((field) => field.key).toSet();
    return _DetailSection(
      title: '原表字段',
      rows: [
        for (final field in orderedFields)
          if (fields.containsKey(field.key))
            _InfoRow('${field.label} (${field.key})', fields[field.key] ?? ''),
        for (final entry in fields.entries)
          if (!orderedKeys.contains(entry.key))
            _InfoRow(entry.key, entry.value),
      ],
      showEmptyValues: true,
    );
  }
}

class _FieldLabel {
  const _FieldLabel(this.key, this.label);

  final String key;
  final String label;
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.rows,
    this.showEmptyValues = false,
  });

  final String title;
  final List<_InfoRow> rows;
  final bool showEmptyValues;

  @override
  Widget build(BuildContext context) {
    final visibleRows = showEmptyValues
        ? rows
        : rows.where((row) => row.value.trim().isNotEmpty).toList();
    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var i = 0; i < visibleRows.length; i++) ...[
                  _DetailRow(row: visibleRows[i]),
                  if (i != visibleRows.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.outlineVariant,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.row});

  final _InfoRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              row.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              row.value.trim().isEmpty ? '无' : row.value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
