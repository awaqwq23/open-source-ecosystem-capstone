import 'package:flutter/widgets.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class OptionCard<T> extends StatelessWidget {
  const OptionCard({
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    this.onChanged,
    super.key,
  });

  final T value;
  final T groupValue;
  final String title;
  final String? subtitle;
  final ValueChanged<T>? onChanged;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final cs = ui.Theme.of(context).colorScheme;
    final typography = ui.Theme.of(context).typography;

    return ui.Clickable(
      onPressed: () => onChanged?.call(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color:
              _selected ? cs.primary.withValues(alpha: 0.10) : cs.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                _selected ? cs.primary.withValues(alpha: 0.40) : cs.border,
            width: _selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: typography.sans.copyWith(
                      color: cs.cardForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: typography.sans.copyWith(
                        color: cs.mutedForeground,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              _selected ? AppIcons.selected : AppIcons.drillIn,
              size: 22,
              color: _selected ? cs.primary : cs.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
