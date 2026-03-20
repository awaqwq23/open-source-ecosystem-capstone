import 'package:huajuan_agenda/shared/models/agenda_item.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class HomeTimeSlot {
  const HomeTimeSlot({
    required this.label,
    required this.start,
    required this.end,
  });

  final String label;
  final DateTime start;
  final DateTime end;
}

class HomeDayColumn {
  const HomeDayColumn({
    required this.date,
    required this.label,
  });

  final DateTime date;
  final String label;
}

class HomeLaidOutItem {
  const HomeLaidOutItem({
    required this.item,
    required this.startFraction,
    required this.endFraction,
    required this.opacity,
  });

  final AgendaItem item;
  final double startFraction;
  final double endFraction;
  final double opacity;
}

class HomeViewData {
  const HomeViewData({
    required this.visibleRange,
    required this.columns,
    required this.timeSlots,
    required this.items,
  });

  final DateTimeRangeValue visibleRange;
  final List<HomeDayColumn> columns;
  final List<HomeTimeSlot> timeSlots;
  final List<HomeLaidOutItem> items;
}
