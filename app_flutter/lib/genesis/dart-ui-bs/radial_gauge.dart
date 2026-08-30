// 🎨 חוט-תצוגה · RadialGauge — מד חצי-עיגול עם מחוג נע (חוק-1/חוק-5).
// המנוע: קשת-מד 180° + מחוג שנע 0→ערך ובחזרה (AnimationController) + אחוז במרכז.
// אפס-דאטה — גובה · צבע-מד/מחוג/רקע מוזרקים בחיווט; הערך מונפש-מחזורי.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadialGauge extends StatefulWidget {
  const RadialGauge({
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<RadialGauge> createState() => _RadialGaugeState();
}

class _RadialGaugeState extends State<RadialGauge> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final v = Curves.easeInOut.transform(_c.value);
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: widget.height * 0.9,
                  height: widget.height * 0.9,
                  child: CustomPaint(
                    painter: _GaugePainter(v: v, accent: widget.accentColor, base: widget.baseColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: widget.height * 0.14),
                  child: Text('${(v * 100).round()}%',
                      style: TextStyle(color: widget.baseColor, fontWeight: FontWeight.w900, fontSize: widget.height * 0.16)),
                ),
              ],
            );
          },
        ),
      );
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.v, required this.accent, required this.base});
  final double v;
  final Color accent, base;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final r = size.width * 0.42;
    final stroke = r * 0.22;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), math.pi, math.pi, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round..color = base.withValues(alpha: 0.2));
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), math.pi, math.pi * v, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round..color = accent);
    final ang = math.pi + math.pi * v;
    final tip = center + Offset(math.cos(ang) * r * 0.85, math.sin(ang) * r * 0.85);
    canvas.drawLine(center, tip, Paint()..strokeWidth = 3..strokeCap = StrokeCap.round..color = accent);
    canvas.drawCircle(center, 5, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.v != v;
}
