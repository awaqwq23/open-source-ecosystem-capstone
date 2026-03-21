import 'package:flutter/material.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:intl/intl.dart';

class BuildHomeGridUseCase {
  const BuildHomeGridUseCase();

  HomeViewData build({
    required String localeTag,
    required DateTime anchor,
    required HomeHeaderScope scope,
    required DateTime? selectedDate,
    required List<HomeLaidOutItem> items,
  }) {
    final visibleRange = _visibleRange(anchor, scope);
    final timeSlots = _buildTimeSlots(anchor);
    final columns = _buildColumns(
      visibleRange,
      selectedDate: selectedDate,
      localeTag: localeTag,
    );
    final metrics = _buildMetrics(timeSlots);
    return HomeViewData(
      periodLabel: _formatPeriodLabel(anchor, localeTag),
      periodSubtitle: _formatPeriodSubtitle(anchor, localeTag),
      metrics: metrics,
      visibleRange: visibleRange,
      columns: columns,
      timeSlots: timeSlots,
      items: items,
    );
  }

  DateTimeRangeValue _visibleRange(DateTime anchor, HomeHeaderScope scope) {
    if (scope == HomeHeaderScope.month) {
      final start = DateTime(anchor.year, anchor.month, 1);
      final end = DateTime(anchor.year, anchor.month + 1, 1);
      return DateTimeRangeValue(start: start, end: end);
    }

    final weekdayOffset = anchor.weekday - DateTime.monday;
    final start = DateUtils.dateOnly(anchor).subtract(Duration(days: weekdayOffset));
    return DateTimeRangeValue(
      start: start,
      end: start.add(const Duration(days: 7)),
    );
  }

  List<HomeDayColumn> _buildColumns(
    DateTimeRangeValue visibleRange,
    {
    required DateTime? selectedDate,
    required String localeTag,
  }
  ) {
    final dayCount = visibleRange.end.difference(visibleRange.start).inDays;
    final today = DateUtils.dateOnly(DateTime.now());
    final normalizedSelected = selectedDate == null
        ? null
        : DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final weekdayFormatter = localeTag.startsWith('zh')
        ? DateFormat('E', localeTag)
        : DateFormat('EEE', localeTag);
    final dateFormatter = DateFormat('M-d', localeTag);

    return [
      for (var index = 0; index < dayCount; index++)
        () {
          final date = visibleRange.start.add(Duration(days: index));
          final normalizedDate = DateUtils.dateOnly(date);
          final weekdayLabel = localeTag.startsWith('zh')
              ? '周${_weekdayLabel(date.weekday)}'
              : weekdayFormatter.format(date);
          return HomeDayColumn(
            date: date,
            weekdayLabel: weekdayLabel,
            dateLabel: dateFormatter.format(date),
            isToday: normalizedDate == today,
            isSelected: normalizedSelected == normalizedDate,
            emphasize: date.weekday == DateTime.saturday,
          );
        }(),
    ];
  }

  List<HomeTimeSlot> _buildTimeSlots(DateTime anchor) {
    final base = DateTime(anchor.year, anchor.month, anchor.day);
    const slots = <({int startHour, int startMinute, int endHour, int endMinute})>[
      (startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
      (startHour: 8, startMinute: 50, endHour: 9, endMinute: 35),
      (startHour: 9, startMinute: 50, endHour: 10, endMinute: 35),
      (startHour: 10, startMinute: 40, endHour: 11, endMinute: 25),
      (startHour: 11, startMinute: 30, endHour: 12, endMinute: 15),
      (startHour: 14, startMinute: 5, endHour: 14, endMinute: 50),
      (startHour: 14, startMinute: 55, endHour: 15, endMinute: 40),
      (startHour: 15, startMinute: 45, endHour: 16, endMinute: 30),
      (startHour: 16, startMinute: 40, endHour: 17, endMinute: 25),
      (startHour: 17, startMinute: 30, endHour: 18, endMinute: 15),
      (startHour: 18, startMinute: 30, endHour: 19, endMinute: 15),
      (startHour: 19, startMinute: 20, endHour: 20, endMinute: 5),
      (startHour: 20, startMinute: 10, endHour: 20, endMinute: 55),
    ];

    return [
      for (final slot in slots)
        HomeTimeSlot(
          label:
              '${_pad(slot.startHour)}:${_pad(slot.startMinute)}\n${_pad(slot.endHour)}:${_pad(slot.endMinute)}',
          start: DateTime(
            base.year,
            base.month,
            base.day,
            slot.startHour,
            slot.startMinute,
          ),
          end: DateTime(
            base.year,
            base.month,
            base.day,
            slot.endHour,
            slot.endMinute,
          ),
          startMinute: slot.startHour * 60 + slot.startMinute,
          endMinute: slot.endHour * 60 + slot.endMinute,
        ),
    ];
  }

  HomeLayoutMetrics _buildMetrics(List<HomeTimeSlot> timeSlots) {
    final totalMinutes = timeSlots.last.endMinute - timeSlots.first.startMinute;
    return HomeLayoutMetrics(
      columnWidth: 72,
      columnGap: 8,
      timelineWidth: 44,
      startMinuteOfDay: timeSlots.first.startMinute,
      totalMinutes: totalMinutes,
    );
  }

  String _formatPeriodLabel(DateTime anchor, String localeTag) {
    final monday = DateUtils.dateOnly(
      anchor.subtract(Duration(days: anchor.weekday - DateTime.monday)),
    );
    final weekNumber = _weekOfYear(monday);
    if (localeTag.startsWith('zh')) {
      return '第$weekNumber周';
    }
    return 'Week $weekNumber';
  }

  String _formatPeriodSubtitle(DateTime anchor, String localeTag) {
    final monday = DateUtils.dateOnly(
      anchor.subtract(Duration(days: anchor.weekday - DateTime.monday)),
    );
    final formatter = DateFormat('M/d', localeTag);
    final sunday = monday.add(const Duration(days: 6));
    final isCurrentWeek = _isSameWeek(monday, DateTime.now());
    if (localeTag.startsWith('zh')) {
      return isCurrentWeek
          ? '本周 · ${formatter.format(monday)}-${formatter.format(sunday)}'
          : '${formatter.format(monday)}-${formatter.format(sunday)}';
    }
    return isCurrentWeek
        ? 'This week · ${formatter.format(monday)}-${formatter.format(sunday)}'
        : '${formatter.format(monday)}-${formatter.format(sunday)}';
  }

  int _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final offset = firstDay.weekday - DateTime.monday;
    final dayOfYear = date.difference(firstDay).inDays + 1;
    return ((dayOfYear + offset - 1) ~/ 7) + 1;
  }

  bool _isSameWeek(DateTime left, DateTime right) {
    final leftMonday = DateUtils.dateOnly(
      left.subtract(Duration(days: left.weekday - DateTime.monday)),
    );
    final rightMonday = DateUtils.dateOnly(
      right.subtract(Duration(days: right.weekday - DateTime.monday)),
    );
    return leftMonday == rightMonday;
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => '一',
      DateTime.tuesday => '二',
      DateTime.wednesday => '三',
      DateTime.thursday => '四',
      DateTime.friday => '五',
      DateTime.saturday => '六',
      DateTime.sunday => '日',
      _ => '',
    };
  }
}
