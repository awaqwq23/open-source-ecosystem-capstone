import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/item_editor/data/item_editor_repository.dart';
import 'package:huajuan_agenda/features/item_editor/domain/item_editor_defaults.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/item_editor_validator.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';

class ItemEditorPageState {
  const ItemEditorPageState({
    required this.itemId,
    required this.draft,
    required this.isImportant,
    this.errors = const ItemEditorValidationErrors(),
    this.isSubmitting = false,
    this.submitSucceeded = false,
  });

  final String? itemId;
  final ItemDraft draft;
  final bool isImportant;
  final ItemEditorValidationErrors errors;
  final bool isSubmitting;
  final bool submitSucceeded;

  bool get canSubmit => !isSubmitting;
  bool get isEditing => itemId != null;

  ItemEditorPageState copyWith({
    String? itemId,
    bool clearItemId = false,
    ItemDraft? draft,
    bool? isImportant,
    ItemEditorValidationErrors? errors,
    bool? isSubmitting,
    bool? submitSucceeded,
  }) {
    return ItemEditorPageState(
      itemId: clearItemId ? null : (itemId ?? this.itemId),
      draft: draft ?? this.draft,
      isImportant: isImportant ?? this.isImportant,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
    );
  }
}

class ItemEditorPageController extends AutoDisposeNotifier<ItemEditorPageState> {
  ItemEditorArgs? _args;

  @override
  ItemEditorPageState build() {
    return ItemEditorPageState(
      itemId: null,
      draft: ItemEditorDefaults.createDraft(),
      isImportant: false,
    );
  }

  void initialize([ItemEditorArgs? args]) {
    if (_args == args && args != null) {
      return;
    }

    _args = args;
    final prefill = args?.prefill;
    state = ItemEditorPageState(
      itemId: args?.itemId,
      draft: ItemEditorDefaults.createDraft(prefill),
      isImportant: prefill?.isImportant ?? false,
    );
  }

  void selectType(ItemType type) {
    _updateDraft(ItemEditorDefaults.applyType(state.draft, type));
  }

  void updateTitle(String value) {
    _updateDraft(state.draft.copyWith(title: value));
  }

  void updateDetails(String value) {
    _updateDraft(state.draft.copyWith(details: value));
  }

  void updateLocation(String value) {
    _updateDraft(state.draft.copyWith(location: value));
  }

  void selectColor(ItemColorOption color) {
    _updateDraft(state.draft.copyWith(color: color));
  }

  void toggleAllDay(bool value) {
    if (state.draft.type == ItemType.memo) {
      return;
    }

    if (value) {
      final normalizedStart = DateTime(
        state.draft.startAt.year,
        state.draft.startAt.month,
        state.draft.startAt.day,
      );
      final normalizedEnd = DateTime(
        state.draft.endAt.year,
        state.draft.endAt.month,
        state.draft.endAt.day,
        23,
        59,
      );
      final normalizedDeadline = state.draft.deadline == null
          ? null
          : DateTime(
              state.draft.deadline!.year,
              state.draft.deadline!.month,
              state.draft.deadline!.day,
              23,
              59,
            );

      _updateDraft(
        state.draft.copyWith(
          isAllDay: true,
          startAt: normalizedStart,
          endAt: normalizedEnd.isBefore(normalizedStart)
              ? DateTime(
                  normalizedStart.year,
                  normalizedStart.month,
                  normalizedStart.day,
                  23,
                  59,
                )
              : normalizedEnd,
          deadline: normalizedDeadline,
        ),
      );
      return;
    }

    final start = DateTime(
      state.draft.startAt.year,
      state.draft.startAt.month,
      state.draft.startAt.day,
      9,
    );
    final hasSameDayRange = DateUtils.isSameDay(state.draft.startAt, state.draft.endAt);
    final end = hasSameDayRange
        ? start.add(const Duration(hours: 1))
        : DateTime(
            state.draft.endAt.year,
            state.draft.endAt.month,
            state.draft.endAt.day,
            10,
          );
    final deadline = state.draft.deadline == null
        ? null
        : DateTime(
            state.draft.deadline!.year,
            state.draft.deadline!.month,
            state.draft.deadline!.day,
            18,
          );

    _updateDraft(
      state.draft.copyWith(
        isAllDay: false,
        startAt: start,
        endAt: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
        deadline: deadline,
      ),
    );
  }

  void selectReminder(ReminderOption option) {
    _updateDraft(state.draft.copyWith(reminder: option));
  }

  void selectRepeatRule(RepeatRule rule) {
    _updateDraft(state.draft.copyWith(repeatRule: rule));
  }

  void updateStartDate(DateTime date) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      state.draft.startAt.hour,
      state.draft.startAt.minute,
    );
    final end = state.draft.endAt.isBefore(start) ? start : state.draft.endAt;
    _updateDraft(
      state.draft.copyWith(
        startAt: start,
        endAt: end,
        targetDate: date,
      ),
    );
  }

  void updateStartDateTime(DateTime dateTime) {
    final end = state.draft.endAt.isBefore(dateTime) ? dateTime : state.draft.endAt;
    _updateDraft(
      state.draft.copyWith(
        startAt: dateTime,
        endAt: end,
        targetDate: dateTime,
      ),
    );
  }

  void updateStartTime(int hour, int minute) {
    final start = DateTime(
      state.draft.startAt.year,
      state.draft.startAt.month,
      state.draft.startAt.day,
      hour,
      minute,
    );
    final end = state.draft.endAt.isBefore(start) ? start : state.draft.endAt;
    _updateDraft(state.draft.copyWith(startAt: start, endAt: end));
  }

  void updateEndDate(DateTime date) {
    final end = DateTime(
      date.year,
      date.month,
      date.day,
      state.draft.endAt.hour,
      state.draft.endAt.minute,
    );
    _updateDraft(state.draft.copyWith(endAt: end));
  }

  void updateEndTime(int hour, int minute) {
    final end = DateTime(
      state.draft.endAt.year,
      state.draft.endAt.month,
      state.draft.endAt.day,
      hour,
      minute,
    );
    _updateDraft(state.draft.copyWith(endAt: end));
  }

  void updateEndDateTime(DateTime dateTime) {
    _updateDraft(state.draft.copyWith(endAt: dateTime));
  }

  void updateDeadlineDate(DateTime date) {
    final currentDeadline = state.draft.deadline ?? state.draft.endAt;
    final deadline = DateTime(
      date.year,
      date.month,
      date.day,
      currentDeadline.hour,
      currentDeadline.minute,
    );
    _updateDraft(state.draft.copyWith(deadline: deadline));
  }

  void updateDeadlineTime(int hour, int minute) {
    final currentDeadline = state.draft.deadline ?? state.draft.endAt;
    final deadline = DateTime(
      currentDeadline.year,
      currentDeadline.month,
      currentDeadline.day,
      hour,
      minute,
    );
    _updateDraft(state.draft.copyWith(deadline: deadline));
  }

  void updateDeadlineDateTime(DateTime dateTime) {
    _updateDraft(state.draft.copyWith(deadline: dateTime));
  }

  void clearDeadline() {
    _updateDraft(state.draft.copyWith(clearDeadline: true));
  }

  void updateTargetDate(DateTime date) {
    _updateDraft(state.draft.copyWith(targetDate: date));
  }

  void updateEstimatedDuration(Duration duration) {
    _updateDraft(state.draft.copyWith(estimatedDuration: duration));
  }

  void toggleImportant(bool value) {
    state = state.copyWith(
      isImportant: value,
      errors: const ItemEditorValidationErrors(),
      submitSucceeded: false,
    );
  }

  Future<bool> submit(ItemEditorValidationErrors errors) async {
    state = state.copyWith(errors: errors, submitSucceeded: false);
    if (errors.hasErrors) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    final repository = ref.read(itemEditorRepositoryProvider);
    if (state.isEditing) {
      await repository.updateItem(
        state.itemId!,
        state.draft,
        isImportant: state.isImportant,
      );
    } else {
      await repository.createItem(
        state.draft,
        isImportant: state.isImportant,
      );
    }
    state = state.copyWith(
      isSubmitting: false,
      submitSucceeded: true,
    );
    return true;
  }

  void clearSubmitSucceeded() {
    if (state.submitSucceeded) {
      state = state.copyWith(submitSucceeded: false);
    }
  }

  void _updateDraft(ItemDraft draft) {
    state = state.copyWith(
      draft: draft,
      errors: const ItemEditorValidationErrors(),
      submitSucceeded: false,
    );
  }
}

final itemEditorPageControllerProvider =
    NotifierProvider.autoDispose<ItemEditorPageController, ItemEditorPageState>(
  ItemEditorPageController.new,
);
