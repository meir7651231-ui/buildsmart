// ✨ Sparkline — קו-מגמה זעיר עם מילוי-גרדיאנט ונקודת-קצה מודגשת (CustomPainter)
import 'dart:ui';
import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, this.height = 56});

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparkPainter(values),
        size: Size.infinite,
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values);

  final List<double> values;

  static const Color _cyan = Color(0xFF22E1FF);
  static const Color _violet = Color(0xFF7A5CFF);
  static const Color _magenta = Color(0xFFFF3DCB);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    double lo = values.first, hi = values.first;
    for (final v in values) {
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    final double span = (hi - lo).abs() < 1e-9 ? 1 : (hi - lo);
    const double pad = 5;
    final double h = size.height - pad * 2;
    final double dx = size.width / (values.length - 1);

    final List<Offset> pts = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final double t = (values[i] - lo) / span;
      pts.add(Offset(i * dx, pad + (1 - t) * h));
    }

    final Path line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final Offset p0 = pts[i - 1];
      final Offset p1 = pts[i];
      final double mx = (p0.dx + p1.dx) / 2;
      line.cubicTo(mx, p0.dy, mx, p1.dy, p1.dx, p1.dy);
    }

    final Rect rect = Offset.zero & size;
    const Gradient grad = LinearGradient(
      colors: [_cyan, _violet, _magenta],
    );

    final Path fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_violet.withValues(alpha: 0.28), _violet.withValues(alpha: 0.0)],
        ).createShader(rect),
    );

    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = grad.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(line, glow);

    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = grad.createShader(rect);
    canvas.drawPath(line, stroke);

    final Offset end = pts.last;
    canvas.drawCircle(end, 8, Paint()..color = _magenta.withValues(alpha: 0.28));
    canvas.drawCircle(end, 4.5, Paint()..color = _magenta);
    canvas.drawCircle(end, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.values != values;
}
