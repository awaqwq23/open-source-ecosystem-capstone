import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/pages/home/domain/models/home_view_data.dart';
import 'package:luotopia/features/pages/home/presentation/viewmodels/home_header_view_model.dart';

void main() {
  test('切换时间段时会清空已选时间块并把选中日期约束在可见范围内', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(homeHeaderViewModelProvider.notifier);

    // 固定到五月中旬，避免依赖 DateTime.now() 的边界问题
    notifier.jumpToSelection(
      HomePeriodSelection(
        anchor: DateTime(2026, 5, 15),
        scope: HomeDisplayScope.month,
      ),
    );

    final initialState = container.read(homeHeaderViewModelProvider);
    final initialWeekStart = DateUtils.dateOnly(
      initialState.anchor,
    ).subtract(Duration(days: initialState.anchor.weekday - DateTime.monday));
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
    expect(jumpedState.selectedDate, nextWeekStart);
  });
}
