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

class ListDemoItemsSource {
  const ListDemoItemsSource();

  static const idPrefix = 'debug_list_';

  List<AgendaItem> build(DateTime now) {
    final today = DateUtils.dateOnly(now);
    final createdAt = today.subtract(const Duration(days: 7));

    return [
      _task(
        id: '${idPrefix}task_today_1',
        title: '补齐列表页交互边界',
        details: '检查滑动、空行和重要标记',
        start: _at(today, 9, 0),
        end: _at(today, 10, 0),
        deadline: _at(today, 11, 30),
        color: ItemColorOption.sky,
        createdAt: createdAt,
        manualOrder: 0,
      ),
      _task(
        id: '${idPrefix}task_today_2',
        title: '整理录屏用示例数据',
        details: '补几条已完成和备忘',
        start: _at(today, 10, 30),
        end: _at(today, 11, 30),
        deadline: _at(today, 18, 0),
        color: ItemColorOption.coral,
        createdAt: createdAt.add(const Duration(hours: 1)),
        manualOrder: 1,
      ),
      _task(
        id: '${idPrefix}task_today_3',
        title: '给导师发阶段进度',
        details: '附上本周功能截图',
        start: _at(today, 14, 0),
        end: _at(today, 14, 30),
        deadline: _at(today, 17, 0),
        color: ItemColorOption.amber,
        createdAt: createdAt.add(const Duration(hours: 2)),
        manualOrder: 2,
        isCompleted: true,
        completedAt: _at(today, 15, 10),
      ),
      _task(
        id: '${idPrefix}task_tomorrow',
        title: '准备答辩提纲',
        details: '列出三页演示重点',
        start: _at(today.add(const Duration(days: 1)), 8, 30),
        end: _at(today.add(const Duration(days: 1)), 9, 30),
        deadline: _at(today.add(const Duration(days: 1)), 21, 0),
        color: ItemColorOption.jade,
        createdAt: createdAt.add(const Duration(hours: 3)),
        manualOrder: 3,
      ),
      _schedule(
        id: '${idPrefix}schedule_today',
        title: '产品走查会',
        details: '讨论列表页新布局',
        start: _at(today, 16, 0),
        end: _at(today, 17, 0),
        color: ItemColorOption.orchid,
        createdAt: createdAt.add(const Duration(hours: 4)),
        manualOrder: 4,
      ),
      _schedule(
        id: '${idPrefix}schedule_future',
        title: '周例会',
        details: '同步主页与列表页进度',
        start: _at(today.add(const Duration(days: 2)), 9, 30),
        end: _at(today.add(const Duration(days: 2)), 10, 30),
        color: ItemColorOption.slate,
        createdAt: createdAt.add(const Duration(hours: 5)),
        manualOrder: 5,
      ),
      _memo(
        id: '${idPrefix}memo_today',
        title: '记得检查深色主题',
        details: '重点看分割线和图标对比度',
        targetDate: _at(today, 20, 0),
        estimatedDuration: const Duration(minutes: 25),
        color: ItemColorOption.sky,
        createdAt: createdAt.add(const Duration(hours: 6)),
        manualOrder: 6,
      ),
      _memo(
        id: '${idPrefix}memo_done',
        title: '确认标签页文案',
        details: '中英文都过一遍',
        targetDate: _at(today, 12, 0),
        estimatedDuration: const Duration(minutes: 20),
        color: ItemColorOption.jade,
        createdAt: createdAt.add(const Duration(hours: 7)),
        manualOrder: 7,
        isCompleted: true,
        completedAt: _at(today, 12, 20),
      ),
      _task(
        id: '${idPrefix}task_old_done',
        title: '清理旧截图',
        details: '保留最新一版效果图',
        start: _at(today.subtract(const Duration(days: 1)), 19, 0),
        end: _at(today.subtract(const Duration(days: 1)), 19, 40),
        deadline: _at(today.subtract(const Duration(days: 1)), 22, 0),
        color: ItemColorOption.slate,
        createdAt: createdAt.add(const Duration(hours: 8)),
        manualOrder: 8,
        isCompleted: true,
        completedAt: _at(today.subtract(const Duration(days: 1)), 20, 5),
      ),
      _task(
        id: '${idPrefix}task_done_later',
        title: '修正列表页滚动留白',
        details: '确认到底部不会露出多余空白',
        start: _at(today, 13, 0),
        end: _at(today, 13, 30),
        deadline: _at(today, 13, 30),
        color: ItemColorOption.coral,
        createdAt: createdAt.add(const Duration(hours: 9)),
        manualOrder: 9,
        isCompleted: true,
        completedAt: _at(today, 13, 35),
      ),
    ];
  }

  AgendaItem _task({
    required String id,
    required String title,
    required String details,
    required DateTime start,
    required DateTime end,
    required DateTime deadline,
    required ItemColorOption color,
    required DateTime createdAt,
    required double manualOrder,
    bool isCompleted = false,
    DateTime? completedAt,
  }) {
    final schedule = ItemScheduleDetails(
      range: DateTimeRangeValue(start: start, end: end),
      isAllDay: false,
    );
    return AgendaItem(
      id: id,
      type: ItemType.task,
      title: title,
      details: details,
      location: '',
      color: color,
      reminder: ReminderOption.fifteenMinutesBefore,
      repeatRule: RepeatRule.none,
      scheduleDetails: schedule,
      taskDetails: ItemTaskDetails(
        schedule: schedule,
        deadline: deadline,
      ),
      memoDetails: ItemMemoDetails(
        targetDate: start,
        estimatedDuration: end.difference(start),
      ),
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      manualOrder: manualOrder,
    );
  }

  AgendaItem _schedule({
    required String id,
    required String title,
    required String details,
    required DateTime start,
    required DateTime end,
    required ItemColorOption color,
    required DateTime createdAt,
    required double manualOrder,
  }) {
    final schedule = ItemScheduleDetails(
      range: DateTimeRangeValue(start: start, end: end),
      isAllDay: false,
    );
    return AgendaItem(
      id: id,
      type: ItemType.schedule,
      title: title,
      details: details,
      location: '',
      color: color,
      reminder: ReminderOption.atTime,
      repeatRule: RepeatRule.none,
      scheduleDetails: schedule,
      taskDetails: ItemTaskDetails(
        schedule: schedule,
        deadline: null,
      ),
      memoDetails: ItemMemoDetails(
        targetDate: start,
        estimatedDuration: end.difference(start),
      ),
      isCompleted: false,
      createdAt: createdAt,
      completedAt: null,
      manualOrder: manualOrder,
    );
  }

  AgendaItem _memo({
    required String id,
    required String title,
    required String details,
    required DateTime targetDate,
    required Duration estimatedDuration,
    required ItemColorOption color,
    required DateTime createdAt,
    required double manualOrder,
    bool isCompleted = false,
    DateTime? completedAt,
  }) {
    final schedule = ItemScheduleDetails(
      range: DateTimeRangeValue(start: targetDate, end: targetDate.add(estimatedDuration)),
      isAllDay: false,
    );
    return AgendaItem(
      id: id,
      type: ItemType.memo,
      title: title,
      details: details,
      location: '',
      color: color,
      reminder: ReminderOption.none,
      repeatRule: RepeatRule.none,
      scheduleDetails: schedule,
      taskDetails: ItemTaskDetails(
        schedule: schedule,
        deadline: null,
      ),
      memoDetails: ItemMemoDetails(
        targetDate: targetDate,
        estimatedDuration: estimatedDuration,
      ),
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      manualOrder: manualOrder,
    );
  }

  DateTime _at(DateTime day, int hour, int minute) {
    return DateTime(day.year, day.month, day.day, hour, minute);
  }
}
