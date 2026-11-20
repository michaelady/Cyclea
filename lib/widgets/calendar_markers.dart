import 'dart:math' as math;

import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';

/// Shared drawing for calendar days and the legend.
///
/// Logged days are a solid magenta fill. Predicted days reuse that shape in
/// pink stripes. Fertile days are a teal run. Ovulation adds a flower.
/// Today is a neutral ring and a bold date, not another phase color.
class CalendarDayMarker extends StatelessWidget {
  const CalendarDayMarker({
    super.key,
    required this.day,
    this.logged = false,
    this.predicted = false,
    this.fertile = false,
    this.ovulation = false,
    this.band = false,
    this.today = false,
    this.selected = false,
    this.joinLeft = false,
    this.joinRight = false,
    this.symptomDots = 0,
    this.showNumber = true,
    this.size = 36,
  });

  final int day;
  final bool logged;
  final bool predicted;
  final bool fertile;
  final bool ovulation;
  final bool band;
  final bool today;
  final bool selected;
  final bool joinLeft;
  final bool joinRight;
  final int symptomDots;
  final bool showNumber;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final numberColor = logged
        ? Colors.white
        : dark
        ? CycleaColors.darkHeroText
        : CycleaColors.ink;
    return SizedBox(
      width: showNumber ? null : size,
      height: size,
      child: CustomPaint(
        painter: _DayMarkPainter(
          logged: logged,
          predicted: predicted,
          fertile: fertile,
          ovulation: ovulation,
          band: band,
          today: today,
          selected: selected,
          joinLeft: joinLeft,
          joinRight: joinRight,
          symptomDots: symptomDots,
          dark: dark,
        ),
        child: showNumber
            ? Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: today ? 15 : 13.5,
                    height: 1,
                    fontWeight: today || logged
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: numberColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _DayMarkPainter extends CustomPainter {
  const _DayMarkPainter({
    required this.logged,
    required this.predicted,
    required this.fertile,
    required this.ovulation,
    required this.band,
    required this.today,
    required this.selected,
    required this.joinLeft,
    required this.joinRight,
    required this.symptomDots,
    required this.dark,
  });

  final bool logged;
  final bool predicted;
  final bool fertile;
  final bool ovulation;
  final bool band;
  final bool today;
  final bool selected;
  final bool joinLeft;
  final bool joinRight;
  final int symptomDots;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = math.min(size.height - 6, 32.0);
    final top = (size.height - barHeight) / 2 - (symptomDots > 0 ? 2 : 0);
    final rect = Rect.fromLTWH(0, top, size.width, barHeight);
    final radius = barHeight / 2;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(joinLeft ? 0 : radius),
      bottomLeft: Radius.circular(joinLeft ? 0 : radius),
      topRight: Radius.circular(joinRight ? 0 : radius),
      bottomRight: Radius.circular(joinRight ? 0 : radius),
    );
    final period = dark ? const Color(0xFFE56A98) : CycleaColors.period;
    final predict = dark ? const Color(0xFF6A3A4C) : CycleaColors.periodSoft;
    final stripe = dark ? const Color(0xFFF0A0BC) : CycleaColors.periodStripe;
    final tide = dark ? const Color(0xFF7EC8D4) : CycleaColors.tide;
    final tideFill = dark ? const Color(0xFF1C4A54) : CycleaColors.tideSoft;

    if (logged) {
      canvas.drawRRect(rrect, Paint()..color = period);
    } else if (predicted) {
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(rect, Paint()..color = predict);
      _stripes(canvas, rect, stripe);
      canvas.restore();
    } else if (fertile || ovulation) {
      canvas.drawRRect(rrect, Paint()..color = tideFill);
    } else if (band) {
      _dots(
        canvas,
        Offset(size.width / 2, size.height - 5),
        stripe.withValues(alpha: 0.85),
      );
    }

    if (ovulation && !logged) {
      _flower(
        canvas,
        size.center(Offset.zero).translate(0, -1),
        barHeight * 0.22,
        tide,
      );
    }

    if (today) {
      final ring = RRect.fromRectAndRadius(
        rect.deflate(1.2),
        Radius.circular(joinLeft || joinRight ? 8 : radius),
      );
      canvas.drawRRect(
        ring,
        Paint()
          ..color = dark ? CycleaColors.darkHeroText : CycleaColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.4 : 1.8,
      );
    } else if (selected && !logged) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = (dark ? CycleaColors.darkHeroText : CycleaColors.ink)
              .withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    if (symptomDots > 0) {
      final count = math.min(symptomDots, 3);
      final dot = dark ? CycleaColors.honey : CycleaColors.tideDeep;
      final total = count * 5 + (count - 1) * 2;
      var x = (size.width - total) / 2;
      final y = size.height - 4;
      for (var i = 0; i < count; i++) {
        canvas.drawCircle(Offset(x + 2.5, y), 2.1, Paint()..color = dot);
        x += 7;
      }
    }
  }

  void _stripes(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const gap = 6.0;
    for (var x = rect.left - rect.height; x < rect.right; x += gap) {
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(x + rect.height, rect.top),
        paint,
      );
    }
  }

  void _dots(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;
    for (final dx in const [-6.0, 0.0, 6.0]) {
      canvas.drawCircle(center.translate(dx, 0), 1.7, paint);
    }
  }

  void _flower(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()..color = color;
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        radius * 0.55,
        paint,
      );
    }
    canvas.drawCircle(center, radius * 0.38, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _DayMarkPainter oldDelegate) =>
      oldDelegate.logged != logged ||
      oldDelegate.predicted != predicted ||
      oldDelegate.fertile != fertile ||
      oldDelegate.ovulation != ovulation ||
      oldDelegate.band != band ||
      oldDelegate.today != today ||
      oldDelegate.selected != selected ||
      oldDelegate.joinLeft != joinLeft ||
      oldDelegate.joinRight != joinRight ||
      oldDelegate.symptomDots != symptomDots ||
      oldDelegate.dark != dark;
}

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendItem(logged: true, label: 'Logged period'),
        _LegendItem(predicted: true, label: 'Predicted period'),
        _LegendItem(fertile: true, label: 'Fertile window'),
        _LegendItem(ovulation: true, fertile: true, label: 'Ovulation'),
        _LegendItem(today: true, label: 'Today'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    this.logged = false,
    this.predicted = false,
    this.fertile = false,
    this.ovulation = false,
    this.today = false,
  });

  final String label;
  final bool logged;
  final bool predicted;
  final bool fertile;
  final bool ovulation;
  final bool today;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarDayMarker(
          day: 0,
          showNumber: false,
          size: 22,
          logged: logged,
          predicted: predicted,
          fertile: fertile,
          ovulation: ovulation,
          today: today,
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
