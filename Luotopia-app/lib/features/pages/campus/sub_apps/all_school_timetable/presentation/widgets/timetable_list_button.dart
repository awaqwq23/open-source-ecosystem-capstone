import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class TimetableListButton extends StatelessWidget {
  const TimetableListButton({
    required this.title,
    required this.onPressed,
    this.meta,
    this.detail,
    this.trailingLabel,
    super.key,
  });

  final String title;
  final String? meta;
  final String? detail;
  final String? trailingLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ui.CardButton(
        alignment: Alignment.centerLeft,
        onPressed: onPressed,
        trailing: const Icon(Icons.chevron_right),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (trailingLabel != null && trailingLabel!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      trailingLabel!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              if (meta != null && meta!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  meta!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (detail != null && detail!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  detail!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
