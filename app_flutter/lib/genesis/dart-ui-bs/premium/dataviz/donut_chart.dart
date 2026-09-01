// ✨ DonutChart — טבעת-דונאט מפולחת פלטת-ניאון + סכום במרכז (CustomPainter)
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.values, this.size = 176});

  final List<double> values;
  final double size;

  static const List<Color> palette = [
    Color(0xFF22E1FF),
    Color(0xFF7A5CFF),
    Color(0xFFFF3DCB),
    Color(0xFF3DFFB0),
    Color(0xFFFFC24B),
    Color(0xFF5C7CFF),
  ];

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (final v in values) {
      if (v > 0) total += v;
    }
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.square(size), painter: _DonutPainter(values)),
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              colors: [Color(0xFF22E1FF), Color(0xFFFF3DCB)],
            ).createShader(r),
            child: Text(
              _fmt(total),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.19,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.values);

  final List<double> values;

  static const Color _track = Color(0xFF1A1B33);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double stroke = size.width * 0.15;
    final double r = (size.width - stroke) / 2;
    final Rect box = Rect.fromCircle(center: c, radius: r);

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = _track,
    );

    double total = 0;
    for (final v in values) {
      if (v > 0) total += v;
    }
    if (total <= 0) return;

    const double gap = 0.045; // רווח בין פלחים ברדיאנים
    double a = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final double v = values[i];
      if (v <= 0) continue;
      final double sweep = (v / total) * (2 * math.pi);
      final double drawSweep = math.max(sweep - gap, 0.01);
      final Color col = DonutChart.palette[i % DonutChart.palette.length];

      canvas.drawArc(
        box,
        a + gap / 2,
        drawSweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = col.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawArc(
        box,
        a + gap / 2,
        drawSweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = col,
      );
      a += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.values != values;
}
