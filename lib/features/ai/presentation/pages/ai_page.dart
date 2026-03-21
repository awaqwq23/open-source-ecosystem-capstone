import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/ai/presentation/viewmodels/ai_header_view_model.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AiPage extends ConsumerStatefulWidget {
  const AiPage({super.key});

  @override
  ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiHeaderViewModelProvider);
    final groups = ref.watch(aiConversationGroupsProvider);
    final theme = Theme.of(context);
    _syncController(state.input);

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AppEntrance(
              child: ui.Card(
                child: AppSwitchingContent(
                  contentKey: state.period,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              AppIcons.aiFilled,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.aiTitle,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '按 ${_periodLabel(context, state)} 聚合聊天记录。当前分组 ${groups.length} 个。',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AppEntrance(
                        delay: AppMotion.fast,
                        offset: AppMotion.sectionOffset,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ui.PrimaryButton(
                              onPressed: () => _showPeriodPicker(context, ref),
                              child: Text(_periodLabel(context, state)),
                            ),
                            ui.GhostButton(
                              onPressed: () async {
                                final result = await context.push<TimePickerSelection>(
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
                                  ref
                                      .read(aiHeaderViewModelProvider.notifier)
                                      .selectAnchor(result.anchor);
                                }
                              },
                              child: Text(context.l10n.timePickerTitle),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ConversationList(groups: groups),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _controller,
                        onChanged: ref.read(aiHeaderViewModelProvider.notifier).updateInput,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: '输入一句话，让 AI 帮你创建事项或查询日程',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ui.PrimaryButton(
                              onPressed: state.isSending
                                  ? null
                                  : () => ref
                                      .read(aiHeaderViewModelProvider.notifier)
                                      .sendMessage(),
                              child: Text(state.isSending ? '发送中...' : '发送'),
                            ),
                          ),
                        ],
                      ),
                      if (state.lastError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.lastError!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
        return AppSheetEntrance(
          child: Padding(
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
          ),
        );
      },
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.groups,
  });

  final List<AiConversationGroup> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty || groups.every((group) => group.messages.isEmpty)) {
      return const Text('当前时间范围内还没有聊天记录。');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Text(
            group.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final message in group.messages)
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
        ],
      ],
    );
  }
}
