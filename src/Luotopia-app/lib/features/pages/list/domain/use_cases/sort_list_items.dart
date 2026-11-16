import 'dart:math' as math;

import 'package:luotopia/features/pages/list/domain/models/list_filters.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';

class SortListItemsUseCase {
  const SortListItemsUseCase();

  List<AgendaItem> call(
    List<AgendaItem> items,
    ListSortMode mode,
    DateTime now,
  ) {
    final sorted = [...items];
    sorted.sort((a, b) => _compareItems(a, b, mode, now));
    return sorted;
  }

  int _compareItems(
    AgendaItem a,
    AgendaItem b,
    ListSortMode mode,
    DateTime now,
  ) {
    switch (mode) {
      case ListSortMode.dueDate:
        return _compareNullableDate(
          _dueDateOf(a),
          _dueDateOf(b),
          fallback: () {
            return _compareByTimeThenCreated(a, b);
          },
        );
      case ListSortMode.todayFocus:
        final aScore = _todayFocusScore(a, now);
        final bScore = _todayFocusScore(b, now);
        final scoreOrder = bScore.compareTo(aScore);
        if (scoreOrder != 0) {
          return scoreOrder;
        }
        return _compareByTimeThenCreated(a, b);
      case ListSortMode.alphabetical:
        final titleOrder = a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        );
        if (titleOrder != 0) {
          return titleOrder;
        }
        return _compareByTimeThenCreated(a, b);
      case ListSortMode.createdDate:
        final createdOrder = b.createdAt.compareTo(a.createdAt);
        if (createdOrder != 0) {
          return createdOrder;
        }
        return _compareByTimeThenCreated(a, b);
      case ListSortMode.manual:
        final sortOrder = a.sortOrder.compareTo(b.sortOrder);
        if (sortOrder != 0) {
          return sortOrder;
        }
        return _compareByTimeThenCreated(a, b);
    }
  }

  int _compareByTimeThenCreated(AgendaItem a, AgendaItem b) {
    final timeOrder = _primaryDateOf(a).compareTo(_primaryDateOf(b));
    if (timeOrder != 0) {
      return timeOrder;
    }
    final typeOrder = a.type.index.compareTo(b.type.index);
    if (typeOrder != 0) {
      return typeOrder;
    }
    return a.createdAt.compareTo(b.createdAt);
  }

  DateTime _primaryDateOf(AgendaItem item) {
    return switch (item.type) {
      ItemType.memo => item.createdAt,
      ItemType.task => item.deadlineAt!,
      ItemType.schedule =>
        item.scheduleCountdownEnabled
            ? item.timelineEndAt!
            : item.timelineStartAt!,
      ItemType.course => item.timelineStartAt!,
    };
  }

  DateTime? _dueDateOf(AgendaItem item) {
    return switch (item.type) {
      ItemType.memo => null,
      ItemType.task => item.deadlineAt,
      ItemType.schedule =>
        item.scheduleCountdownEnabled
            ? item.timelineEndAt
            : item.timelineStartAt,
      ItemType.course => item.timelineStartAt,
    };
  }

  int _todayFocusScore(AgendaItem item, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final focusDate = _primaryDateOf(item);
    final target = DateTime(focusDate.year, focusDate.month, focusDate.day);
    final distance = target.difference(today).inDays.abs();
    return math.max(0, 100 - distance * 10);
  }

  int _compareNullableDate(
    DateTime? left,
    DateTime? right, {
    required int Function() fallback,
  }) {
    if (left == null && right == null) {
      return fallback();
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }
    final result = left.compareTo(right);
    return result != 0 ? result : fallback();
  }
}
