// 🎨 חוט-תצוגה · LineSpark — גרף-קו עם מילוי-שטח שנמתח בכניסה (חוק-1/חוק-5).
// המנוע: פוליגון דרך N נקודות דטרמיניסטיות + מילוי-שטח, נמתח 0→1 (AnimationController).
// אפס-דאטה — גובה · מספר-נקודות · צבע-קו/מבטא/רקע · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class LineSpark extends StatefulWidget {
  const LineSpark({
    required this.height,
    required this.points,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });
  final double height, radius;
  final int points;
  final Color accentColor, baseColor, fillColor;
  final int seed;
  @override
  State<LineSpark> createState() => _LineSparkState();
}

class _LineSparkState extends State<LineSpark> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
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
              painter: _SparkPainter(
                t: Curves.easeOut.transform(_c.value),
                points: widget.points < 2 ? 2 : widget.points,
                seed: widget.seed,
                accent: widget.accentColor,
              ),
            ),
          ),
        ),
      );
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.t, required this.points, required this.seed, required this.accent});
  final double t;
  final int points;
  final int seed;
  final Color accent;
  @override
  void paint(Canvas canvas, Size size) {
    final pad = 12.0;
    final n = points;
    final drawn = (n * t).clamp(1, n).round();
    Offset at(int i) {
      final r = math.sin(i * 0.9 + seed) * 0.5 + 0.5;
      final x = pad + (size.width - pad * 2) * i / (n - 1);
      final y = pad + (size.height - pad * 2) * (1 - r);
      return Offset(x, y);
    }
    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < drawn; i++) line.lineTo(at(i).dx, at(i).dy);
    final area = Path.from(line)
      ..lineTo(at(drawn - 1).dx, size.height - pad)
      ..lineTo(at(0).dx, size.height - pad)
      ..close();
    canvas.drawPath(area, Paint()..color = accent.withValues(alpha: 0.18));
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = accent,
    );
    canvas.drawCircle(at(drawn - 1), 4, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.t != t || old.points != points;
}
