import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huajuan_agenda/features/pages/home/data/home_demo_items.dart';
import 'package:huajuan_agenda/features/pages/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/pages/home/domain/use_cases/layout_home_items.dart';
import 'package:huajuan_agenda/features/pages/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

void main() {
  test('重叠事项会保持全宽叠压', () {
    const source = HomeDemoItemsSource();
    const useCase = LayoutHomeItemsUseCase();
    final visibleRange = DateTimeRangeValue(
      start: DateTime(2026, 3, 16),
      end: DateTime(2026, 3, 23),
    );
    final items = source.buildForWeek(visibleRange.start).where((item) {
      return item.id == 'demo_overlap_a' || item.id == 'demo_overlap_b';
    }).toList();
    final timeSlots = [
      for (var index = 0; index < 12; index++)
        HomeTimeSlot(
          label: 'slot-$index',
          shortLabel: 'slot-$index',
          start: DateTime(2026, 3, 16, 8 + index),
          end: DateTime(2026, 3, 16, 9 + index),
          startMinute: (8 + index) * 60,
          endMinute: (9 + index) * 60,
          index: index,
        ),
    ];

    final laidOutItems = useCase.build(
      items: items,
      visibleRange: visibleRange,
      timeSlots: timeSlots,
    );

    expect(laidOutItems, hasLength(2));
    expect(laidOutItems.map((item) => item.left).toSet(), {0.0});
    expect(laidOutItems.map((item) => item.width).toSet(), {1.0});
    expect(laidOutItems.every((item) => item.maxOverlap == 1), isTrue);
  });

  test('切换时间段时会清空已选时间块并把选中日期约束在可见范围内', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(homeHeaderViewModelProvider.notifier);
    final initialState = container.read(homeHeaderViewModelProvider);
    final initialWeekStart = DateUtils.dateOnly(initialState.anchor).subtract(
      Duration(days: initialState.anchor.weekday - DateTime.monday),
    );
    final nextWeekStart = initialWeekStart.add(const Duration(days: 7));

    notifier.selectCell(initialWeekStart.add(const Duration(days: 2)), 3);
    notifier.showNext(HomeDisplayScope.week);

    final movedState = container.read(homeHeaderViewModelProvider);
    expect(movedState.anchor, initialState.anchor.add(const Duration(days: 7)));
    expect(movedState.selectedSlotIndex, isNull);
    expect(movedState.selectedDate, nextWeekStart);

    notifier.jumpToSelection(
      HomePeriodSelection(
        anchor: DateTime(2026, 5, 1),
        scope: HomeDisplayScope.month,
      ),
    );

    final jumpedState = container.read(homeHeaderViewModelProvider);
    expect(jumpedState.anchor, DateTime(2026, 5, 1));
    expect(jumpedState.selectedSlotIndex, isNull);
    expect(jumpedState.selectedDate, DateTime(2026, 5, 1));
  });

  test('demo 数据会按可见范围覆盖多周', () {
    const source = HomeDemoItemsSource();
    final visibleRange = DateTimeRangeValue(
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 4, 1),
    );

    final items = source.buildForRange(visibleRange);

    expect(items.length, greaterThan(12));
    expect(
      items.every(
        (item) => item.endAt.isAfter(visibleRange.start) && item.startAt.isBefore(visibleRange.end),
      ),
      isTrue,
    );
  });
}
