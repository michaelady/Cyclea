import 'package:cyclea/domain/advice.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:flutter/material.dart';

class AdviceCardView extends StatelessWidget {
  const AdviceCardView({super.key, required this.card});

  final AdviceCard card;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final glyph = glyphForAdviceTag(card.tag);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CycleaIcon(glyph, filled: true, size: 18, color: scheme.secondary),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    card.tag.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.secondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(card.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(card.body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
