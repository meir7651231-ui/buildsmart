// 🎨 חוט-תצוגה · BarChart — תרשים-עמודות שצומח בכניסה (חוק-1/חוק-5).
// המנוע: N עמודות בגבהים דטרמיניסטיים (seed) שצומחות 0→שיא (AnimationController).
// אפס-דאטה — גובה · מספר-עמודות · צבע-עמודה/מבטא/רקע · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class BarChart extends StatefulWidget {
  const BarChart({
    required this.height,
    required this.bars,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });
  final double height, radius;
  final int bars;
  final Color accentColor, baseColor, fillColor;
  final int seed;
  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Container(
          height: widget.height,
          color: widget.fillColor,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _BarPainter(
                t: Curves.easeOutCubic.transform(_c.value),
                bars: widget.bars < 1 ? 1 : widget.bars,
                seed: widget.seed,
                accent: widget.accentColor,
                base: widget.baseColor,
              ),
            ),
          ),
        ),
      );
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.t, required this.bars, required this.seed, required this.accent, required this.base});
  final double t;
  final int bars;
  final int seed;
  final Color accent, base;
  @override
  void paint(Canvas canvas, Size size) {
    final pad = 14.0;
    final w = (size.width - pad * 2) / bars;
    for (var i = 0; i < bars; i++) {
      final r = (math.sin(i * 1.7 + seed) * 0.5 + 0.5) * 0.75 + 0.2;
      final h = (size.height - pad * 2) * r * t;
      final x = pad + i * w;
      final col = Color.lerp(base, accent, r) ?? accent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + w * 0.15, size.height - pad - h, w * 0.7, h),
          const Radius.circular(4),
        ),
        Paint()..color = col.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.t != t || old.bars != bars;
}
