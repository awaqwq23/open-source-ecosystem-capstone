import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/agenda_item_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class EmptyClassroomAgendaDraftContext {
  const EmptyClassroomAgendaDraftContext({
    required this.termInfo,
    required this.selectedWeek,
    required this.selectedWeekDay,
  });

  final TermInfo termInfo;
  final String selectedWeek;
  final String selectedWeekDay;
}

class BuildEmptyClassroomAgendaDraftUseCase {
  const BuildEmptyClassroomAgendaDraftUseCase();

  DateTimeRangeValue sectionRange({
    required EmptyClassroomAgendaDraftContext context,
    required int section,
    required DateTime now,
  }) {
    final currentWeek = int.tryParse(context.termInfo.currentWeek);
    final targetWeek = int.tryParse(context.selectedWeek);
    final targetWeekDay = int.tryParse(context.selectedWeekDay);
    if (currentWeek == null || targetWeek == null || targetWeekDay == null) {
      throw Exception('空闲教室周次信息异常，无法添加到日程。');
    }
    if (targetWeekDay < 1 || targetWeekDay > 7) {
      throw Exception('空闲教室星期信息异常，无法添加到日程。');
    }

    final currentMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final targetMonday = currentMonday.add(
      Duration(days: (targetWeek - currentWeek) * 7),
    );
    final targetDate = targetMonday.add(Duration(days: targetWeekDay - 1));

    final periodIndex = _periodIndex(section);
    if (periodIndex < 0 || periodIndex >= _coursePeriods.length) {
      throw Exception('第$section节时间信息异常，无法添加到日程。');
    }
    final (startMinute, endMinute) = _coursePeriods[periodIndex];
    return DateTimeRangeValue(
      start: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        startMinute ~/ 60,
        startMinute % 60,
      ),
      end: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        endMinute ~/ 60,
        endMinute % 60,
      ),
    );
  }

  ItemDraft call({
    required EmptyClassroom classroom,
    required int section,
    required EmptyClassroomAgendaDraftContext context,
    required DateTime now,
  }) {
    final range = sectionRange(context: context, section: section, now: now);
    final location = '${classroom.building} ${classroom.name}';
    return ItemDraft(
      type: ItemType.schedule,
      title: '$location 自习',
      notes: '',
      location: location,
      color: colorForSection(section),
      reminder: ReminderOption.none,
      repeatRule: RepeatRule.none,
      details: ScheduleItemDetails(
        startAt: range.start,
        endAt: range.end,
        isAllDay: false,
      ),
    );
  }

  ItemColorOption colorForSection(int section) {
    final options = ItemColorOption.values;
    return options[(section - 1) % options.length];
  }

  int _periodIndex(int section) {
    return section <= 5 ? section - 1 : section;
  }
}

const _coursePeriods = <(int, int)>[
  (480, 525),
  (530, 575),
  (590, 635),
  (640, 685),
  (690, 735),
  (735, 845),
  (845, 890),
  (895, 940),
  (945, 990),
  (1000, 1045),
  (1050, 1095),
  (1110, 1155),
  (1160, 1205),
  (1210, 1255),
];
