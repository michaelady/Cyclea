import 'package:cyclea/domain/cycle_phase.dart';
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
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
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
        _LegendDot(color: CycleaColors.rose, label: 'Logged period'),
        _LegendDot(color: CycleaColors.sage, label: 'Fertile estimate'),
        _LegendDot(color: CycleaColors.sand, label: 'Predicted period'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
