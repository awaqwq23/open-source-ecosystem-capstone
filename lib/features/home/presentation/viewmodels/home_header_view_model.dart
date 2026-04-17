import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/perf/startup_perf_probe.dart';
import 'package:huajuan_agenda/features/home/data/home_demo_items.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/build_home_grid.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/layout_home_items.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class HomeHeaderState {
  const HomeHeaderState({
    required this.anchor,
    this.selectedDate,
    this.selectedSlotIndex,
  });

  final DateTime anchor;
  final DateTime? selectedDate;
  final int? selectedSlotIndex;

  HomeHeaderState copyWith({
    DateTime? anchor,
    DateTime? selectedDate,
    int? selectedSlotIndex,
    bool clearSelectedSlotIndex = false,
  }) {
    return HomeHeaderState(
      anchor: anchor ?? this.anchor,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlotIndex: clearSelectedSlotIndex
          ? null
          : (selectedSlotIndex ?? this.selectedSlotIndex),
    );
  }
}

class HomeViewQuery {
  const HomeViewQuery({
    required this.localeTag,
    required this.allowMonthLayout,
  });

  final String localeTag;
  final bool allowMonthLayout;
}

class HomeHeaderViewModel extends Notifier<HomeHeaderState> {
  static const _gridBuilder = BuildHomeGridUseCase();
  static const _itemLayoutBuilder = LayoutHomeItemsUseCase();
  static const _demoItemsSource = HomeDemoItemsSource();

  @override
  HomeHeaderState build() {
    final now = DateUtils.dateOnly(DateTime.now());
    return HomeHeaderState(
      anchor: now,
      selectedDate: now,
    );
  }

  void showPrevious(HomeDisplayScope scope) {
    _moveToAnchor(
      switch (scope) {
        HomeDisplayScope.week => state.anchor.subtract(const Duration(days: 7)),
        HomeDisplayScope.month => DateTime(state.anchor.year, state.anchor.month - 1, 1),
      },
      scope: scope,
    );
  }

  void showNext(HomeDisplayScope scope) {
    _moveToAnchor(
      switch (scope) {
        HomeDisplayScope.week => state.anchor.add(const Duration(days: 7)),
        HomeDisplayScope.month => DateTime(state.anchor.year, state.anchor.month + 1, 1),
      },
      scope: scope,
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: DateUtils.dateOnly(date));
  }

  void selectCell(DateTime date, int slotIndex) {
    state = state.copyWith(
      selectedDate: DateUtils.dateOnly(date),
      selectedSlotIndex: slotIndex,
    );
  }

  void jumpToSelection(HomePeriodSelection selection) {
    _moveToAnchor(
      DateUtils.dateOnly(selection.anchor),
      scope: selection.scope,
      fallbackSelectedDate: DateUtils.dateOnly(selection.anchor),
    );
  }

  void _moveToAnchor(
    DateTime anchor, {
    required HomeDisplayScope scope,
    DateTime? fallbackSelectedDate,
  }) {
    final normalizedAnchor = DateUtils.dateOnly(anchor);
    final visibleRange = _gridBuilder.visibleDateRange(normalizedAnchor, scope);
    final selectedDate = state.selectedDate == null
        ? fallbackSelectedDate
        : _normalizeSelectionWithinRange(
            selectedDate: state.selectedDate!,
            visibleRange: visibleRange,
            fallbackSelectedDate: fallbackSelectedDate ?? visibleRange.start,
          );
    state = state.copyWith(
      anchor: normalizedAnchor,
      selectedDate: selectedDate,
      clearSelectedSlotIndex: true,
    );
  }

  DateTime _normalizeSelectionWithinRange({
    required DateTime selectedDate,
    required DateTimeRangeValue visibleRange,
    required DateTime fallbackSelectedDate,
  }) {
    final normalizedSelectedDate = DateUtils.dateOnly(selectedDate);
    if (normalizedSelectedDate.isBefore(visibleRange.start) ||
        !normalizedSelectedDate.isBefore(visibleRange.end)) {
      return DateUtils.dateOnly(fallbackSelectedDate);
    }
    return normalizedSelectedDate;
  }
}

final homeHeaderViewModelProvider =
    NotifierProvider<HomeHeaderViewModel, HomeHeaderState>(
  HomeHeaderViewModel.new,
);

final homeViewDataProvider = Provider.family<HomeViewData, HomeViewQuery>((ref, query) {
  final probe = StartupPerfProbe.instance;
  probe.markOnce(
    'home_viewdata_provider_first',
    extras: <String, Object?>{
      'allow_month_layout': query.allowMonthLayout,
      'locale': query.localeTag,
    },
  );
  final state = ref.watch(homeHeaderViewModelProvider);
  final settings = ref.watch(appHomeSettingsProvider);
  final repositoryItems = ref.watch(agendaItemRepositoryProvider);
  final repository = ref.read(agendaItemRepositoryProvider.notifier);
  final timetableStore = ref.watch(courseTimetableRepositoryProvider);
  final activeTimetableId = timetableStore.activeTimetableId;
  final scope = query.allowMonthLayout && settings.wideLayoutScope == HomeWideLayoutScope.month
      ? HomeDisplayScope.month
      : HomeDisplayScope.week;
  final previewGrid = HomeHeaderViewModel._gridBuilder.build(
    localeTag: query.localeTag,
    anchor: state.anchor,
    scope: scope,
    selectedDate: state.selectedDate,
    selectedCell: null,
    settings: settings,
    items: const [],
  );
  final windowKey = _homeWindowKey(
    scope: scope,
    anchor: previewGrid.visibleRange.start,
  );
  if (!settings.showDemoData && !repository.hasLoadedWindow(windowKey)) {
    probe.mark(
      'home_window_load_requested',
      extras: <String, Object?>{
        'window_key': windowKey,
      },
    );
    unawaited(
      repository.loadWindowFromStorage(
        windowKey: windowKey,
        startInclusive: previewGrid.visibleRange.start,
        endExclusive: previewGrid.visibleRange.end,
      ),
    );
  }
  final shouldLoadItems = settings.showDemoData || repository.hasLoadedWindow(windowKey);
  if (shouldLoadItems) {
    probe.markOnce('home_viewdata_window_ready_phase_observed');
  }
  final visibleItems = !shouldLoadItems
      ? const <AgendaItem>[]
      : settings.showDemoData
      ? HomeHeaderViewModel._demoItemsSource.buildForRange(previewGrid.visibleRange)
      : [
          for (final item in repositoryItems)
            if (item.type == ItemType.task ||
                item.type == ItemType.schedule ||
                (item.type == ItemType.course &&
                    (activeTimetableId == null ||
                        item.courseDetails.timetableId == activeTimetableId)))
              item,
        ];
  final laidOutItems = HomeHeaderViewModel._itemLayoutBuilder.build(
    items: visibleItems,
    visibleRange: previewGrid.visibleRange,
    timeSlots: previewGrid.timeSlots,
  );
  final selectedCell = state.selectedDate == null || state.selectedSlotIndex == null
      ? null
      : () {
          final slotIndex = state.selectedSlotIndex!;
          if (slotIndex < 0 || slotIndex >= previewGrid.timeSlots.length) {
            return null;
          }
          return HomeCellSelection(
            date: state.selectedDate!,
            slot: previewGrid.timeSlots[slotIndex],
          );
        }();

  final baseViewData = HomeViewData(
    scope: previewGrid.scope,
    periodLabel: previewGrid.periodLabel,
    periodSubtitle: previewGrid.periodSubtitle,
    metrics: previewGrid.metrics,
    visibleRange: previewGrid.visibleRange,
    periodSelection: previewGrid.periodSelection,
    selectedCell: selectedCell,
    columns: previewGrid.columns,
    timeSlots: previewGrid.timeSlots,
    items: laidOutItems,
  );
  final semesterWeekLabel = _buildSemesterWeekLabel(
    localeTag: query.localeTag,
    scope: scope,
    visibleRangeStart: baseViewData.visibleRange.start,
    activeTimetableId: activeTimetableId,
    timetabledCourseItems: !shouldLoadItems
        ? const <AgendaItem>[]
        : [
      for (final item in repositoryItems)
        if (item.type == ItemType.course && item.courseDetails.timetableId.isNotEmpty) item,
    ],
  );
  if (semesterWeekLabel == null) {
    final prefixedLabel = _withCurrentWeekPrefixIfNeeded(
      label: baseViewData.periodLabel,
      localeTag: query.localeTag,
      scope: scope,
      visibleRangeStart: baseViewData.visibleRange.start,
    );
    if (prefixedLabel == baseViewData.periodLabel) {
      return baseViewData;
    }
    return HomeViewData(
      scope: baseViewData.scope,
      periodLabel: prefixedLabel,
      periodSubtitle: baseViewData.periodSubtitle,
      metrics: baseViewData.metrics,
      visibleRange: baseViewData.visibleRange,
      periodSelection: baseViewData.periodSelection,
      selectedCell: baseViewData.selectedCell,
      columns: baseViewData.columns,
      timeSlots: baseViewData.timeSlots,
      items: baseViewData.items,
    );
  }

  return HomeViewData(
    scope: baseViewData.scope,
    periodLabel: semesterWeekLabel,
    periodSubtitle: baseViewData.periodSubtitle,
    metrics: baseViewData.metrics,
    visibleRange: baseViewData.visibleRange,
    periodSelection: baseViewData.periodSelection,
    selectedCell: baseViewData.selectedCell,
    columns: baseViewData.columns,
    timeSlots: baseViewData.timeSlots,
    items: baseViewData.items,
  );
});

final homeWindowLoadedProvider = Provider.family<bool, HomeViewQuery>((ref, query) {
  final state = ref.watch(homeHeaderViewModelProvider);
  final settings = ref.watch(appHomeSettingsProvider);
  ref.watch(agendaItemRepositoryProvider);
  final repository = ref.read(agendaItemRepositoryProvider.notifier);
  final scope = query.allowMonthLayout && settings.wideLayoutScope == HomeWideLayoutScope.month
      ? HomeDisplayScope.month
      : HomeDisplayScope.week;
  final visibleRange = HomeHeaderViewModel._gridBuilder.visibleDateRange(state.anchor, scope);
  if (settings.showDemoData) {
    return true;
  }
  final windowKey = _homeWindowKey(scope: scope, anchor: visibleRange.start);
  return repository.hasLoadedWindow(windowKey);
});

String _homeWindowKey({
  required HomeDisplayScope scope,
  required DateTime anchor,
}) {
  final date = DateUtils.dateOnly(anchor);
  return switch (scope) {
    HomeDisplayScope.week => 'week:${date.toIso8601String()}',
    HomeDisplayScope.month => 'month:${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}',
  };
}

String? _buildSemesterWeekLabel({
  required String localeTag,
  required HomeDisplayScope scope,
  required DateTime visibleRangeStart,
  required String? activeTimetableId,
  required List<AgendaItem> timetabledCourseItems,
}) {
  if (scope != HomeDisplayScope.week || timetabledCourseItems.isEmpty) {
    return null;
  }

  final String? targetTimetableId = () {
    if (activeTimetableId != null && activeTimetableId.isNotEmpty) {
      return activeTimetableId;
    }
    final ids = <String>{
      for (final item in timetabledCourseItems) item.courseDetails.timetableId,
    };
    return ids.length == 1 ? ids.first : null;
  }();
  if (targetTimetableId == null) {
    return null;
  }

  DateTime? semesterFirstDay;
  for (final item in timetabledCourseItems) {
    if (item.courseDetails.timetableId != targetTimetableId) {
      continue;
    }
    final startDate = DateUtils.dateOnly(item.startAt);
    if (semesterFirstDay == null || startDate.isBefore(semesterFirstDay)) {
      semesterFirstDay = startDate;
    }
  }
  if (semesterFirstDay == null) {
    return null;
  }

  final semesterWeekOneMonday =
      semesterFirstDay.subtract(Duration(days: semesterFirstDay.weekday - DateTime.monday));
  final currentMonday = DateUtils.dateOnly(visibleRangeStart)
      .subtract(Duration(days: visibleRangeStart.weekday - DateTime.monday));
  final weekIndex = currentMonday.difference(semesterWeekOneMonday).inDays ~/ 7 + 1;
  if (weekIndex <= 0) {
    return null;
  }

  if (!localeTag.startsWith('zh')) {
    return 'Week $weekIndex';
  }
  final today = DateUtils.dateOnly(DateTime.now());
  final todayMonday = today.subtract(Duration(days: today.weekday - DateTime.monday));
  if (DateUtils.isSameDay(todayMonday, currentMonday)) {
    return '本周·第$weekIndex周';
  }
  return '第$weekIndex周';
}

String _withCurrentWeekPrefixIfNeeded({
  required String label,
  required String localeTag,
  required HomeDisplayScope scope,
  required DateTime visibleRangeStart,
}) {
  if (!localeTag.startsWith('zh') || scope != HomeDisplayScope.week) {
    return label;
  }
  if (label.startsWith('本周·')) {
    return label;
  }
  final today = DateUtils.dateOnly(DateTime.now());
  final todayMonday = today.subtract(Duration(days: today.weekday - DateTime.monday));
  final visibleMonday = DateUtils.dateOnly(visibleRangeStart)
      .subtract(Duration(days: visibleRangeStart.weekday - DateTime.monday));
  if (!DateUtils.isSameDay(todayMonday, visibleMonday)) {
    return label;
  }
  return '本周·$label';
}

