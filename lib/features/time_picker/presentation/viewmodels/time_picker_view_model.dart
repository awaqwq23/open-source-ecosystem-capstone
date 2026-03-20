import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';

class TimePickerState {
  const TimePickerState({
    required this.mode,
    required this.displayMonth,
    required this.selectedDate,
  });

  final TimePickerMode mode;
  final DateTime displayMonth;
  final DateTime selectedDate;

  TimePickerState copyWith({
    TimePickerMode? mode,
    DateTime? displayMonth,
    DateTime? selectedDate,
  }) {
    return TimePickerState(
      mode: mode ?? this.mode,
      displayMonth: displayMonth ?? this.displayMonth,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class TimePickerViewModel extends AutoDisposeNotifier<TimePickerState> {
  TimePickerArgs? _args;

  @override
  TimePickerState build() {
    final now = DateTime.now();
    return TimePickerState(
      mode: TimePickerMode.day,
      displayMonth: DateTime(now.year, now.month, 1),
      selectedDate: DateUtils.dateOnly(now),
    );
  }

  void initialize(TimePickerArgs? args) {
    if (_args == args && args != null) {
      return;
    }
    _args = args;
    final now = DateUtils.dateOnly(args?.initialDate ?? DateTime.now());
    state = TimePickerState(
      mode: args?.mode ?? TimePickerMode.day,
      displayMonth: DateTime(now.year, now.month, 1),
      selectedDate: now,
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

  void selectDate(DateTime date) {
    final normalized = DateUtils.dateOnly(date);
    state = state.copyWith(
      selectedDate: switch (state.mode) {
        TimePickerMode.day => normalized,
        TimePickerMode.week =>
          normalized.subtract(Duration(days: normalized.weekday - DateTime.monday)),
        TimePickerMode.month => DateTime(normalized.year, normalized.month, 1),
      },
    );
  }

  void selectMode(TimePickerMode mode) {
    state = state.copyWith(mode: mode);
    selectDate(state.selectedDate);
  }

  List<DateTime?> visibleDays() {
    final firstDay = state.displayMonth;
    final offset = firstDay.weekday - DateTime.monday;
    final start = firstDay.subtract(Duration(days: offset));
    return [
      for (var index = 0; index < 42; index++) start.add(Duration(days: index)),
    ];
  }
}

final timePickerViewModelProvider =
    NotifierProvider.autoDispose<TimePickerViewModel, TimePickerState>(
  TimePickerViewModel.new,
);
