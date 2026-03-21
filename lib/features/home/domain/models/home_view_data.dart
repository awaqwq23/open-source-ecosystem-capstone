import 'package:huajuan_agenda/shared/models/agenda_item.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class HomeLayoutMetrics {
  const HomeLayoutMetrics({
    required this.columnWidth,
    required this.columnGap,
    required this.timelineWidth,
    required this.startMinuteOfDay,
    required this.totalMinutes,
  });

  final double columnWidth;
  final double columnGap;
  final double timelineWidth;
  final int startMinuteOfDay;
  final int totalMinutes;
}

class HomeTimeSlot {
  const HomeTimeSlot({
    required this.label,
    required this.start,
    required this.end,
    required this.startMinute,
    required this.endMinute,
  });

  final String label;
  final DateTime start;
  final DateTime end;
  final int startMinute;
  final int endMinute;
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

class HomeLaidOutItem {
  const HomeLaidOutItem({
    required this.item,
    required this.columnIndex,
    required this.startMinute,
    required this.endMinute,
    required this.top,
    required this.height,
    required this.opacity,
  });

  final AgendaItem item;
  final int columnIndex;
  final int startMinute;
  final int endMinute;
  final double top;
  final double height;
  final double opacity;
}

class HomeViewData {
  const HomeViewData({
    required this.periodLabel,
    required this.periodSubtitle,
    required this.metrics,
    required this.visibleRange,
    required this.columns,
    required this.timeSlots,
    required this.items,
  });

  final String periodLabel;
  final String periodSubtitle;
  final HomeLayoutMetrics metrics;
  final DateTimeRangeValue visibleRange;
  final List<HomeDayColumn> columns;
  final List<HomeTimeSlot> timeSlots;
  final List<HomeLaidOutItem> items;
}
