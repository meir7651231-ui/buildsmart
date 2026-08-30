// 🎨 חוט-תצוגה · DonutChart — תרשים-טבעת עם קשתות שנפרשות (חוק-1/חוק-5).
// המנוע: N פלחים בגדלים דטרמיניסטיים שנסרקים פנימה (AnimationController); חור מרכזי.
// אפס-דאטה — גובה · מספר-פלחים · צבע-פלח/מבטא/רקע · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutChart extends StatefulWidget {
  const DonutChart({
    required this.height,
    required this.slices,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });
  final double height, radius;
  final int slices;
  final Color accentColor, baseColor, fillColor;
  final int seed;
  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> with SingleTickerProviderStateMixin {
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
          width: widget.height * 0.75,
          height: widget.height * 0.75,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _DonutPainter(
                t: Curves.easeOut.transform(_c.value),
                slices: widget.slices < 1 ? 1 : widget.slices,
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

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.t, required this.slices, required this.seed, required this.accent, required this.base, required this.fill});
  final double t;
  final int slices;
  final int seed;
  final Color accent, base, fill;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    final stroke = r * 0.32;
    final weights = List.generate(slices, (i) => math.sin(i * 1.3 + seed) * 0.5 + 0.7);
    final total = weights.fold<double>(0, (a, b) => a + b);
    var start = -math.pi / 2;
    for (var i = 0; i < slices; i++) {
      final sweep = (weights[i] / total) * 2 * math.pi * t;
      final col = Color.lerp(base, accent, i / slices) ?? accent;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r - stroke / 2),
        start,
        sweep - 0.04,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = col,
      );
      start += (weights[i] / total) * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.t != t || old.slices != slices;
}
