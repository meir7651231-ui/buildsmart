// ✨ ProgressRing — טבעת-התקדמות 0..1 גרדיאנט+זוהר, אחוז במרכז (CustomPainter)
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, this.label, this.size = 148});

  final double value;
  final String? label;
  final double size;

  static const Color _mute = Color(0xFF8A8CB8);

  @override
  Widget build(BuildContext context) {
    final double v = value.clamp(0.0, 1.0);
    final int pct = (v * 100).round();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.square(size), painter: _RingPainter(v)),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [Color(0xFF22E1FF), Color(0xFFFF3DCB)],
                  ).createShader(r),
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                if (label != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    label!,
                    style: const TextStyle(
                      color: _mute,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);

  final double value;

  static const Color _track = Color(0xFF1A1B33);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double stroke = size.width * 0.11;
    final double r = (size.width - stroke) / 2;
    final Rect box = Rect.fromCircle(center: c, radius: r);
    const double start = -math.pi / 2;
    final double sweep = 2 * math.pi * value;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = _track,
    );

    if (value <= 0) return;

    const SweepGradient grad = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [Color(0xFF22E1FF), Color(0xFF7A5CFF), Color(0xFFFF3DCB), Color(0xFF22E1FF)],
    );

    canvas.drawArc(
      box,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = grad.createShader(box)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawArc(
      box,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = grad.createShader(box),
    );

    final double ang = start + sweep;
    final Offset head = Offset(c.dx + r * math.cos(ang), c.dy + r * math.sin(ang));
    canvas.drawCircle(head, stroke * 0.62, Paint()..color = Colors.white);
    canvas.drawCircle(
      head,
      stroke * 0.62,
      Paint()
        ..color = const Color(0xFFFF3DCB).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value;
}
