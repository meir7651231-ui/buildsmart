// 🎨 חוט-תצוגה · MapPins — מפה סגנונית עם סיכות שנוחתות ופועמות (חוק-1/חוק-5).
// המנוע: רשת-מפה + N סיכות במיקומים דטרמיניסטיים (seed), הילת-פעימה סביבן (AnimationController).
// אפס-דאטה — גובה · מספר-סיכות · צבע-סיכה/רשת/רקע · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class MapPins extends StatefulWidget {
  const MapPins({
    required this.height,
    required this.pins,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });
  final double height;
  final int pins;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  final int seed;
  @override
  State<MapPins> createState() => _MapPinsState();
}

class _MapPinsState extends State<MapPins> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _MapPainter(
                t: _c.value,
                pins: widget.pins < 0 ? 0 : widget.pins,
                seed: widget.seed,
                accent: widget.accentColor,
                base: widget.baseColor,
                fill: widget.fillColor,
              ),
            ),
          ),
        ),
      );
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.t, required this.pins, required this.seed, required this.accent, required this.base, required this.fill});
  final double t;
  final int pins;
  final int seed;
  final Color accent, base, fill;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    final grid = Paint()..color = base.withValues(alpha: 0.08)..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 26) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (var y = 0.0; y < size.height; y += 26) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    for (var i = 0; i < pins; i++) {
      final px = (math.sin(i * 2.1 + seed) * 0.4 + 0.5) * size.width;
      final py = (math.cos(i * 1.7 + seed) * 0.4 + 0.5) * size.height;
      final pulse = (t + i * 0.2) % 1;
      canvas.drawCircle(Offset(px, py), 6 + pulse * 18, Paint()..color = accent.withValues(alpha: (1 - pulse) * 0.4));
      canvas.drawCircle(Offset(px, py), 6, Paint()..color = accent);
      canvas.drawCircle(Offset(px, py), 2.5, Paint()..color = fill);
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.t != t || old.pins != pins;
}
