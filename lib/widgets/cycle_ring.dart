import 'dart:math';

import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';

class CycleRing extends StatelessWidget {
  const CycleRing({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
    required this.phase,
    this.size = 176,
  });

  final int? cycleDay;
  final int cycleLength;
  final CyclePhase phase;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final day = cycleDay;
    final fill = switch (phase) {
      CyclePhase.menstrual => CycleaColors.rose,
      CyclePhase.ovulatory => CycleaColors.sage,
      CyclePhase.luteal => CycleaColors.sand,
      CyclePhase.follicular => scheme.primary,
      CyclePhase.unknown => scheme.outline,
    };
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BloomRingPainter(
          progress: day == null ? 0 : (day / cycleLength).clamp(0.0, 1.0),
          track: scheme.outlineVariant.withValues(alpha: 0.45),
          fill: fill,
          wash: fill.withValues(alpha: 0.12),
        ),
        child: Center(
          child: day == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CycleaIcon(CycleaGlyph.bud, filled: true, size: 28, color: fill),
                    const SizedBox(height: 4),
                    Text(
                      'awaiting\na start',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$day', style: Theme.of(context).textTheme.displaySmall),
                    Text(
                      'day of ~$cycleLength',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BloomRingPainter extends CustomPainter {
  const _BloomRingPainter({
    required this.progress,
    required this.track,
    required this.fill,
    required this.wash,
  });

  final double progress;
  final Color track;
  final Color fill;
  final Color wash;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = min(size.width, size.height) / 2 - 6;
    const petalCount = 14;
    canvas.drawCircle(center, outer * 0.52, Paint()..color = wash);

    for (var i = 0; i < petalCount; i++) {
      final start = i / petalCount;
      final lit = progress > start;
      final angle = -pi / 2 + (2 * pi * i / petalCount);
      final petal = botanicalPetal(
        center: Offset(
          center.dx + outer * 0.62 * cos(angle),
          center.dy + outer * 0.62 * sin(angle),
        ),
        angle: angle,
        length: outer * 0.28,
        width: outer * 0.13,
      );
      canvas.drawPath(
        petal,
        Paint()
          ..color = lit ? fill : track
          ..style = lit ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BloomRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill ||
      oldDelegate.wash != wash;
}
