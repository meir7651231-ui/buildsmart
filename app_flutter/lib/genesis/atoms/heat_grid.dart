// 🎨 חוט-תצוגה · HeatGrid — מפת-חום נושמת (חוק-1/חוק-5).
// המנוע: רשת NxN, עוצמת כל תא דטרמיניסטית (seed) + נשימה עדינה (AnimationController).
// אפס-דאטה — גובה · צפיפות-רשת · צבע-שיא/רקע-תא/רקע · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeatGrid extends StatefulWidget {
  const HeatGrid({
    required this.height,
    required this.cells,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });
  final double height, radius;
  final int cells;
  final Color accentColor, baseColor, fillColor;
  final int seed;
  @override
  State<HeatGrid> createState() => _HeatGridState();
}

class _HeatGridState extends State<HeatGrid> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Container(
          height: widget.height,
          width: double.infinity,
          color: widget.fillColor,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _HeatPainter(
                t: _c.value,
                cells: widget.cells < 1 ? 1 : widget.cells,
                seed: widget.seed,
                accent: widget.accentColor,
                base: widget.baseColor,
              ),
            ),
          ),
        ),
      );
}

class _HeatPainter extends CustomPainter {
  _HeatPainter({required this.t, required this.cells, required this.seed, required this.accent, required this.base});
  final double t;
  final int cells;
  final int seed;
  final Color accent, base;
  @override
  void paint(Canvas canvas, Size size) {
    final pad = 8.0;
    final cols = cells;
    final rows = ((cells * size.height / size.width).clamp(1, cells * 2)).round();
    final cw = (size.width - pad * 2) / cols, ch = (size.height - pad * 2) / rows;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        var v = math.sin(x * 1.1 + y * 0.7 + seed) * 0.5 + 0.5;
        v = (v + 0.1 * math.sin(t * 2 * math.pi + x + y)).clamp(0.0, 1.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(pad + x * cw + 1, pad + y * ch + 1, cw - 2, ch - 2),
            const Radius.circular(3),
          ),
          Paint()..color = (Color.lerp(base, accent, v) ?? accent).withValues(alpha: 0.25 + 0.65 * v),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HeatPainter old) => old.t != t || old.cells != cells;
}
