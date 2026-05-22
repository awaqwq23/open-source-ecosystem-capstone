import 'package:flutter/material.dart';
import 'package:luotopia/features/pages/home/domain/models/home_view_data.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:intl/intl.dart';

class BuildHomeGridUseCase {
  const BuildHomeGridUseCase();

  HomeViewData build({
    required String localeTag,
    required DateTime anchor,
    required HomeDisplayScope scope,
    required DateTime? selectedDate,
    required HomeCellSelection? selectedCell,
    required HomeSettings settings,
    required List<HomeLaidOutItem> items,
  }) {
    final visibleRange = visibleDateRange(anchor, scope);
    final periodSelection = HomePeriodSelection(
      anchor: visibleRange.start,
      scope: scope,
    );
    final timeSlots = _buildTimeSlots(
      anchor: visibleRange.start,
      localeTag: localeTag,
      settings: settings,
    );
    final columns = _buildColumns(
      visibleRange,
      selectedDate: selectedDate,
      localeTag: localeTag,
    );
    final metrics = _buildMetrics(timeSlots, dayCount: columns.length);
    return HomeViewData(
      scope: scope,
      periodLabel: _formatPeriodLabel(
        visibleRange: visibleRange,
        scope: scope,
        localeTag: localeTag,
      ),
      periodSubtitle: _formatPeriodSubtitle(
        visibleRange: visibleRange,
        scope: scope,
        localeTag: localeTag,
      ),
      metrics: metrics,
      visibleRange: visibleRange,
      periodSelection: periodSelection,
      selectedCell: selectedCell,
      columns: columns,
      timeSlots: timeSlots,
      items: items,
      isCourseGrid: settings.gridMode == HomeGridMode.courseGrid,
    );
  }

  DateTimeRangeValue visibleDateRange(DateTime anchor, HomeDisplayScope scope) {
    if (scope == HomeDisplayScope.month) {
      final start = DateTime(anchor.year, anchor.month, 1);
      return DateTimeRangeValue(
        start: start,
        end: DateTime(anchor.year, anchor.month + 1, 1),
      );
    }

    final weekdayOffset = anchor.weekday - DateTime.monday;
    final start = DateUtils.dateOnly(anchor).subtract(Duration(days: weekdayOffset));
    return DateTimeRangeValue(
      start: start,
      end: start.add(const Duration(days: 7)),
    );
  }

  List<HomeTimeSlot> _buildTimeSlots({
    required DateTime anchor,
    required String localeTag,
    required HomeSettings settings,
  }) {
    if (settings.gridMode == HomeGridMode.courseGrid) {
      return _buildCourseTimeSlots(anchor: anchor, localeTag: localeTag);
    }
    return _buildDefaultTimeSlots(anchor: anchor, settings: settings);
  }

  List<HomeTimeSlot> _buildCourseTimeSlots({
    required DateTime anchor,
    required String localeTag,
  }) {
    final base = DateUtils.dateOnly(anchor);
    // 13 fixed course periods with specific times
    const coursePeriods = <(int start, int end)>[
      (480, 525),   // 1:  8:00-8:45
      (530, 575),   // 2:  8:50-9:35
      (590, 635),   // 3:  9:50-10:35
      (640, 685),   // 4: 10:40-11:25
      (690, 735),   // 5: 11:30-12:15
      (735, 845),   // 午休: 12:15-14:05
      (845, 890),   // 6: 14:05-14:50
      (895, 940),   // 7: 14:55-15:40
      (945, 990),   // 8: 15:45-16:30
      (1000, 1045), // 9: 16:40-17:25
      (1050, 1095), //10: 17:30-18:15
      (1110, 1155), //11: 18:30-19:15
      (1160, 1205), //12: 19:20-20:05
      (1210, 1255), //13: 20:10-20:55
    ];
    final localeIsChinese = localeTag.startsWith('zh');
    const lunchBreakIndex = 5;

    return [
      for (var index = 0; index < coursePeriods.length; index++)
        () {
          final (slotStartMinute, slotEndMinute) = coursePeriods[index];
          final start = DateTime(
            base.year,
            base.month,
            base.day,
            slotStartMinute ~/ 60,
            slotStartMinute % 60,
          );
          final end = DateTime(
            base.year,
            base.month,
            base.day,
            slotEndMinute ~/ 60,
            slotEndMinute % 60,
          );
          final startLabel = _formatMinute(slotStartMinute);
          final endLabel = _formatMinute(slotEndMinute);
          final isLunchBreak = index == lunchBreakIndex;
          final courseNumber = isLunchBreak ? null : (index < lunchBreakIndex ? index + 1 : index);
          return HomeTimeSlot(
            label: '$startLabel~$endLabel',
            shortLabel: isLunchBreak
                ? (localeIsChinese ? '午休' : 'Lunch')
                : (localeIsChinese ? '第$courseNumber节' : 'Period $courseNumber'),
            start: start,
            end: end,
            startMinute: slotStartMinute,
            endMinute: slotEndMinute,
            index: index,
          );
        }(),
    ];
  }

  List<HomeTimeSlot> _buildDefaultTimeSlots({
    required DateTime anchor,
    required HomeSettings settings,
  }) {
    final base = DateUtils.dateOnly(anchor);
    final startMinute = settings.dayStartTime.hour * 60 + settings.dayStartTime.minute;

    return [
      for (var index = 0; index < settings.blockCount; index++)
        () {
          final slotStartMinute = startMinute +
              index * (settings.blockDurationMinutes + settings.blockGapMinutes);
          final slotEndMinute = slotStartMinute + settings.blockDurationMinutes;
          final start = DateTime(
            base.year,
            base.month,
            base.day,
            slotStartMinute ~/ 60,
            slotStartMinute % 60,
          );
          final end = DateTime(
            base.year,
            base.month,
            base.day,
            slotEndMinute ~/ 60,
            slotEndMinute % 60,
          );
          final startLabel = _formatMinute(slotStartMinute);
          final endLabel = _formatMinute(slotEndMinute);
          return HomeTimeSlot(
            label: '$startLabel~$endLabel',
            shortLabel: '第${index + 1}块',
            start: start,
            end: end,
            startMinute: slotStartMinute,
            endMinute: slotEndMinute,
            index: index,
          );
        }(),
    ];
  }

  List<HomeDayColumn> _buildColumns(
    DateTimeRangeValue visibleRange, {
    required DateTime? selectedDate,
    required String localeTag,
  }) {
    final dayCount = visibleRange.end.difference(visibleRange.start).inDays;
    final today = DateUtils.dateOnly(DateTime.now());
    final normalizedSelected = selectedDate == null ? null : DateUtils.dateOnly(selectedDate);
    final weekdayFormatter =
        localeTag.startsWith('zh') ? DateFormat('E', localeTag) : DateFormat('EEE', localeTag);
    final dateFormatter = localeTag.startsWith('zh')
        ? DateFormat('M/d', localeTag)
        : DateFormat('M/d', localeTag);

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
            emphasize: date.weekday == DateTime.saturday || date.weekday == DateTime.sunday,
          );
        }(),
    ];
  }

  HomeLayoutMetrics _buildMetrics(List<HomeTimeSlot> timeSlots, {required int dayCount}) {
    if (timeSlots.isEmpty) {
      return const HomeLayoutMetrics(
        startMinuteOfDay: 0,
        totalMinutes: 0,
        endMinuteOfDay: 0,
        dayCount: 0,
        blockCount: 0,
      );
    }
    final startMinute = timeSlots.first.startMinute;
    final endMinute = timeSlots.last.endMinute;
    return HomeLayoutMetrics(
      startMinuteOfDay: startMinute,
      totalMinutes: endMinute - startMinute,
      endMinuteOfDay: endMinute,
      dayCount: dayCount,
      blockCount: timeSlots.length,
    );
  }

  String _formatPeriodLabel({
    required DateTimeRangeValue visibleRange,
    required HomeDisplayScope scope,
    required String localeTag,
  }) {
    if (scope == HomeDisplayScope.month) {
      return localeTag.startsWith('zh')
          ? '${visibleRange.start.year}年${visibleRange.start.month}月'
          : DateFormat.yMMMM(localeTag).format(visibleRange.start);
    }

    final weekStart = visibleRange.start;
    final weekEnd = visibleRange.end.subtract(const Duration(days: 1));
    if (localeTag.startsWith('zh')) {
      return weekStart.month == weekEnd.month
          ? '${weekStart.month}月第${_weekOfMonth(weekStart)}周'
          : '${weekStart.year}年第${_weekOfYear(weekStart)}周';
    }
    if (weekStart.month == weekEnd.month) {
      return 'Week ${_weekOfMonth(weekStart)} of ${DateFormat.yMMMM(localeTag).format(weekStart)}';
    }
    return 'Week ${_weekOfYear(weekStart)} of ${weekStart.year}';
  }

  String _formatPeriodSubtitle({
    required DateTimeRangeValue visibleRange,
    required HomeDisplayScope scope,
    required String localeTag,
  }) {
    final formatter = DateFormat('M/d', localeTag);
    if (scope == HomeDisplayScope.month) {
      return localeTag.startsWith('zh')
          ? '${visibleRange.start.day}-${visibleRange.end.subtract(const Duration(days: 1)).day}日'
          : formatter.format(visibleRange.start);
    }

    final isCurrentWeek = _isCurrentWeek(visibleRange.start);
    if (isCurrentWeek && localeTag.startsWith('zh')) {
      return '本周';
    }

    final end = visibleRange.end.subtract(const Duration(days: 1));
    if (localeTag.startsWith('zh')) {
      return '${formatter.format(visibleRange.start)}-${formatter.format(end)}';
    }
    return '${formatter.format(visibleRange.start)}-${formatter.format(end)}';
  }

  bool _isCurrentWeek(DateTime visibleRangeStart) {
    final today = DateUtils.dateOnly(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));
    return DateUtils.isSameDay(monday, DateUtils.dateOnly(visibleRangeStart));
  }

  String _formatMinute(int minute) {
    final normalizedHour = minute ~/ 60;
    final normalizedMinute = minute % 60;
    final hourText = normalizedHour.toString().padLeft(2, '0');
    final minuteText = normalizedMinute.toString().padLeft(2, '0');
    return '$hourText:$minuteText';
  }

  int _weekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final offset = firstDay.weekday - DateTime.monday;
    return ((date.day + offset - 1) ~/ 7) + 1;
  }

  int _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final offset = firstDay.weekday - DateTime.monday;
    final dayOfYear = date.difference(firstDay).inDays + 1;
    return ((dayOfYear + offset - 1) ~/ 7) + 1;
  }

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
