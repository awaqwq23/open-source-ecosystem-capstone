import 'dart:math' as math;

import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class LayoutHomeItemsUseCase {
  const LayoutHomeItemsUseCase();

  List<HomeLaidOutItem> build({
    required List<AgendaItem> items,
    required DateTimeRangeValue visibleRange,
    required List<HomeTimeSlot> timeSlots,
  }) {
    if (timeSlots.isEmpty) {
      return const [];
    }

    final visibleItems = [
      for (final item in items)
        if (_isVisible(item, visibleRange)) item,
    ]..sort((left, right) => left.startAt.compareTo(right.startAt));

    final dayStartMinute = timeSlots.first.startMinute;
    final totalMinutes = timeSlots.last.endMinute - dayStartMinute;
    if (totalMinutes <= 0) {
      return const [];
    }

    return [
      for (final item in visibleItems)
        () {
          final start = item.startAt.isBefore(visibleRange.start)
              ? visibleRange.start
              : item.startAt;
          final end = item.endAt.isAfter(visibleRange.end) ? visibleRange.end : item.endAt;
          final columnIndex = start.difference(visibleRange.start).inDays;
          final startMinute = start.hour * 60 + start.minute;
          final endMinute = end.hour * 60 + end.minute;
          final normalizedStartMinute = math.max(dayStartMinute, startMinute);
          final normalizedEndMinute = math.min(dayStartMinute + totalMinutes, endMinute);
          final top = (normalizedStartMinute - dayStartMinute) / totalMinutes;
          final height = math.max(
            0.06,
            (normalizedEndMinute - normalizedStartMinute) / totalMinutes,
          );
          return HomeLaidOutItem(
            item: item,
            columnIndex: columnIndex,
            startMinute: normalizedStartMinute,
            endMinute: normalizedEndMinute,
            top: top,
            height: height,
            opacity: _opacity(item, visibleItems),
          );
        }(),
    ];
  }

  bool _isVisible(AgendaItem item, DateTimeRangeValue visibleRange) {
    return item.type != ItemType.memo &&
        item.endAt.isAfter(visibleRange.start) &&
        item.startAt.isBefore(visibleRange.end);
  }

  double _opacity(AgendaItem target, List<AgendaItem> items) {
    var maxOverlap = 1;
    for (final current in items) {
      if (!_overlaps(target, current)) {
        continue;
      }
      var overlapCount = 0;
      for (final other in items) {
        if (_overlaps(current, other)) {
          overlapCount += 1;
        }
      }
      maxOverlap = math.max(maxOverlap, overlapCount);
    }
    return 1 / maxOverlap;
  }

  bool _overlaps(AgendaItem left, AgendaItem right) {
    return left.startAt.isBefore(right.endAt) && right.startAt.isBefore(left.endAt);
  }
}
