import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/item_editor/domain/item_editor_defaults.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_args.dart';
import 'package:luotopia/features/pages/item_editor/domain/repositories/item_editor_repository_provider.dart';
import 'package:luotopia/features/pages/item_editor/domain/use_cases/build_item_editor_draft.dart';
import 'package:luotopia/features/pages/item_editor/domain/use_cases/save_item_draft.dart';
import 'package:luotopia/features/pages/item_editor/domain/item_editor_validator.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

enum CourseColorUpdateScope {
  singleItem,
  sameTitleCourses,
}

class ItemEditorPageState {
  const ItemEditorPageState({
    required this.itemId,
    required this.draft,
    this.errors = const ItemEditorValidationErrors(),
    this.isSubmitting = false,
    this.submitSucceeded = false,
  });

  final String? itemId;
  final ItemDraft draft;
  final ItemEditorValidationErrors errors;
  final bool isSubmitting;
  final bool submitSucceeded;

  bool get canSubmit => !isSubmitting;
  bool get isEditing => itemId != null;

  ItemEditorPageState copyWith({
    String? itemId,
    bool clearItemId = false,
    ItemDraft? draft,
    ItemEditorValidationErrors? errors,
    bool? isSubmitting,
    bool? submitSucceeded,
  }) {
    return ItemEditorPageState(
      itemId: clearItemId ? null : (itemId ?? this.itemId),
      draft: draft ?? this.draft,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
    );
  }
}

class ItemEditorPageController extends AutoDisposeNotifier<ItemEditorPageState> {
  static const _buildDraft = BuildItemEditorDraftUseCase();
  ItemEditorArgs? _args;
  CourseColorUpdateScope _courseColorUpdateScope = CourseColorUpdateScope.singleItem;

  @override
  ItemEditorPageState build() {
    return ItemEditorPageState(
      itemId: null,
      draft: _buildDraft(),
    );
  }

  void initialize([ItemEditorArgs? args]) {
    if (_args == args && args != null) {
      return;
    }

    _args = args;
    _courseColorUpdateScope = CourseColorUpdateScope.singleItem;
    final prefill = args?.prefill;
    var draft = _buildDraft(prefill);
    state = ItemEditorPageState(
      itemId: args?.itemId,
      draft: _normalizeDraft(draft),
    );
  }

  void selectType(ItemType type) {
    if (type != ItemType.course) {
      _courseColorUpdateScope = CourseColorUpdateScope.singleItem;
    }
    _updateDraft(ItemEditorDefaults.applyType(state.draft, type));
  }

  void updateTitle(String value) {
    _updateDraft(state.draft.copyWith(title: value));
  }

  void updateDetails(String value) {
    _updateDraft(state.draft.copyWith(notes: value));
  }

  void updateLocation(String value) {
    _updateDraft(state.draft.copyWith(location: value));
  }

  void updateCourseNature(String value) {
    _updateDraft(
      state.draft.copyWith(
        courseDetails: state.draft.courseDetails.copyWith(courseNature: value),
      ),
    );
  }

  void updateCourseInstructor(String value) {
    _updateDraft(
      state.draft.copyWith(
        courseDetails: state.draft.courseDetails.copyWith(instructor: value),
      ),
    );
  }

  void selectColor(
    ItemColorOption color, {
    CourseColorUpdateScope courseScope = CourseColorUpdateScope.singleItem,
  }) {
    _courseColorUpdateScope = courseScope;
    _updateDraft(state.draft.copyWith(color: color));
  }

  void toggleAllDay(bool value) {
    if (state.draft.type == ItemType.memo) {
      return;
    }

    if (_shouldDeriveEndFromDuration(state.draft)) {
      if (value) {
        final normalizedStart = DateTime(
          state.draft.startAt.year,
          state.draft.startAt.month,
          state.draft.startAt.day,
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
          deadline: deadline,
        ),
      );
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
    final end = state.draft.type == ItemType.schedule
        ? DateTime(
            date.year,
            date.month,
            date.day,
            state.draft.endAt.hour,
            state.draft.endAt.minute,
          )
        : (state.draft.endAt.isBefore(start) ? start : state.draft.endAt);
    _updateDraft(
      state.draft.copyWith(
        startAt: start,
        endAt: end.isBefore(start) ? start : end,
      ),
    );
  }

  void updateStartDateTime(DateTime dateTime) {
    final end = state.draft.endAt.isBefore(dateTime) ? dateTime : state.draft.endAt;
    _updateDraft(
      state.draft.copyWith(
        startAt: dateTime,
        endAt: end,
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
    if (_shouldDeriveEndFromDuration(state.draft)) {
      return;
    }
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
    if (_shouldDeriveEndFromDuration(state.draft)) {
      return;
    }
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
    if (_shouldDeriveEndFromDuration(state.draft)) {
      return;
    }
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

  void updateEstimatedDuration(Duration duration) {
    _updateDraft(state.draft.copyWith(estimatedDuration: duration));
  }

  Future<bool> submit(ItemEditorValidationErrors errors) async {
    state = state.copyWith(errors: errors, submitSucceeded: false);
    if (errors.hasErrors) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    final repository = ref.read(itemEditorRepositoryProvider);
    final saveDraft = SaveItemDraftUseCase(repository);
    var draft = _normalizeDraftForSave(state.draft);
    if (draft.type == ItemType.course) {
      draft = draft.copyWith(
        reminder: ReminderOption.none,
        repeatRule: RepeatRule.none,
      );
    }
    await saveDraft(
      itemId: state.itemId,
      draft: draft,
    );
    if (draft.type == ItemType.course &&
        state.itemId != null &&
        _courseColorUpdateScope == CourseColorUpdateScope.sameTitleCourses) {
      await repository.updateCourseColorByTitle(
        title: draft.title,
        color: draft.color,
      );
    }
    _courseColorUpdateScope = CourseColorUpdateScope.singleItem;
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
    final normalizedDraft = _normalizeDraft(draft);
    state = state.copyWith(
      draft: normalizedDraft,
      errors: const ItemEditorValidationErrors(),
      submitSucceeded: false,
    );
  }

  ItemDraft _normalizeDraft(ItemDraft draft) {
    if (!_shouldDeriveEndFromDuration(draft)) {
      return draft;
    }
    final duration = _effectiveEstimatedDuration(draft.estimatedDuration);
    final derivedEndAt = draft.startAt.add(duration);
    return draft.copyWith(
      endAt: derivedEndAt,
    );
  }

  ItemDraft _normalizeDraftForSave(ItemDraft draft) {
    if (draft.type != ItemType.task) {
      return draft;
    }
    if (draft.estimatedDuration > Duration.zero) {
      return draft;
    }
    return draft.copyWith(estimatedDuration: const Duration(hours: 1));
  }

  Duration _effectiveEstimatedDuration(Duration duration) {
    return duration > Duration.zero ? duration : const Duration(hours: 1);
  }

  bool _shouldDeriveEndFromDuration(ItemDraft draft) {
    return draft.type == ItemType.task;
  }
}

final itemEditorPageControllerProvider =
    NotifierProvider.autoDispose<ItemEditorPageController, ItemEditorPageState>(
  ItemEditorPageController.new,
);

