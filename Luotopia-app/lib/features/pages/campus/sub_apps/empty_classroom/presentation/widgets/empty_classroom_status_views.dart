import 'package:flutter/material.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class EmptyClassroomLoginRequiredView extends StatelessWidget {
  const EmptyClassroomLoginRequiredView({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.emptyClassroomLoginPrompt,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ui.PrimaryButton(
              onPressed: onLogin,
              child: Text(l10n.emptyClassroomGoLogin),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyClassroomInitialErrorView extends StatelessWidget {
  const EmptyClassroomInitialErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: colors.onSurfaceVariant)),
            const SizedBox(height: 16),
            ui.PrimaryButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

class EmptyClassroomQueryErrorCard extends StatelessWidget {
  const EmptyClassroomQueryErrorCard({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return ui.Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 36, color: colors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ui.OutlineButton(
            onPressed: onRetry,
            child: Text(l10n.emptyClassroomRetry),
          ),
        ],
      ),
    );
  }
}

class EmptyClassroomEmptyCard extends StatelessWidget {
  const EmptyClassroomEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return ui.Card(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 48,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emptyClassroomNoResults,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class EmptyClassroomQueryHint extends StatelessWidget {
  const EmptyClassroomQueryHint({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return ui.Card(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 48,
            color: colors.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emptyClassroomQueryHint,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
