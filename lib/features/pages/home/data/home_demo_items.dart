import 'package:flutter/material.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/value_objects/item_memo_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_schedule_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class HomeDemoItemsSource {
  const HomeDemoItemsSource();

  List<AgendaItem> buildForRange(DateTimeRangeValue visibleRange) {
    final firstWeekStart = DateUtils.dateOnly(visibleRange.start).subtract(
      Duration(days: visibleRange.start.weekday - DateTime.monday),
    );
    final lastVisibleDate = visibleRange.end.subtract(const Duration(milliseconds: 1));
    final lastWeekStart = DateUtils.dateOnly(lastVisibleDate).subtract(
      Duration(days: lastVisibleDate.weekday - DateTime.monday),
    );
    final weekCount = lastWeekStart.difference(firstWeekStart).inDays ~/ 7;

    return [
      for (var index = 0; index <= weekCount; index++)
        ...buildForWeek(firstWeekStart.add(Duration(days: index * 7))),
    ].where((item) {
      return item.type != ItemType.memo &&
          item.endAt.isAfter(visibleRange.start) &&
          item.startAt.isBefore(visibleRange.end);
    }).toList();
  }

  List<AgendaItem> buildForWeek(DateTime weekStart) {
    final normalizedWeekStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final createdAt = normalizedWeekStart.subtract(const Duration(days: 14));

    return [
      _schedule(
        id: 'demo_software_requirements',
        title: '操作系统 3K',
        details: '1-428',
        weekStart: normalizedWeekStart,
        dayOffset: 1,
        startHour: 9,
        startMinute: 5,
        endHour: 10,
        endMinute: 35,
        color: ItemColorOption.sky,
        createdAt: createdAt,
      ),
      _schedule(
        id: 'demo_os_lab',
        title: '操作系统 3K',
        details: '1-428',
        weekStart: normalizedWeekStart,
        dayOffset: 2,
        startHour: 9,
        startMinute: 5,
        endHour: 10,
        endMinute: 35,
        color: ItemColorOption.orchid,
        createdAt: createdAt,
      ),
      _schedule(
        id: 'demo_algorithm',
        title: '算法设计与分析 3K',
        details: '2-108',
        weekStart: normalizedWeekStart,
        dayOffset: 3,
        startHour: 9,
        startMinute: 5,
        endHour: 10,
        endMinute: 35,
        color: ItemColorOption.amber,
        createdAt: createdAt,
      ),
      _schedule(
        id: 'demo_marxism',
        title: '习近平新时代中国特色社会主义思想概论',
        details: '2-217',
        weekStart: normalizedWeekStart,
        dayOffset: 3,
        startHour: 14,
        startMinute: 5,
        endHour: 16,
        endMinute: 30,
        color: ItemColorOption.amber,
        createdAt: createdAt,
      ),
      _schedule(
        id: 'demo_prob',
        title: '概率论与数理统计',
        details: '3-402',
        weekStart: normalizedWeekStart,
        dayOffset: 4,
        startHour: 9,
        startMinute: 5,
        endHour: 12,
        endMinute: 15,
        color: ItemColorOption.jade,
        createdAt: createdAt,
      ),
      _schedule(
        id: 'demo_digital_logic',
        title: '软件工程 3K',
        details: '1-304',
        weekStart: normalizedWeekStart,
        dayOffset: 4,
        startHour: 14,
        startMinute: 5,
        endHour: 15,
        endMinute: 40,
        color: ItemColorOption.jade,
        createdAt: createdAt,
      ),
      _schedule(
        id: 'demo_exercise',
        title: '排练',
        details: '活动中心',
        weekStart: normalizedWeekStart,
        dayOffset: 5,
        startHour: 14,
        startMinute: 5,
        endHour: 14,
        endMinute: 50,
        color: ItemColorOption.slate,
        createdAt: createdAt,
      ),
      _schedule(
        id: 'demo_ui',
        title: '软件构造基础 3K',
        details: '1-328',
        weekStart: normalizedWeekStart,
        dayOffset: 5,
        startHour: 9,
        startMinute: 5,
        endHour: 10,
        endMinute: 35,
        color: ItemColorOption.orchid,
        createdAt: createdAt,
      ),
      _schedule(
        id: 'demo_ui_lab',
        title: '软件构造基础 3K',
        details: '1-328',
        weekStart: normalizedWeekStart,
        dayOffset: 5,
        startHour: 14,
        startMinute: 5,
        endHour: 16,
        endMinute: 30,
        color: ItemColorOption.orchid,
        createdAt: createdAt,
      ),
      _task(
        id: 'demo_cleaning',
        title: '寝室春检',
        details: '晚自习前清扫',
        weekStart: normalizedWeekStart,
        dayOffset: 6,
        startHour: 18,
        startMinute: 30,
        endHour: 20,
        endMinute: 55,
        color: ItemColorOption.amber,
        createdAt: createdAt,
      ),
      _task(
        id: 'demo_overlap_a',
        title: '组会',
        details: '讨论主页交互',
        weekStart: normalizedWeekStart,
        dayOffset: 1,
        startHour: 15,
        startMinute: 0,
        endHour: 16,
        endMinute: 0,
        color: ItemColorOption.coral,
        createdAt: createdAt,
      ),
      _task(
        id: 'demo_overlap_b',
        title: '复盘',
        details: '接口梳理',
        weekStart: normalizedWeekStart,
        dayOffset: 1,
        startHour: 15,
        startMinute: 20,
        endHour: 16,
        endMinute: 20,
        color: ItemColorOption.sky,
        createdAt: createdAt,
      ),
    ];
  }

  AgendaItem _schedule({
    required String id,
    required String title,
    required String details,
    required DateTime weekStart,
    required int dayOffset,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required ItemColorOption color,
    required DateTime createdAt,
  }) {
    final start = _dateTime(weekStart, dayOffset, startHour, startMinute);
    final end = _dateTime(weekStart, dayOffset, endHour, endMinute);
    return AgendaItem(
      id: id,
      type: ItemType.schedule,
      title: title,
      details: details,
      location: '',
      color: color,
      reminder: ReminderOption.none,
      repeatRule: RepeatRule.everyWeek,
      scheduleDetails: ItemScheduleDetails(
        range: DateTimeRangeValue(start: start, end: end),
        isAllDay: false,
      ),
      taskDetails: ItemTaskDetails(
        schedule: ItemScheduleDetails(
          range: DateTimeRangeValue(start: start, end: end),
          isAllDay: false,
        ),
        deadline: null,
      ),
      memoDetails: ItemMemoDetails(
        targetDate: start,
        estimatedDuration: end.difference(start),
      ),
      isCompleted: false,
      createdAt: createdAt,
      completedAt: null,
      manualOrder: 0,
    );
  }

  AgendaItem _task({
    required String id,
    required String title,
    required String details,
    required DateTime weekStart,
    required int dayOffset,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required ItemColorOption color,
    required DateTime createdAt,
  }) {
    final start = _dateTime(weekStart, dayOffset, startHour, startMinute);
    final end = _dateTime(weekStart, dayOffset, endHour, endMinute);
    return AgendaItem(
      id: id,
      type: ItemType.task,
      title: title,
      details: details,
      location: '',
      color: color,
      reminder: ReminderOption.fifteenMinutesBefore,
      repeatRule: RepeatRule.none,
      scheduleDetails: ItemScheduleDetails(
        range: DateTimeRangeValue(start: start, end: end),
        isAllDay: false,
      ),
      taskDetails: ItemTaskDetails(
        schedule: ItemScheduleDetails(
          range: DateTimeRangeValue(start: start, end: end),
          isAllDay: false,
        ),
        deadline: end,
      ),
      memoDetails: ItemMemoDetails(
        targetDate: start,
        estimatedDuration: end.difference(start),
      ),
      isCompleted: false,
      createdAt: createdAt,
      completedAt: null,
      manualOrder: 0,
    );
  }

  DateTime _dateTime(
    DateTime weekStart,
    int dayOffset,
    int hour,
    int minute,
  ) {
    return DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + dayOffset,
      hour,
      minute,
    );
  }
}
