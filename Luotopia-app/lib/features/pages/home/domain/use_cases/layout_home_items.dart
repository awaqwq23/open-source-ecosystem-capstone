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
        final startCompare = _anchorStart(left).compareTo(_anchorStart(right));
        if (startCompare != 0) {
          return startCompare;
        }
        final endCompare = _anchorEnd(left).compareTo(_anchorEnd(right));
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
          timeSlots: timeSlots,
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
    if (item.type == ItemType.memo) {
      return false;
    }
    if (item.type == ItemType.task) {
      final deadline = item.deadlineAt;
      return deadline != null &&
          !deadline.isBefore(visibleRange.start) &&
          deadline.isBefore(visibleRange.end);
    }
    final start = item.timelineStartAt;
    final end = item.timelineEndAt;
    return start != null &&
        end != null &&
        end.isAfter(visibleRange.start) &&
        start.isBefore(visibleRange.end);
  }

  List<_ItemSegment> _segmentsForItem({
    required AgendaItem item,
    required DateTimeRangeValue visibleRange,
    required List<HomeTimeSlot> timeSlots,
    required int dayStartMinute,
    required int dayEndMinute,
  }) {
    if (item.type == ItemType.task) {
      final deadline = item.deadlineAt!;
      final minute = deadline.hour * 60 + deadline.minute;
      final slot = _slotContaining(
        minute: minute,
        timeSlots: timeSlots,
        dayStartMinute: dayStartMinute,
        dayEndMinute: dayEndMinute,
      );
      return [
        _ItemSegment(
          item: item,
          columnIndex: DateTime(deadline.year, deadline.month, deadline.day)
              .difference(visibleRange.start)
              .inDays,
          startMinute: slot.$1,
          endMinute: slot.$2,
        ),
      ];
    }

    final itemStart = item.timelineStartAt!;
    final itemEnd = item.timelineEndAt!;
    final clippedStart = itemStart.isBefore(visibleRange.start)
        ? visibleRange.start
        : itemStart;
    final clippedEnd = itemEnd.isAfter(visibleRange.end) ? visibleRange.end : itemEnd;
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

  DateTime _anchorStart(AgendaItem item) {
    return item.type == ItemType.task
        ? item.deadlineAt!
        : item.timelineStartAt ?? item.createdAt;
  }

  DateTime _anchorEnd(AgendaItem item) {
    return item.type == ItemType.task
        ? item.deadlineAt!
        : item.timelineEndAt ?? item.createdAt;
  }

  (int, int) _slotContaining({
    required int minute,
    required List<HomeTimeSlot> timeSlots,
    required int dayStartMinute,
    required int dayEndMinute,
  }) {
    for (final slot in timeSlots) {
      if (minute >= slot.startMinute && minute <= slot.endMinute) {
        return (slot.startMinute, slot.endMinute);
      }
    }
    if (minute <= dayStartMinute) {
      return (timeSlots.first.startMinute, timeSlots.first.endMinute);
    }
    return (timeSlots.last.startMinute, timeSlots.last.endMinute);
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

