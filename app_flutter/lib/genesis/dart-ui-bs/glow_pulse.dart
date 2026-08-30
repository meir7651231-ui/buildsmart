// 🎨 חוט-תצוגה · GlowPulse — הילת-זוהר נושמת (מנוע-הנפשה טהור, חוק-1/חוק-5).
// המנוע: טבעות-זוהר מרוכזות שנושמות בעקומה מחזורית (sin) סביב ליבה. אפס-דאטה —
// צבע-הילה/ליבה/רקע · גובה · מהירות מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlowPulse extends StatefulWidget {
  const GlowPulse({
    required this.height,
    required this.speed,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final double height;
  final double speed;
  final double radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _GlowPainter(
                t: _c.value,
                speed: widget.speed <= 0 ? 1 : widget.speed,
                glow: widget.accentColor,
                core: widget.baseColor,
                fill: widget.fillColor,
              ),
            ),
          ),
        ),
      );
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.t,
    required this.speed,
    required this.glow,
    required this.core,
    required this.fill,
  });

  final double t;
  final double speed;
  final Color glow, core, fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    if (size.width <= 0 || size.height <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final base = math.min(size.width, size.height) * 0.26;
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi * speed);
    for (var k = 8; k >= 0; k--) {
      final rad = base * (1.7 - k * 0.15) * (0.9 + 0.25 * pulse);
      canvas.drawCircle(
        center,
        rad,
        Paint()..color = glow.withValues(alpha: 0.04 + k * 0.022 * (0.6 + 0.4 * pulse)),
      );
    }
    canvas.drawCircle(
      center,
      base * (0.5 + 0.12 * pulse),
      Paint()..color = core.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.t != t;
}
