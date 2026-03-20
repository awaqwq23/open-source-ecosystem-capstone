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
  }) {
    final visibleItems = [
      for (final item in items)
        if (_isVisible(item, visibleRange)) item,
    ]..sort((left, right) => left.startAt.compareTo(right.startAt));

    return [
      for (final item in visibleItems)
        HomeLaidOutItem(
          item: item,
          startFraction: _startFraction(item, visibleRange),
          endFraction: _endFraction(item, visibleRange),
          opacity: _opacity(item, visibleItems),
        ),
    ];
  }

  bool _isVisible(AgendaItem item, DateTimeRangeValue visibleRange) {
    if (item.type == ItemType.memo) {
      return !item.targetDate.isBefore(visibleRange.start) &&
          item.targetDate.isBefore(visibleRange.end);
    }
    return item.endAt.isAfter(visibleRange.start) && item.startAt.isBefore(visibleRange.end);
  }

  double _startFraction(AgendaItem item, DateTimeRangeValue visibleRange) {
    final total = visibleRange.end.difference(visibleRange.start).inMinutes;
    if (total <= 0) {
      return 0;
    }
    final normalized = math.max(
      0,
      item.startAt.difference(visibleRange.start).inMinutes,
    );
    return normalized / total;
  }

  double _endFraction(AgendaItem item, DateTimeRangeValue visibleRange) {
    final total = visibleRange.end.difference(visibleRange.start).inMinutes;
    if (total <= 0) {
      return 1;
    }
    final normalized = math.min(
      total,
      item.endAt.difference(visibleRange.start).inMinutes,
    );
    return normalized / total;
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
