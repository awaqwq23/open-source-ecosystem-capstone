import 'dart:math' as math;

import 'package:luotopia/features/pages/home/domain/models/home_view_data.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';

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
    ]..sort((left, right) {
        final startCompare = left.startAt.compareTo(right.startAt);
        if (startCompare != 0) {
          return startCompare;
        }
        final endCompare = left.endAt.compareTo(right.endAt);
        if (endCompare != 0) {
          return endCompare;
        }
        return left.createdAt.compareTo(right.createdAt);
      });

    final dayStartMinute = timeSlots.first.startMinute;
    final dayEndMinute = timeSlots.last.endMinute;
    if (dayEndMinute <= dayStartMinute) {
      return const [];
    }

    final segments = <_ItemSegment>[];
    for (final item in visibleItems) {
      segments.addAll(
        _segmentsForItem(
          item: item,
          visibleRange: visibleRange,
          dayStartMinute: dayStartMinute,
          dayEndMinute: dayEndMinute,
        ),
      );
    }

    return [
      for (final segment in segments)
        HomeLaidOutItem(
          item: segment.item,
          columnIndex: segment.columnIndex,
          startMinute: segment.startMinute,
          endMinute: segment.endMinute,
        ),
    ];
  }

  bool _isVisible(AgendaItem item, DateTimeRangeValue visibleRange) {
    return item.type != ItemType.memo &&
        item.endAt.isAfter(visibleRange.start) &&
        item.startAt.isBefore(visibleRange.end);
  }

  List<_ItemSegment> _segmentsForItem({
    required AgendaItem item,
    required DateTimeRangeValue visibleRange,
    required int dayStartMinute,
    required int dayEndMinute,
  }) {
    final clippedStart = item.startAt.isBefore(visibleRange.start)
        ? visibleRange.start
        : item.startAt;
    final clippedEnd = item.endAt.isAfter(visibleRange.end) ? visibleRange.end : item.endAt;
    final firstDate = DateTime(clippedStart.year, clippedStart.month, clippedStart.day);
    final lastMoment = clippedEnd.subtract(const Duration(milliseconds: 1));
    final lastDate = DateTime(lastMoment.year, lastMoment.month, lastMoment.day);
    final totalDays = lastDate.difference(firstDate).inDays;

    final segments = <_ItemSegment>[];
    for (var index = 0; index <= totalDays; index++) {
      final currentDate = firstDate.add(Duration(days: index));
      final dayStart = DateTime(currentDate.year, currentDate.month, currentDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final segmentStart = clippedStart.isAfter(dayStart) ? clippedStart : dayStart;
      final segmentEnd = clippedEnd.isBefore(dayEnd) ? clippedEnd : dayEnd;
      final startMinute = math.max(dayStartMinute, segmentStart.hour * 60 + segmentStart.minute);
      final endMinute = math.min(dayEndMinute, segmentEnd.hour * 60 + segmentEnd.minute);
      if (endMinute <= dayStartMinute || startMinute >= dayEndMinute || endMinute <= startMinute) {
        continue;
      }
      segments.add(
        _ItemSegment(
          item: item,
          columnIndex: currentDate.difference(visibleRange.start).inDays,
          startMinute: startMinute,
          endMinute: endMinute,
        ),
      );
    }
    return segments;
  }
}

class _ItemSegment {
  const _ItemSegment({
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

