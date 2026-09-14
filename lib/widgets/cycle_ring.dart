import 'dart:math';

import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';

class CycleRing extends StatelessWidget {
  const CycleRing({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
    required this.phase,
    this.size = 168,
  });

  final int? cycleDay;
  final int cycleLength;
  final CyclePhase phase;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final day = cycleDay;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: day == null ? 0 : (day / cycleLength).clamp(0.0, 1.0),
          track: scheme.outlineVariant.withValues(alpha: 0.45),
          fill: switch (phase) {
            CyclePhase.menstrual => CycleaColors.rose,
            CyclePhase.ovulatory => CycleaColors.sage,
            CyclePhase.luteal => CycleaColors.sand,
            CyclePhase.follicular => scheme.primary,
            CyclePhase.unknown => scheme.outline,
          },
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day == null ? '—' : '$day',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                day == null ? 'log a period' : 'day of ~$cycleLength',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, trackPaint);
    if (progress > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill;
}
