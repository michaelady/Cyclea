import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';

class PhaseChip extends StatelessWidget {
  const PhaseChip({super.key, required this.phase});

  final CyclePhase phase;

  @override
  Widget build(BuildContext context) {
    final color = switch (phase) {
      CyclePhase.menstrual => CycleaColors.rose,
      CyclePhase.follicular => Theme.of(context).colorScheme.primary,
      CyclePhase.ovulatory => CycleaColors.sage,
      CyclePhase.luteal => CycleaColors.sand,
      CyclePhase.unknown => Theme.of(context).colorScheme.outline,
    };
    final glyph = switch (phase) {
      CyclePhase.menstrual => CycleaGlyph.drop,
      CyclePhase.follicular => CycleaGlyph.sprout,
      CyclePhase.ovulatory => CycleaGlyph.blossom,
      CyclePhase.luteal => CycleaGlyph.moon,
      CyclePhase.unknown => CycleaGlyph.bud,
    };
    return Chip(
      avatar: CycleaIcon(glyph, filled: true, size: 16, color: color),
      label: Text(phase.label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendMark(glyph: CycleaGlyph.drop, color: CycleaColors.rose, label: 'Logged period'),
        _LegendMark(glyph: CycleaGlyph.sprout, color: CycleaColors.sage, label: 'Fertile estimate'),
        _LegendMark(glyph: CycleaGlyph.moon, color: CycleaColors.sand, label: 'Predicted period'),
      ],
    );
  }
}

class _LegendMark extends StatelessWidget {
  const _LegendMark({
    required this.glyph,
    required this.color,
    required this.label,
  });

  final CycleaGlyph glyph;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CycleaIcon(glyph, filled: true, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
