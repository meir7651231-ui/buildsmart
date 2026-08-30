// 🎨 חוט-תצוגה · RadarChart — תרשים-מכ"ם (עכביש) שנפרש בכניסה (חוק-1/חוק-5).
// המנוע: N צירים עם ערכים דטרמיניסטיים (seed); המצולע נפרש 0→מלא (AnimationController).
// אפס-דאטה — גובה · מספר-צירים · צבע-מילוי/רשת/רקע · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadarChart extends StatefulWidget {
  const RadarChart({
    required this.height,
    required this.axes,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });
  final double height;
  final int axes;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  final int seed;
  @override
  State<RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
        child: SizedBox(
          width: widget.height * 0.8,
          height: widget.height * 0.8,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _RadarPainter(
                t: Curves.easeOutBack.transform(_c.value).clamp(0.0, 1.0),
                axes: widget.axes < 3 ? 3 : widget.axes,
                seed: widget.seed,
                accent: widget.accentColor,
                base: widget.baseColor,
              ),
            ),
          ),
        ),
      );
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.t, required this.axes, required this.seed, required this.accent, required this.base});
  final double t;
  final int axes;
  final int seed;
  final Color accent, base;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 * 0.9;
    final gridP = Paint()..style = PaintingStyle.stroke..color = base.withValues(alpha: 0.15)..strokeWidth = 1;
    for (var ring = 1; ring <= 3; ring++) {
      final path = Path();
      for (var i = 0; i <= axes; i++) {
        final a = -math.pi / 2 + i * 2 * math.pi / axes;
        final p = center + Offset(math.cos(a), math.sin(a)) * (r * ring / 3);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, gridP);
    }
    final poly = Path();
    for (var i = 0; i <= axes; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / axes;
      final val = (math.sin(i * 1.9 + seed) * 0.35 + 0.6) * t;
      final p = center + Offset(math.cos(a), math.sin(a)) * (r * val);
      i == 0 ? poly.moveTo(p.dx, p.dy) : poly.lineTo(p.dx, p.dy);
    }
    poly.close();
    canvas.drawPath(poly, Paint()..color = accent.withValues(alpha: 0.25));
    canvas.drawPath(poly, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = accent);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.t != t || old.axes != axes;
}
