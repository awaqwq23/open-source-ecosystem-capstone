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
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';
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
  bool _isDraftRouteOpening = false;
  int? _lastHandledDraftNavigationId;

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
    _setupDraftNavigationListener();

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
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _periodLabel(context, state),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  ui.GhostButton(
                    onPressed: () => _openTimePicker(context, state),
                    child: Text(context.l10n.timePickerTitle),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (!state.composerEnabled || state.lastError != null)
              _ErrorBanner(
                message: state.composerDisabledReason ??
                    state.lastError ??
                    _text(context, zh: 'AI 服务异常', en: 'AI service error'),
                onOpenSettings: () => context.go(AppRoutePaths.settingsAi),
                onRetry: ref.read(aiHeaderViewModelProvider.notifier).retryEnableComposer,
              ),
            Expanded(
              child: _ConversationTimeline(
                groups: groups,
                pendingDraft: state.pendingDraft,
                onOpenDraft: ref.read(aiHeaderViewModelProvider.notifier).requestOpenDraftEditor,
              ),
            ),
            const Divider(height: 1),
            _ComposerBar(
              controller: _controller,
              focusNode: _inputFocusNode,
              canSend: state.canSend,
              isBusy: state.isBusy,
              isVoiceSupported: _isVoiceSupported,
              isListening: _isListening,
              onChanged: ref.read(aiHeaderViewModelProvider.notifier).updateInput,
              onSend: ref.read(aiHeaderViewModelProvider.notifier).sendMessage,
              onLongPressStart: () => _startVoice(Localizations.localeOf(context).toLanguageTag()),
              onLongPressEnd: _stopVoice,
            ),
          ],
        ),
      ),
    );
  }

  void _setupDraftNavigationListener() {
    ref.listen<AiHeaderState>(aiHeaderViewModelProvider, (previous, next) {
      final navId = next.pendingDraftNavigationId;
      if (navId == null ||
          _isDraftRouteOpening ||
          _lastHandledDraftNavigationId == navId ||
          next.pendingDraft == null) {
        return;
      }
      _lastHandledDraftNavigationId = navId;
      _openDraftEditor(next.pendingDraft!);
    });
  }

  Future<void> _openDraftEditor(AiCreateItemDraft draft) async {
    if (!mounted) {
      return;
    }
    _isDraftRouteOpening = true;
    final notifier = ref.read(aiHeaderViewModelProvider.notifier);
    notifier.consumeDraftNavigationRequest();
    final result = await context.openItemEditorFlow<bool>(
      extra: ItemEditorArgs(
        prefill: _draftToPrefill(draft),
      ),
    );
    if (!mounted) {
      return;
    }
    await notifier.onDraftEditorClosed(created: result == true);
    _isDraftRouteOpening = false;
  }

  ItemEditorPrefill _draftToPrefill(AiCreateItemDraft draft) {
    final itemDraft = draft.draft;
    return ItemEditorPrefill(
      type: itemDraft.type,
      title: itemDraft.title,
      details: itemDraft.details,
      location: itemDraft.location,
      color: itemDraft.color,
      isAllDay: itemDraft.isAllDay,
      reminder: itemDraft.reminder,
      repeatRule: itemDraft.repeatRule,
      startAt: itemDraft.startAt,
      endAt: itemDraft.endAt,
      deadline: itemDraft.deadline,
      targetDate: itemDraft.targetDate,
      estimatedDuration: itemDraft.estimatedDuration,
      isImportant: draft.isImportant,
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

  static String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh') ? zh : en;
  }
}

class _ConversationTimeline extends StatelessWidget {
  const _ConversationTimeline({
    required this.groups,
    required this.pendingDraft,
    required this.onOpenDraft,
  });

  final List<AiConversationGroup> groups;
  final AiCreateItemDraft? pendingDraft;
  final VoidCallback onOpenDraft;

  @override
  Widget build(BuildContext context) {
    final hasHistory = groups.isNotEmpty && groups.any((group) => group.messages.isNotEmpty);
    if (!hasHistory && pendingDraft == null) {
      return Center(
        child: Text(
          context.l10n.aiEmptyState,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              group.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          for (final message in group.messages)
            _MessageLine(message: message),
        ],
        if (pendingDraft != null)
          _DraftEntryLine(
            pendingDraft: pendingDraft!,
            onOpenDraft: onOpenDraft,
          ),
      ],
    );
  }
}

class _MessageLine extends StatefulWidget {
  const _MessageLine({
    required this.message,
  });

  final AiChatMessage message;

  @override
  State<_MessageLine> createState() => _MessageLineState();
}

class _MessageLineState extends State<_MessageLine> {
  var _showCitations = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == AiChatRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.5,
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
        );

    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(widget.message.content, style: style),
              if (widget.message.citations.isNotEmpty) ...[
                const SizedBox(height: 4),
                ui.GhostButton(
                  onPressed: () {
                    setState(() {
                      _showCitations = !_showCitations;
                    });
                  },
                  child: Text(
                    _showCitations
                        ? _text(context, zh: '收起引用', en: 'Hide references')
                        : _text(
                            context,
                            zh: '引用了 ${widget.message.citations.length} 条事项',
                            en: '${widget.message.citations.length} references',
                          ),
                  ),
                ),
                if (_showCitations)
                  for (final citation in widget.message.citations)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '· ${citation.title}${citation.reason == null || citation.reason!.trim().isEmpty ? '' : '  ${citation.reason!.trim()}'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh') ? zh : en;
  }
}

class _DraftEntryLine extends StatelessWidget {
  const _DraftEntryLine({
    required this.pendingDraft,
    required this.onOpenDraft,
  });

  final AiCreateItemDraft pendingDraft;
  final VoidCallback onOpenDraft;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final draft = pendingDraft.draft;
    final title = draft.title.trim().isEmpty
        ? _text(context, zh: '未命名事项', en: 'Untitled item')
        : draft.title.trim();
    final timeLabel = draft.type.name == 'memo'
        ? DateFormat.yMd(locale).format(draft.targetDate)
        : '${DateFormat.yMd(locale).format(draft.startAt)} ${DateFormat.Hm(locale).format(draft.startAt)}';

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _text(context, zh: '草稿已生成：$title', en: 'Draft ready: $title'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              timeLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            ui.GhostButton(
              onPressed: onOpenDraft,
              child: Text(_text(context, zh: '打开草稿二级页', en: 'Open Draft Page')),
            ),
          ],
        ),
      ),
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh') ? zh : en;
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.isBusy,
    required this.isVoiceSupported,
    required this.isListening,
    required this.onChanged,
    required this.onSend,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final bool isBusy;
  final bool isVoiceSupported;
  final bool isListening;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: context.l10n.aiInputHint,
                border: const UnderlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPressStart: (_) => onLongPressStart(),
            onLongPressEnd: (_) => onLongPressEnd(),
            child: ui.IconButton.ghost(
              icon: Icon(
                Icons.mic_none,
                color: isListening ? Colors.red : null,
              ),
              onPressed: isVoiceSupported ? () {} : null,
            ),
          ),
          ui.PrimaryButton(
            onPressed: canSend ? onSend : null,
            child: Text(
              isBusy
                  ? _text(context, zh: '发送中', en: 'Sending')
                  : _text(context, zh: '发送', en: 'Send'),
            ),
          ),
        ],
      ),
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh') ? zh : en;
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onOpenSettings,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.55),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          ui.GhostButton(
            onPressed: onOpenSettings,
            child: Text(_text(context, zh: 'AI 设置', en: 'AI Settings')),
          ),
          ui.GhostButton(
            onPressed: onRetry,
            child: Text(_text(context, zh: '重试', en: 'Retry')),
          ),
        ],
      ),
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh') ? zh : en;
  }
}
