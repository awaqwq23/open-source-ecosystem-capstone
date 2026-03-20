import 'package:flutter/material.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class BuildHomeGridUseCase {
  const BuildHomeGridUseCase();

  HomeViewData build({
    required DateTime anchor,
    required HomeHeaderScope scope,
    required List<HomeLaidOutItem> items,
  }) {
    final visibleRange = _visibleRange(anchor, scope);
    final columns = _buildColumns(visibleRange, scope);
    final timeSlots = _buildTimeSlots(anchor);
    return HomeViewData(
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
    HomeHeaderScope scope,
  ) {
    final dayCount = scope == HomeHeaderScope.month
        ? visibleRange.end.difference(visibleRange.start).inDays
        : 7;
    return [
      for (var index = 0; index < dayCount; index++)
        HomeDayColumn(
          date: visibleRange.start.add(Duration(days: index)),
          label: scope == HomeHeaderScope.month
              ? '${visibleRange.start.add(Duration(days: index)).month}/${visibleRange.start.add(Duration(days: index)).day}'
              : '周${_weekdayLabel(visibleRange.start.add(Duration(days: index)).weekday)} ${visibleRange.start.add(Duration(days: index)).month}/${visibleRange.start.add(Duration(days: index)).day}',
        ),
    ];
  }

  List<HomeTimeSlot> _buildTimeSlots(DateTime anchor) {
    final startOfDay = DateTime(anchor.year, anchor.month, anchor.day, 8);
    return [
      for (var index = 0; index < 12; index++)
        HomeTimeSlot(
          label: '${(8 + index).toString().padLeft(2, '0')}:00-${(9 + index).toString().padLeft(2, '0')}:00',
          start: startOfDay.add(Duration(hours: index)),
          end: startOfDay.add(Duration(hours: index + 1)),
        ),
    ];
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
