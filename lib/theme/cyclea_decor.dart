import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';

class PetalWash extends StatelessWidget {
  const PetalWash({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _PetalWashPainter(dark: dark),
      child: child,
    );
  }
}

class _PetalWashPainter extends CustomPainter {
  const _PetalWashPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    void blob(Offset origin, double w, double h, double angle, Color color) {
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Paint()..color = color,
      );
      canvas.restore();
    }

    if (dark) {
      blob(Offset(size.width * 0.08, -20), 260, 170, -0.4, const Color(0x33C98693));
      blob(Offset(size.width * 0.92, 40), 220, 160, 0.5, const Color(0x224F7A68));
      blob(Offset(size.width * 0.7, size.height * 0.92), 280, 180, -0.2, const Color(0x22E6C9A0));
    } else {
      blob(Offset(size.width * 0.02, -10), 280, 180, -0.45, CycleaColors.blush.withValues(alpha: 0.9));
      blob(Offset(size.width * 0.95, 28), 240, 170, 0.55, CycleaColors.sageMist.withValues(alpha: 0.85));
      blob(Offset(size.width * 0.18, size.height * 0.98), 300, 190, 0.2, CycleaColors.honey.withValues(alpha: 0.28));
      blob(Offset(size.width * 0.78, size.height * 0.82), 180, 120, -0.7, CycleaColors.petal.withValues(alpha: 0.28));
    }
  }

  @override
  bool shouldRepaint(covariant _PetalWashPainter oldDelegate) => oldDelegate.dark != dark;
}

class BloomHero extends StatelessWidget {
  const BloomHero({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF2A2224), Color(0xFF231C1B), Color(0xFF1F2421)]
              : const [Color(0xFFFBE7EA), Color(0xFFFFF8F3), Color(0xFFE7F1EB)],
        ),
        border: Border.all(
          color: dark ? const Color(0x33E8B4BC) : CycleaColors.petal.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: CycleaColors.rose.withValues(alpha: dark ? 0.12 : 0.1),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: CustomPaint(
          painter: _HeroPetalsPainter(dark: dark),
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }
}

class _HeroPetalsPainter extends CustomPainter {
  const _HeroPetalsPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final color = (dark ? CycleaColors.roseSoft : CycleaColors.rose).withValues(alpha: dark ? 0.14 : 0.1);
    for (var i = 0; i < 5; i++) {
      final t = i / 5;
      canvas.drawPath(
        botanicalPetal(
          center: Offset(size.width * (0.78 + t * 0.04), size.height * (0.18 + t * 0.12)),
          angle: -0.6 + i * 0.42,
          length: 36 - i * 4,
          width: 16,
        ),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroPetalsPainter oldDelegate) => oldDelegate.dark != dark;
}

class CycleaWordmark extends StatelessWidget {
  const CycleaWordmark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CycleaIcon(
          CycleaGlyph.blossom,
          filled: true,
          size: compact ? 26 : 32,
          color: Theme.of(context).colorScheme.primary,
          semanticLabel: 'Cyclea blossom',
        ),
        const SizedBox(width: 10),
        Text(
          'Cyclea',
          style: compact
              ? Theme.of(context).textTheme.headlineSmall
              : Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF26211F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: dark ? 0.4 : 0.55)),
        boxShadow: [
          BoxShadow(
            color: CycleaColors.rose.withValues(alpha: dark ? 0.08 : 0.07),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
