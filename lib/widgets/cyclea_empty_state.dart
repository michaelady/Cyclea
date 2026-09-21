import 'package:cyclea/theme/cyclea_decor.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:flutter/material.dart';

class CycleaEmptyState extends StatelessWidget {
  const CycleaEmptyState({
    super.key,
    required this.glyph,
    required this.title,
    required this.body,
    this.action,
  });

  final CycleaGlyph glyph;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CycleaIcon(
                glyph,
                filled: true,
                size: 28,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          if (action != null) ...[
            const SizedBox(height: 14),
            action!,
          ],
        ],
      ),
    );
  }
}

class IconLabelChip extends StatelessWidget {
  const IconLabelChip({
    super.key,
    required this.glyph,
    required this.label,
    this.color,
  });

  final CycleaGlyph glyph;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? Theme.of(context).colorScheme.primary;
    return Chip(
      avatar: CycleaIcon(glyph, filled: true, size: 16, color: resolved),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
