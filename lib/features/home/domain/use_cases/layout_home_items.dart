import 'dart:math' as math;

import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class LayoutHomeItemsUseCase {
  const LayoutHomeItemsUseCase();

  static const minimumVisibleHeightFactor = 0.04;

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

    final segmentLayouts = _buildSegmentLayouts(segments);

    return [
      for (final segment in segments)
        HomeLaidOutItem(
          item: segment.item,
          columnIndex: segment.columnIndex,
          startMinute: segment.startMinute,
          endMinute: segment.endMinute,
          top: (segment.startMinute - dayStartMinute) / (dayEndMinute - dayStartMinute),
          height: math.max(
            minimumVisibleHeightFactor,
            (segment.endMinute - segment.startMinute) / (dayEndMinute - dayStartMinute),
          ),
          opacity: 1 / (segmentLayouts[segment.key]?.maxOverlap ?? 1),
          left: segmentLayouts[segment.key]?.left ?? 0,
          width: segmentLayouts[segment.key]?.width ?? 1,
          maxOverlap: segmentLayouts[segment.key]?.maxOverlap ?? 1,
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

  Map<String, _SegmentLayout> _buildSegmentLayouts(List<_ItemSegment> segments) {
    final grouped = <int, List<_ItemSegment>>{};
    for (final segment in segments) {
      grouped.putIfAbsent(segment.columnIndex, () => []).add(segment);
    }

    final layouts = <String, _SegmentLayout>{};
    for (final entry in grouped.entries) {
      final sortedSegments = [...entry.value]
        ..sort((left, right) {
          final startCompare = left.startMinute.compareTo(right.startMinute);
          if (startCompare != 0) {
            return startCompare;
          }
          final endCompare = left.endMinute.compareTo(right.endMinute);
          if (endCompare != 0) {
            return endCompare;
          }
          return left.item.createdAt.compareTo(right.item.createdAt);
        });
      final groups = <List<_ItemSegment>>[];
      var activeGroup = <_ItemSegment>[];
      var activeGroupEnd = -1;
      for (final segment in sortedSegments) {
        if (activeGroup.isEmpty || segment.startMinute < activeGroupEnd) {
          activeGroup.add(segment);
          activeGroupEnd = math.max(activeGroupEnd, segment.endMinute);
          continue;
        }
        groups.add(activeGroup);
        activeGroup = [segment];
        activeGroupEnd = segment.endMinute;
      }
      if (activeGroup.isNotEmpty) {
        groups.add(activeGroup);
      }

      for (final group in groups) {
        layouts.addAll(_buildGroupLayouts(group));
      }
    }
    return layouts;
  }

  Map<String, _SegmentLayout> _buildGroupLayouts(List<_ItemSegment> group) {
    final laneEndMinutes = <int>[];
    final laneBySegmentKey = <String, int>{};

    for (final segment in group) {
      var laneIndex = -1;
      for (var index = 0; index < laneEndMinutes.length; index++) {
        if (laneEndMinutes[index] <= segment.startMinute) {
          laneIndex = index;
          break;
        }
      }
      if (laneIndex == -1) {
        laneEndMinutes.add(segment.endMinute);
        laneIndex = laneEndMinutes.length - 1;
      } else {
        laneEndMinutes[laneIndex] = segment.endMinute;
      }
      laneBySegmentKey[segment.key] = laneIndex;
    }

    final maxOverlapBySegment = _maxOverlapBySegment(group);
    final laneCount = math.max(1, laneEndMinutes.length);
    return {
      for (final segment in group)
        segment.key: _SegmentLayout(
          left: laneBySegmentKey[segment.key]! / laneCount,
          width: 1 / laneCount,
          maxOverlap: maxOverlapBySegment[segment.key] ?? 1,
        ),
    };
  }

  Map<String, int> _maxOverlapBySegment(List<_ItemSegment> segments) {
    final breakpoints = <int>{};
    for (final segment in segments) {
      breakpoints
        ..add(segment.startMinute)
        ..add(segment.endMinute);
    }
    final sortedPoints = breakpoints.toList()..sort();
    final overlapByItem = <String, int>{};
    for (var index = 0; index < sortedPoints.length - 1; index++) {
      final probeMinute = sortedPoints[index];
      final active = [
        for (final segment in segments)
          if (segment.startMinute <= probeMinute && probeMinute < segment.endMinute) segment,
      ];
      if (active.isEmpty) {
        continue;
      }
      for (final segment in active) {
        overlapByItem[segment.key] = math.max(
          overlapByItem[segment.key] ?? 1,
          active.length,
        );
      }
    }
    return overlapByItem;
  }
}

class _SegmentLayout {
  const _SegmentLayout({
    required this.left,
    required this.width,
    required this.maxOverlap,
  });

  final double left;
  final double width;
  final int maxOverlap;
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

  String get key => '${item.id}_${columnIndex}_${startMinute}_$endMinute';
}
