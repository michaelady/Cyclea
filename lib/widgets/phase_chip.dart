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
      CyclePhase.ovulatory => CycleaColors.tide,
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
      visualDensity: VisualDensity.standard,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}
