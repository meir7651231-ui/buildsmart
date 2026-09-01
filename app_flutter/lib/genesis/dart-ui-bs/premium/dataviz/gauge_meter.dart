// ✨ GaugeMeter — מד-קשת 0..1 גרדיאנט-ניאון עם מחוג זוהר (CustomPainter)
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class GaugeMeter extends StatelessWidget {
  const GaugeMeter({super.key, required this.value, this.size = 200});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double v = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size * 0.62,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 0.62),
            painter: _GaugePainter(v),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: size * 0.02),
            child: ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Color(0xFF22E1FF), Color(0xFFFF3DCB)],
              ).createShader(r),
              child: Text(
                '${(v * 100).round()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value);

  final double value;

  static const Color _track = Color(0xFF1A1B33);
  static const double _start = math.pi;
  static const double _extent = math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height);
    final double stroke = size.width * 0.075;
    final double r = size.width / 2 - stroke;
    final Rect box = Rect.fromCircle(center: c, radius: r);

    canvas.drawArc(
      box,
      _start,
      _extent,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = _track,
    );

    const SweepGradient grad = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: [Color(0xFF22E1FF), Color(0xFF7A5CFF), Color(0xFFFF3DCB)],
    );

    final double sweep = _extent * value;
    if (sweep > 0) {
      canvas.drawArc(
        box,
        _start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = grad.createShader(box)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
      canvas.drawArc(
        box,
        _start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = grad.createShader(box),
      );
    }

    // מחוג
    final double ang = _start + _extent * value;
    final double nx = c.dx + (r) * math.cos(ang);
    final double ny = c.dy + (r) * math.sin(ang);
    final Paint needle = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c, Offset(nx, ny), needle);
    canvas.drawCircle(c, stroke * 0.55, Paint()..color = const Color(0xFF7A5CFF));
    canvas.drawCircle(c, stroke * 0.28, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(nx, ny),
      5,
      Paint()
        ..color = const Color(0xFFFF3DCB)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.value != value;
}
