import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.glyph,
  });

  final String label;
  final String value;
  final String? caption;
  final CycleaGlyph? glyph;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (glyph != null) ...[
                    CycleaIcon(glyph!, filled: true, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                  ],
                  Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(caption!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FrequencyBar extends StatelessWidget {
  const FrequencyBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.glyph,
  });

  final String label;
  final double value;
  final Color color;
  final CycleaGlyph? glyph;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (glyph != null) ...[
                CycleaIcon(glyph!, filled: true, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
              Text('${pct.round()}%', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
