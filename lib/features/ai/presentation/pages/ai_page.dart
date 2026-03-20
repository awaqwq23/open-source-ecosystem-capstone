import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/features/ai/presentation/viewmodels/ai_header_view_model.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AiPage extends ConsumerWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiHeaderViewModelProvider);
    final theme = Theme.of(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(context.l10n.aiTitle),
          trailing: [
            ui.Tooltip(
              tooltip: (context) => Text(context.l10n.headerOpenTimePicker),
              child: ui.IconButton.ghost(
                icon: const Icon(Icons.calendar_month),
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
                              Icons.auto_awesome,
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
                                  context.l10n.aiDescription,
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
                              onPressed: () => context.push(AppRoutePaths.timePicker),
                              child: Text(context.l10n.timePickerTitle),
                            ),
                          ],
                        ),
                      ),
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
