import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/ai/data/ai_in_memory_data_source.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/shared/data/agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

enum AiHeaderPeriod {
  day,
  week,
  month,
}

class AiHeaderState {
  const AiHeaderState({
    required this.period,
    required this.anchor,
    this.input = '',
    this.isSending = false,
    this.lastError,
  });

  final AiHeaderPeriod period;
  final DateTime anchor;
  final String input;
  final bool isSending;
  final String? lastError;

  AiHeaderState copyWith({
    AiHeaderPeriod? period,
    DateTime? anchor,
    String? input,
    bool? isSending,
    String? lastError,
    bool clearError = false,
  }) {
    return AiHeaderState(
      period: period ?? this.period,
      anchor: anchor ?? this.anchor,
      input: input ?? this.input,
      isSending: isSending ?? this.isSending,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

class AiHeaderViewModel extends Notifier<AiHeaderState> {
  @override
  AiHeaderState build() {
    return AiHeaderState(
      period: AiHeaderPeriod.day,
      anchor: DateTime(2026, 3, 20),
    );
  }

  void select(AiHeaderPeriod period) {
    state = state.copyWith(period: period);
  }

  void updateInput(String value) {
    state = state.copyWith(input: value, clearError: true);
  }

  void selectAnchor(DateTime date) {
    state = state.copyWith(anchor: DateTime(date.year, date.month, date.day));
  }

  Future<void> sendMessage() async {
    final content = state.input.trim();
    if (content.isEmpty) {
      return;
    }

    state = state.copyWith(isSending: true, clearError: true);
    final repository = ref.read(aiChatRepositoryNotifierProvider);
    final service = ref.read(aiServiceProvider);
    final now = DateTime.now();

    await repository.append(
      AiChatMessage(
        id: 'user_${now.microsecondsSinceEpoch}',
        content: content,
        createdAt: now,
        role: AiChatRole.user,
      ),
    );

    try {
      final reply = await service.sendMessage(
        message: content,
        items: ref.read(agendaItemRepositoryProvider),
      );
      await repository.append(reply);
      state = state.copyWith(
        input: '',
        isSending: false,
      );
    } catch (_) {
      state = state.copyWith(
        isSending: false,
        lastError: 'AI 服务暂不可用',
      );
    }
  }

  DateTimeRangeValue visibleRange() {
    final anchor = DateTime(state.anchor.year, state.anchor.month, state.anchor.day);
    return switch (state.period) {
      AiHeaderPeriod.day => DateTimeRangeValue(
          start: anchor,
          end: anchor.add(const Duration(days: 1)),
        ),
      AiHeaderPeriod.week => DateTimeRangeValue(
          start: anchor.subtract(Duration(days: anchor.weekday - DateTime.monday)),
          end: anchor
              .subtract(Duration(days: anchor.weekday - DateTime.monday))
              .add(const Duration(days: 7)),
        ),
      AiHeaderPeriod.month => DateTimeRangeValue(
          start: DateTime(anchor.year, anchor.month, 1),
          end: DateTime(anchor.year, anchor.month + 1, 1),
        ),
    };
  }
}

final aiHeaderViewModelProvider =
    NotifierProvider<AiHeaderViewModel, AiHeaderState>(
  AiHeaderViewModel.new,
);

final aiConversationGroupsProvider = Provider<List<AiConversationGroup>>((ref) {
  final range = ref.read(aiHeaderViewModelProvider.notifier).visibleRange();
  final messages = ref.watch(aiChatRepositoryProvider).where((message) {
    return !message.createdAt.isBefore(range.start) && message.createdAt.isBefore(range.end);
  }).toList()
    ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
  return [
    AiConversationGroup(
      label: '${range.start.year}/${range.start.month}/${range.start.day}',
      range: range,
      messages: messages,
    ),
  ];
});
