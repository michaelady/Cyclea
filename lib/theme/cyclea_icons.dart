import 'dart:math';

import 'package:flutter/material.dart';

/// Botanical glyph set used across nav, empty states, legends, and chips.
enum CycleaGlyph {
  blossom,
  calendarBloom,
  sprout,
  moon,
  heartLeaf,
  petal,
  bud,
  drop,
  seed,
  sun,
  cloudLeaf,
  guest,
  spark,
  leaf,
}

class CycleaIcon extends StatelessWidget {
  const CycleaIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    this.color,
    this.filled = false,
    this.semanticLabel,
  });

  final CycleaGlyph glyph;
  final double size;
  final Color? color;
  final bool filled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _GlyphPainter(glyph: glyph, color: resolved, filled: filled),
          ),
        ),
      ),
    );
  }
}

class GoogleGMark extends StatelessWidget {
  const GoogleGMark({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

Path botanicalPetal({
  required Offset center,
  required double angle,
  required double length,
  required double width,
}) {
  final path = Path()
    ..moveTo(0, -length)
    ..cubicTo(width, -length * 0.42, width, length * 0.12, 0, length * 0.38)
    ..cubicTo(-width, length * 0.12, -width, -length * 0.42, 0, -length)
    ..close();
  final matrix = Matrix4.identity()
    ..translateByDouble(center.dx, center.dy, 0, 1)
    ..rotateZ(angle);
  return path.transform(matrix.storage);
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.glyph,
    required this.color,
    required this.filled,
  });

  final CycleaGlyph glyph;
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas
      ..save()
      ..scale(scale, scale);
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = filled ? 1.35 : 1.55
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final paint = filled ? fill : stroke;
    switch (glyph) {
      case CycleaGlyph.blossom:
        _blossom(canvas, fill, stroke);
      case CycleaGlyph.calendarBloom:
        _calendar(canvas, fill, stroke);
      case CycleaGlyph.sprout:
        _sprout(canvas, fill, stroke);
      case CycleaGlyph.moon:
        _moon(canvas, fill, stroke);
      case CycleaGlyph.heartLeaf:
        _heartLeaf(canvas, paint, stroke);
      case CycleaGlyph.petal:
        _singlePetal(canvas, paint);
      case CycleaGlyph.bud:
        _bud(canvas, fill, stroke);
      case CycleaGlyph.drop:
        _drop(canvas, paint);
      case CycleaGlyph.seed:
        _seed(canvas, paint, stroke);
      case CycleaGlyph.sun:
        _sun(canvas, fill, stroke);
      case CycleaGlyph.cloudLeaf:
        _cloudLeaf(canvas, fill, stroke);
      case CycleaGlyph.guest:
        _guest(canvas, fill, stroke);
      case CycleaGlyph.spark:
        _spark(canvas, fill, stroke);
      case CycleaGlyph.leaf:
        _leaf(canvas, paint, stroke);
    }
    canvas.restore();
  }

  void _blossom(Canvas canvas, Paint fill, Paint stroke) {
    const origin = Offset(12, 13.2);
    final bloom = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * 2 * pi / 5;
      bloom.addPath(
        botanicalPetal(center: origin, angle: angle, length: 6.6, width: 3.35),
        Offset.zero,
      );
    }
    canvas.drawPath(bloom, filled ? fill : stroke);
    canvas.drawCircle(origin, filled ? 2.15 : 1.85, filled ? fill : stroke);
    if (filled) {
      canvas.drawCircle(origin, 0.85, Paint()..color = Color.lerp(color, Colors.white, 0.55)!);
    }
  }

  void _calendar(Canvas canvas, Paint fill, Paint stroke) {
    final body = RRect.fromLTRBR(4.2, 6.2, 19.8, 20.6, const Radius.circular(3.6));
    canvas.drawRRect(body, filled ? fill : stroke);
    final ringPaint = filled
        ? (Paint()
            ..color = Color.lerp(color, Colors.white, 0.88)!
            ..style = PaintingStyle.fill)
        : stroke;
    canvas.drawLine(const Offset(8, 3.6), const Offset(8, 8.2), stroke);
    canvas.drawLine(const Offset(16, 3.6), const Offset(16, 8.2), stroke);
    if (filled) {
      canvas.drawRRect(
        RRect.fromLTRBR(5.6, 8.6, 18.4, 11.2, const Radius.circular(1.2)),
        Paint()..color = Color.lerp(color, Colors.white, 0.82)!,
      );
    } else {
      canvas.drawLine(const Offset(6.4, 10.2), const Offset(17.6, 10.2), stroke);
    }
    const origin = Offset(12.2, 15.6);
    final bloom = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * 2 * pi / 5;
      bloom.addPath(
        botanicalPetal(center: origin, angle: angle, length: 3.1, width: 1.55),
        Offset.zero,
      );
    }
    canvas.drawPath(bloom, ringPaint);
  }

  void _sprout(Canvas canvas, Paint fill, Paint stroke) {
    final stem = Path()
      ..moveTo(12, 20.6)
      ..quadraticBezierTo(11.2, 14.5, 12.4, 8.2);
    canvas.drawPath(stem, stroke);
    final left = botanicalPetal(center: const Offset(8.6, 13.2), angle: -2.15, length: 5.2, width: 2.6);
    final right = botanicalPetal(center: const Offset(15.6, 12.4), angle: 2.05, length: 5.4, width: 2.7);
    canvas.drawPath(left, filled ? fill : stroke);
    canvas.drawPath(right, filled ? fill : stroke);
    canvas.drawCircle(const Offset(12.6, 7.1), 1.7, filled ? fill : stroke);
  }

  void _moon(Canvas canvas, Paint fill, Paint stroke) {
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 7.2)),
      Path()..addOval(Rect.fromCircle(center: const Offset(15.6, 9.8), radius: 5.6)),
    );
    canvas.drawPath(crescent, filled ? fill : stroke);
  }

  void _heartLeaf(Canvas canvas, Paint paint, Paint stroke) {
    final heart = Path()
      ..moveTo(12, 20.2)
      ..cubicTo(4.2, 15.2, 3.4, 8.4, 8.4, 6.2)
      ..cubicTo(10.4, 5.3, 11.6, 6.4, 12, 7.6)
      ..cubicTo(12.4, 6.4, 13.6, 5.3, 15.6, 6.2)
      ..cubicTo(20.6, 8.4, 19.8, 15.2, 12, 20.2)
      ..close();
    canvas.drawPath(heart, filled ? paint : stroke);
    canvas.drawLine(const Offset(12, 9.2), const Offset(12, 18.4), stroke);
  }

  void _singlePetal(Canvas canvas, Paint paint) {
    canvas.drawPath(
      botanicalPetal(center: const Offset(12, 13.4), angle: -0.35, length: 8.4, width: 4.4),
      paint,
    );
  }

  void _bud(Canvas canvas, Paint fill, Paint stroke) {
    final cup = Path()
      ..moveTo(12, 5.4)
      ..cubicTo(7.2, 8.8, 6.4, 14.8, 12, 19.4)
      ..cubicTo(17.6, 14.8, 16.8, 8.8, 12, 5.4)
      ..close();
    canvas.drawPath(cup, filled ? fill : stroke);
    canvas.drawLine(const Offset(12, 8.2), const Offset(12, 16.8), stroke);
    canvas.drawLine(const Offset(12, 20.2), const Offset(12, 22.2), stroke);
  }

  void _drop(Canvas canvas, Paint paint) {
    final drop = Path()
      ..moveTo(12, 4.6)
      ..cubicTo(12.4, 8.8, 18.2, 12.8, 18.2, 16.4)
      ..cubicTo(18.2, 20.4, 15.4, 22.4, 12, 22.4)
      ..cubicTo(8.6, 22.4, 5.8, 20.4, 5.8, 16.4)
      ..cubicTo(5.8, 12.8, 11.6, 8.8, 12, 4.6)
      ..close();
    canvas.drawPath(drop, paint);
  }

  void _seed(Canvas canvas, Paint paint, Paint stroke) {
    canvas.save();
    canvas.translate(12, 12);
    canvas.rotate(-0.5);
    canvas.drawOval(const Rect.fromLTWH(-4.2, -7.4, 8.4, 14.8), paint);
    canvas.restore();
    canvas.drawLine(const Offset(10.4, 8.2), const Offset(14.2, 16.6), stroke);
  }

  void _sun(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawCircle(const Offset(12, 12), 4.4, filled ? fill : stroke);
    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + i * pi / 4;
      canvas.drawPath(
        botanicalPetal(center: Offset(12 + 7.2 * cos(angle), 12 + 7.2 * sin(angle)), angle: angle, length: 2.8, width: 1.35),
        filled ? fill : stroke,
      );
    }
  }

  void _cloudLeaf(Canvas canvas, Paint fill, Paint stroke) {
    final cloud = Path()
      ..moveTo(6.4, 16.6)
      ..cubicTo(3.2, 16.4, 3.4, 11.6, 7.2, 11.4)
      ..cubicTo(7.8, 8.2, 12.4, 7.6, 13.8, 10.4)
      ..cubicTo(17.8, 9.4, 20.6, 13.2, 18.2, 16.4)
      ..close();
    canvas.drawPath(cloud, filled ? fill : stroke);
    canvas.drawPath(
      botanicalPetal(center: const Offset(16.8, 18.8), angle: 0.7, length: 3.4, width: 1.7),
      filled ? fill : stroke,
    );
  }

  void _guest(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawCircle(const Offset(12, 8.2), 3.4, filled ? fill : stroke);
    final cloak = Path()
      ..moveTo(5.6, 20.6)
      ..quadraticBezierTo(6.4, 13.6, 12, 13.2)
      ..quadraticBezierTo(17.6, 13.6, 18.4, 20.6)
      ..close();
    canvas.drawPath(cloak, filled ? fill : stroke);
    canvas.drawPath(
      botanicalPetal(center: const Offset(18.4, 7.2), angle: 0.5, length: 3.2, width: 1.5),
      filled ? fill : stroke,
    );
  }

  void _spark(Canvas canvas, Paint fill, Paint stroke) {
    canvas.drawPath(
      botanicalPetal(center: const Offset(12, 11.2), angle: -0.2, length: 6.8, width: 3.1),
      filled ? fill : stroke,
    );
    canvas.drawCircle(const Offset(6.4, 17.4), 1.5, filled ? fill : stroke);
    canvas.drawCircle(const Offset(17.8, 16.8), 1.15, filled ? fill : stroke);
  }

  void _leaf(Canvas canvas, Paint paint, Paint stroke) {
    canvas.drawPath(
      botanicalPetal(center: const Offset(12, 13), angle: -0.55, length: 8.6, width: 4.6),
      paint,
    );
    canvas.drawLine(const Offset(9.4, 16.8), const Offset(14.8, 8.6), stroke);
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter oldDelegate) =>
      oldDelegate.glyph != glyph || oldDelegate.color != color || oldDelegate.filled != filled;
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.scale(s / 18, s / 18);
    const c = Offset(9, 9);
    const radius = 7.0;
    const stroke = 2.35;
    final rect = Rect.fromCircle(center: c, radius: radius);
    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt
          ..isAntiAlias = true,
      );
    }

    arc(_red, -pi * 0.92, pi * 0.62);
    arc(_yellow, pi * 0.72, pi * 0.42);
    arc(_green, pi * 0.22, pi * 0.5);
    arc(_blue, -pi * 0.28, pi * 0.5);
    canvas.drawLine(
      const Offset(9, 9),
      const Offset(16.1, 9),
      Paint()
        ..color = _blue
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

CycleaGlyph glyphForSymptom(String id) {
  return switch (id) {
    'cramps' || 'pelvic_pain' || 'back_pain' || 'joint_pain' => CycleaGlyph.drop,
    'fatigue' || 'sleep_issues' || 'low_mood' || 'brain_fog' => CycleaGlyph.moon,
    'high_energy' || 'acne' => CycleaGlyph.sun,
    'calm' => CycleaGlyph.heartLeaf,
    'cravings' || 'appetite_up' || 'appetite_down' => CycleaGlyph.seed,
    'mood_swings' || 'anxiety' || 'irritability' || 'tearful' => CycleaGlyph.petal,
    'nausea' || 'digestive' || 'bloating' => CycleaGlyph.leaf,
    'headache' || 'dizziness' => CycleaGlyph.spark,
    _ => CycleaGlyph.blossom,
  };
}

CycleaGlyph glyphForAdviceTag(String tag) {
  final key = tag.toLowerCase();
  if (key.contains('important')) return CycleaGlyph.drop;
  if (key.contains('phase')) return CycleaGlyph.moon;
  if (key.contains('stat') || key.contains('pattern')) return CycleaGlyph.sprout;
  if (key.contains('start')) return CycleaGlyph.bud;
  return CycleaGlyph.petal;
}
