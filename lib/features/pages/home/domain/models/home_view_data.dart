import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';

enum HomeDisplayScope {
  week,
  month,
}

class HomeLayoutMetrics {
  const HomeLayoutMetrics({
    required this.startMinuteOfDay,
    required this.totalMinutes,
    required this.endMinuteOfDay,
    required this.dayCount,
    required this.blockCount,
  });

  final int startMinuteOfDay;
  final int totalMinutes;
  final int endMinuteOfDay;
  final int dayCount;
  final int blockCount;
}

class HomeTimeSlot {
  const HomeTimeSlot({
    required this.label,
    required this.shortLabel,
    required this.start,
    required this.end,
    required this.startMinute,
    required this.endMinute,
    required this.index,
  });

  final String label;
  final String shortLabel;
  final DateTime start;
  final DateTime end;
  final int startMinute;
  final int endMinute;
  final int index;
}

class HomeDayColumn {
  const HomeDayColumn({
    required this.date,
    required this.weekdayLabel,
    required this.dateLabel,
    required this.isToday,
    required this.isSelected,
    required this.emphasize,
  });

  final DateTime date;
  final String weekdayLabel;
  final String dateLabel;
  final bool isToday;
  final bool isSelected;
  final bool emphasize;
}

class HomePeriodSelection {
  const HomePeriodSelection({
    required this.anchor,
    required this.scope,
  });

  final DateTime anchor;
  final HomeDisplayScope scope;
}

class HomeLaidOutItem {
  const HomeLaidOutItem({
    required this.item,
    required this.columnIndex,
    required this.startMinute,
    required this.endMinute,
  });

  final AgendaItem item;
  final int columnIndex;
  final int startMinute;
  final int endMinute;
}

class HomeCellSelection {
  const HomeCellSelection({
    required this.date,
    required this.slot,
  });

  final DateTime date;
  final HomeTimeSlot slot;
}

class HomeViewData {
  const HomeViewData({
    required this.scope,
    required this.periodLabel,
    required this.periodSubtitle,
    required this.metrics,
    required this.visibleRange,
    required this.periodSelection,
    required this.selectedCell,
    required this.columns,
    required this.timeSlots,
    required this.items,
    this.isCourseGrid = false,
  });

  final HomeDisplayScope scope;
  final String periodLabel;
  final String periodSubtitle;
  final HomeLayoutMetrics metrics;
  final DateTimeRangeValue visibleRange;
  final HomePeriodSelection periodSelection;
  final HomeCellSelection? selectedCell;
  final List<HomeDayColumn> columns;
  final List<HomeTimeSlot> timeSlots;
  final List<HomeLaidOutItem> items;
  final bool isCourseGrid;
}

