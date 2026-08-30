// 🎨 חוט-תצוגה · OrbitSpinner — טוען מסתובב (קשת נעה) (חוק-1/חוק-5).
// המנוע: טבעת-רקע דהויה + קשת-צבע שמסתובבת ברציפות (AnimationController). אפס-דאטה —
// גובה/קוטר · צבע-קשת/רקע-טבעת מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class OrbitSpinner extends StatefulWidget {
  const OrbitSpinner({
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    super.key,
  });

  final double height, radius;
  final Color accentColor, baseColor;

  @override
  State<OrbitSpinner> createState() => _OrbitSpinnerState();
}

class _OrbitSpinnerState extends State<OrbitSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: widget.height,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _SpinnerPainter(
                t: _c.value,
                accent: widget.accentColor,
                base: widget.baseColor,
              ),
            ),
          ),
        ),
      );
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.t, required this.accent, required this.base});

  final double t;
  final Color accent, base;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.12;
    final r = size.shortestSide / 2 - stroke;
    final center = Offset(size.width / 2, size.height / 2);
    if (r <= 0) return;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = base.withValues(alpha: 0.18),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      t * 2 * math.pi,
      math.pi * 1.4,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = accent,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.t != t;
}
