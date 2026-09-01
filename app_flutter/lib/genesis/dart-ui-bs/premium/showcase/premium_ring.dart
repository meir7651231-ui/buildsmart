// ✨ PremiumRing — טבעת-התקדמות מעגלית: value(0..1) + label? + caption? + size. קשת-SweepGradient
// עם קצה-מעוגל וזוהר · מסילת-רקע · count-up במרכז (%). a11y: Semantics(value) · reduced-motion.
// חוט-טהור: material + dart:math בלבד · פיגמנט const · טקסט דרך פרמטר · RTL.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class PremiumRing extends StatefulWidget {
  const PremiumRing({
    required this.value,
    this.label,
    this.caption,
    this.size = 132,
    super.key,
  });

  final double value; // 0..1
  final String? label; // עוקף את אחוז-ברירת-המחדל
  final String? caption;
  final double size;

  static const _track = Color(0xFF1A1B23);
  static const _arcA = Color(0xFF39D6F0);
  static const _arcB = Color(0xFF7A6BFF);
  static const _arcC = Color(0xFFC66BFF);
  static const _glow = Color(0xFF6C5CE7);
  static const _ink = Color(0xFFF4F5F7);
  static const _muted = Color(0xFF9AA0AC);

  @override
  State<PremiumRing> createState() => _PremiumRingState();
}

class _PremiumRingState extends State<PremiumRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final v = widget.value.clamp(0.0, 1.0);
    return Semantics(
      label: widget.caption,
      value: '${(v * 100).round()}%',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = reduce ? 1.0 : Curves.easeOutCubic.transform(_c.value);
            final shown = v * t;
            return CustomPaint(
              painter: _RingPainter(shown),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label ?? '${(shown * 100).round()}%',
                      style: TextStyle(
                        color: PremiumRing._ink,
                        fontSize: widget.size * 0.24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    if (widget.caption != null) ...[
                      SizedBox(height: widget.size * 0.04),
                      Text(
                        widget.caption!,
                        style: const TextStyle(
                            color: PremiumRing._muted, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.1;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * value;

    // מסילת-רקע
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = PremiumRing._track,
    );
    if (value <= 0) return;

    final shader = const SweepGradient(
      startAngle: start,
      endAngle: start + 2 * math.pi,
      colors: [PremiumRing._arcA, PremiumRing._arcB, PremiumRing._arcC, PremiumRing._arcA],
      stops: [0, 0.4, 0.75, 1],
      transform: GradientRotation(-math.pi / 2),
    ).createShader(rect);

    canvas
      // זוהר
      ..drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = shader
          ..color = PremiumRing._glow.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      )
      // קשת-חדה
      ..drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = shader,
      );
    // נקודת-קצה מוארת
    final end = Offset(
      center.dx + radius * math.cos(start + sweep),
      center.dy + radius * math.sin(start + sweep),
    );
    canvas
      ..drawCircle(end, stroke * 0.5, Paint()..color = Colors.white.withValues(alpha: 0.9))
      ..drawCircle(end, stroke * 0.22, Paint()..color = PremiumRing._arcB);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value;
}
