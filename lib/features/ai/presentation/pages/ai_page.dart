import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_navigator.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/ai/data/voice_input_service_impl.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_action_models.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/ai/presentation/viewmodels/ai_header_view_model.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AiPage extends ConsumerStatefulWidget {
  const AiPage({
    this.autoFocusInput = false,
    super.key,
  });

  final bool autoFocusInput;

  @override
  ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
  late final TextEditingController _controller;
  late final FocusNode _inputFocusNode;
  bool _focusRequested = false;
  bool _isVoiceSupported = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _inputFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareVoiceSupport();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiHeaderViewModelProvider);
    final groups = ref.watch(aiConversationGroupsProvider);
    _syncController(state.input);
    _tryAutoFocus();

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(context.l10n.aiTitle),
          trailing: [
            ui.Tooltip(
              tooltip: (context) => Text(context.l10n.headerOpenTimePicker),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.openTimePicker),
                onPressed: () => _showPeriodPicker(context, ref),
              ),
            ),
          ],
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1040;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildMainColumn(context, state, groups),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 340,
                            child: _DraftPanel(
                              pendingDraft: state.pendingDraft,
                              onConfirm: state.phase == AiWorkflowPhase.creating
                                  ? null
                                  : ref
                                      .read(aiHeaderViewModelProvider.notifier)
                                      .confirmCreateDraft,
                              onDiscard: ref
                                  .read(aiHeaderViewModelProvider.notifier)
                                  .discardCreateDraft,
                              isCreating: state.phase == AiWorkflowPhase.creating,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildMainColumn(context, state, groups),
                          const SizedBox(height: 16),
                          _DraftPanel(
                            pendingDraft: state.pendingDraft,
                            onConfirm: state.phase == AiWorkflowPhase.creating
                                ? null
                                : ref
                                    .read(aiHeaderViewModelProvider.notifier)
                                    .confirmCreateDraft,
                            onDiscard: ref
                                .read(aiHeaderViewModelProvider.notifier)
                                .discardCreateDraft,
                            isCreating: state.phase == AiWorkflowPhase.creating,
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainColumn(
    BuildContext context,
    AiHeaderState state,
    List<AiConversationGroup> groups,
  ) {
    final theme = Theme.of(context);
    return ui.Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppIcons.aiFilled,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.aiPeriodSummary(
                      _periodLabel(context, state),
                      groups.length,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ui.PrimaryButton(
                  onPressed: () => _showPeriodPicker(context, ref),
                  child: Text(_periodLabel(context, state)),
                ),
                ui.GhostButton(
                  onPressed: () => _openTimePicker(context, state),
                  child: Text(context.l10n.timePickerTitle),
                ),
              ],
            ),
            if (!state.composerEnabled || state.lastError != null) ...[
              const SizedBox(height: 12),
              _buildStatusBanner(context, state),
            ],
            const SizedBox(height: 16),
            _ConversationList(groups: groups),
            const SizedBox(height: 12),
            _buildComposer(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, AiHeaderState state) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.composerDisabledReason ?? state.lastError ?? _text(context, zh: 'AI 发生错误', en: 'AI error'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ui.GhostButton(
                onPressed: () => context.go(AppRoutePaths.settingsAi),
                child: Text(_text(context, zh: '前往 AI 设置', en: 'Open AI Settings')),
              ),
              ui.GhostButton(
                onPressed: ref.read(aiHeaderViewModelProvider.notifier).retryEnableComposer,
                child: Text(_text(context, zh: '重试', en: 'Retry')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context, AiHeaderState state) {
    final notifier = ref.read(aiHeaderViewModelProvider.notifier);
    final localeId = Localizations.localeOf(context).toLanguageTag();
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _inputFocusNode,
          onChanged: notifier.updateInput,
          minLines: 2,
          maxLines: 4,
          enabled: state.composerEnabled && !state.isBusy,
          decoration: InputDecoration(
            hintText: context.l10n.aiInputHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ui.PrimaryButton(
                onPressed: state.canSend
                    ? ref.read(aiHeaderViewModelProvider.notifier).sendMessage
                    : null,
                child: Text(
                  state.isBusy
                      ? context.l10n.aiSendingButton
                      : context.l10n.aiSendButton,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onLongPressStart: (_) => _startVoice(localeId),
              onLongPressEnd: (_) => _stopVoice(),
              child: ui.GhostButton(
                onPressed: _isVoiceSupported
                    ? () {}
                    : null,
                child: Row(
                  children: [
                    Icon(
                      Icons.mic,
                      size: 18,
                      color: _isListening ? Colors.red : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isListening
                          ? _text(context, zh: '松开发送转写', en: 'Release to transcribe')
                          : _text(context, zh: '长按语音', en: 'Hold to speak'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant AiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.autoFocusInput && widget.autoFocusInput) {
      _focusRequested = false;
      _tryAutoFocus();
    }
  }

  void _tryAutoFocus() {
    if (!widget.autoFocusInput || _focusRequested) {
      return;
    }
    _focusRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _inputFocusNode.requestFocus();
    });
  }

  void _syncController(String value) {
    if (_controller.text == value) {
      return;
    }
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _periodLabel(BuildContext context, AiHeaderState state) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return switch (state.period) {
      AiHeaderPeriod.day => DateFormat.yMd(locale).format(state.anchor),
      AiHeaderPeriod.week => locale.startsWith('zh')
          ? '${DateFormat.yM(locale).format(state.anchor)} 第${_weekOfMonth(state.anchor)}周'
          : 'Week ${_weekOfMonth(state.anchor)} of ${DateFormat.yMMMM(locale).format(state.anchor)}',
      AiHeaderPeriod.month => DateFormat.yMMMM(locale).format(state.anchor),
    };
  }

  int _weekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final offset = firstDay.weekday - DateTime.monday;
    return ((date.day + offset - 1) ~/ 7) + 1;
  }

  Future<void> _showPeriodPicker(BuildContext context, WidgetRef ref) {
    final state = ref.read(aiHeaderViewModelProvider);
    final l10n = context.l10n;

    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: RadioGroup<AiHeaderPeriod>(
            groupValue: state.period,
            onChanged: (value) {
              if (value == null) return;
              ref.read(aiHeaderViewModelProvider.notifier).select(value);
              ui.closeDrawer(sheetContext);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiPeriodPickerTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),
                RadioListTile<AiHeaderPeriod>(
                  value: AiHeaderPeriod.day,
                  title: Text(l10n.aiPeriodDay),
                ),
                RadioListTile<AiHeaderPeriod>(
                  value: AiHeaderPeriod.week,
                  title: Text(l10n.aiPeriodWeek),
                ),
                RadioListTile<AiHeaderPeriod>(
                  value: AiHeaderPeriod.month,
                  title: Text(l10n.aiPeriodMonth),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openTimePicker(BuildContext context, AiHeaderState state) async {
    final result = await context.openModal<TimePickerSelection>(
      AppRoutePaths.timePicker,
      extra: TimePickerArgs(
        mode: switch (state.period) {
          AiHeaderPeriod.day => TimePickerMode.day,
          AiHeaderPeriod.week => TimePickerMode.week,
          AiHeaderPeriod.month => TimePickerMode.month,
        },
        initialDate: state.anchor,
      ),
    );
    if (result != null && mounted) {
      ref.read(aiHeaderViewModelProvider.notifier).selectAnchor(result.anchor);
    }
  }

  Future<void> _prepareVoiceSupport() async {
    final supported = await ref.read(voiceInputServiceProvider).isSupported();
    if (!mounted) {
      return;
    }
    setState(() {
      _isVoiceSupported = supported;
    });
  }

  Future<void> _startVoice(String localeId) async {
    if (!_isVoiceSupported || _isListening) {
      return;
    }
    final started = await ref.read(voiceInputServiceProvider).startListening(
          localeId: localeId,
        );
    if (!mounted) {
      return;
    }
    if (started) {
      setState(() {
        _isListening = true;
      });
    }
  }

  Future<void> _stopVoice() async {
    if (!_isListening) {
      return;
    }
    final text = await ref.read(voiceInputServiceProvider).stopListening();
    if (!mounted) {
      return;
    }
    setState(() {
      _isListening = false;
    });
    if (text == null || text.trim().isEmpty) {
      return;
    }
    final merged = _controller.text.trim().isEmpty
        ? text.trim()
        : '${_controller.text.trim()} ${text.trim()}';
    ref.read(aiHeaderViewModelProvider.notifier).updateInput(merged);
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh') ? zh : en;
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.groups,
  });

  final List<AiConversationGroup> groups;

  @override
  Widget build(BuildContext context) {
    final hasHistory = groups.isNotEmpty && groups.any((group) => group.messages.isNotEmpty);
    if (!hasHistory) {
      return Text(context.l10n.aiEmptyState);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Text(
            group.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          for (final message in group.messages) ...[
            Align(
              alignment: message.role == AiChatRole.user
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: message.role == AiChatRole.user
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(message.content),
              ),
            ),
            if (message.citations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final citation in message.citations)
                      _CitationCard(citation: citation),
                  ],
                ),
              ),
          ],
        ],
      ],
    );
  }
}

class _CitationCard extends StatelessWidget {
  const _CitationCard({
    required this.citation,
  });

  final AiCitation citation;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timeLabel = citation.startAt == null
        ? ''
        : DateFormat.yMd(locale).add_Hm().format(citation.startAt!);
    return Container(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 280),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            citation.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_typeLabel(context, citation.type)} ${timeLabel.isEmpty ? '' : '· $timeLabel'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if ((citation.reason ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              citation.reason!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  String _typeLabel(BuildContext context, ItemType type) {
    final zh = Localizations.localeOf(context).languageCode.startsWith('zh');
    return switch (type) {
      ItemType.schedule => zh ? '日程' : 'Schedule',
      ItemType.task => zh ? '任务' : 'Task',
      ItemType.memo => zh ? '备忘' : 'Memo',
      ItemType.course => zh ? '课程' : 'Course',
    };
  }
}

class _DraftPanel extends StatelessWidget {
  const _DraftPanel({
    required this.pendingDraft,
    required this.onConfirm,
    required this.onDiscard,
    required this.isCreating,
  });

  final AiCreateItemDraft? pendingDraft;
  final VoidCallback? onConfirm;
  final VoidCallback onDiscard;
  final bool isCreating;

  @override
  Widget build(BuildContext context) {
    final draft = pendingDraft;
    return ui.Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: draft == null
            ? Text(
                Localizations.localeOf(context).languageCode.startsWith('zh')
                    ? '暂无待确认草稿。发送一句自然语言，AI 会先生成结构化草稿。'
                    : 'No pending draft. Send a message and AI will build a structured draft first.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode.startsWith('zh')
                        ? '待确认事项草稿'
                        : 'Pending Draft',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _row(context, Localizations.localeOf(context).languageCode.startsWith('zh') ? '类型' : 'Type',
                      _typeLabel(context, draft.draft.type)),
                  _row(context, Localizations.localeOf(context).languageCode.startsWith('zh') ? '标题' : 'Title',
                      draft.draft.title.isEmpty ? '-' : draft.draft.title),
                  _row(context, Localizations.localeOf(context).languageCode.startsWith('zh') ? '开始' : 'Start',
                      DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
                          .add_Hm()
                          .format(draft.draft.startAt)),
                  _row(context, Localizations.localeOf(context).languageCode.startsWith('zh') ? '结束' : 'End',
                      DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
                          .add_Hm()
                          .format(draft.draft.endAt)),
                  if (draft.conflicts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      Localizations.localeOf(context).languageCode.startsWith('zh')
                          ? '检测到时间冲突'
                          : 'Potential conflicts',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    for (final conflict in draft.conflicts)
                      Text(
                        '• ${conflict.title}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                  if (draft.missingRequired.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      Localizations.localeOf(context).languageCode.startsWith('zh')
                          ? '缺少必填字段：${draft.missingRequired.join(', ')}'
                          : 'Missing required fields: ${draft.missingRequired.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ui.PrimaryButton(
                          onPressed: (draft.missingRequired.isEmpty && !isCreating)
                              ? onConfirm
                              : null,
                          child: Text(
                            isCreating
                                ? (Localizations.localeOf(context).languageCode.startsWith('zh')
                                    ? '创建中...'
                                    : 'Creating...')
                                : (Localizations.localeOf(context).languageCode.startsWith('zh')
                                    ? '确认创建'
                                    : 'Confirm Create'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ui.GhostButton(
                        onPressed: isCreating ? null : onDiscard,
                        child: Text(
                          Localizations.localeOf(context).languageCode.startsWith('zh')
                              ? '放弃'
                              : 'Discard',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _typeLabel(BuildContext context, ItemType type) {
    final zh = Localizations.localeOf(context).languageCode.startsWith('zh');
    return switch (type) {
      ItemType.schedule => zh ? '日程' : 'Schedule',
      ItemType.task => zh ? '任务' : 'Task',
      ItemType.memo => zh ? '备忘' : 'Memo',
      ItemType.course => zh ? '课程' : 'Course',
    };
  }
}
