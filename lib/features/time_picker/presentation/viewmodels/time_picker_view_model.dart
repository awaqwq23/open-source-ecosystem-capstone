import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';

class TimePickerState {
  const TimePickerState({
    required this.mode,
    required this.displayMonth,
    required this.selectedAnchor,
  });

  final TimePickerMode mode;
  final DateTime displayMonth;
  final DateTime selectedAnchor;

  TimePickerState copyWith({
    TimePickerMode? mode,
    DateTime? displayMonth,
    DateTime? selectedAnchor,
  }) {
    return TimePickerState(
      mode: mode ?? this.mode,
      displayMonth: displayMonth ?? this.displayMonth,
      selectedAnchor: selectedAnchor ?? this.selectedAnchor,
    );
  }
}

class TimePickerWeekRow {
  const TimePickerWeekRow({
    required this.startOfWeek,
    required this.days,
  });

  final DateTime startOfWeek;
  final List<DateTime> days;
}

class TimePickerViewModel extends AutoDisposeNotifier<TimePickerState> {
  TimePickerArgs? _args;

  @override
  TimePickerState build() {
    final now = DateUtils.dateOnly(DateTime.now());
    return TimePickerState(
      mode: TimePickerMode.day,
      displayMonth: DateTime(now.year, now.month, 1),
      selectedAnchor: now,
    );
  }

  void initialize(TimePickerArgs? args) {
    if (_args == args && args != null) {
      return;
    }
    _args = args;
    final now = DateUtils.dateOnly(args?.initialDate ?? DateTime.now());
    final mode = args?.mode ?? TimePickerMode.day;
    state = TimePickerState(
      mode: mode,
      displayMonth: DateTime(now.year, now.month, 1),
      selectedAnchor: _normalizeForMode(now, mode),
    );
  }

  void showPreviousMonth() {
    state = state.copyWith(
      displayMonth: DateTime(state.displayMonth.year, state.displayMonth.month - 1, 1),
    );
  }

  void showNextMonth() {
    state = state.copyWith(
      displayMonth: DateTime(state.displayMonth.year, state.displayMonth.month + 1, 1),
    );
  }

  void jumpToMonth(DateTime date) {
    state = state.copyWith(
      displayMonth: DateTime(date.year, date.month, 1),
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedAnchor: _normalizeForMode(date, state.mode));
  }

  void selectWeek(DateTime date) {
    state = state.copyWith(
      mode: TimePickerMode.week,
      selectedAnchor: _normalizeForMode(date, TimePickerMode.week),
    );
  }

  void selectMonth(DateTime date) {
    final normalized = _normalizeForMode(date, TimePickerMode.month);
    state = state.copyWith(
      mode: TimePickerMode.month,
      displayMonth: DateTime(normalized.year, normalized.month, 1),
      selectedAnchor: normalized,
    );
  }

  void selectMode(TimePickerMode mode) {
    state = state.copyWith(
      mode: mode,
      selectedAnchor: _normalizeForMode(state.selectedAnchor, mode),
    );
  }

  TimePickerSelection confirmSelection() {
    return TimePickerSelection(
      mode: state.mode,
      anchor: state.selectedAnchor,
    );
  }

  List<TimePickerWeekRow> visibleWeeks() {
    final firstDay = state.displayMonth;
    final offset = firstDay.weekday - DateTime.monday;
    final start = firstDay.subtract(Duration(days: offset));
    return [
      for (var row = 0; row < 6; row++)
        TimePickerWeekRow(
          startOfWeek: start.add(Duration(days: row * 7)),
          days: [
            for (var column = 0; column < 7; column++)
              start.add(Duration(days: row * 7 + column)),
          ],
        ),
    ];
  }

  bool isMonthSelected() {
    return state.mode == TimePickerMode.month &&
        state.selectedAnchor.year == state.displayMonth.year &&
        state.selectedAnchor.month == state.displayMonth.month;
  }

  bool isWeekSelected(DateTime weekStart) {
    final selectedWeek = _normalizeForMode(state.selectedAnchor, TimePickerMode.week);
    return state.mode == TimePickerMode.week && DateUtils.isSameDay(selectedWeek, weekStart);
  }

  bool isDaySelected(DateTime day) {
    return state.mode == TimePickerMode.day && DateUtils.isSameDay(state.selectedAnchor, day);
  }

  DateTime _normalizeForMode(DateTime date, TimePickerMode mode) {
    final normalized = DateUtils.dateOnly(date);
    return switch (mode) {
      TimePickerMode.day => normalized,
      TimePickerMode.week =>
        normalized.subtract(Duration(days: normalized.weekday - DateTime.monday)),
      TimePickerMode.month => DateTime(normalized.year, normalized.month, 1),
    };
  }
}

final timePickerViewModelProvider =
    NotifierProvider.autoDispose<TimePickerViewModel, TimePickerState>(
  TimePickerViewModel.new,
);
