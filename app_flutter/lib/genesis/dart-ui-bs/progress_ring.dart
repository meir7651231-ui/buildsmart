// 🎨 חוט-תצוגה · ProgressRing — טבעת-התקדמות עם אחוז במרכז (חוק-1/חוק-5).
// המנוע: קשת שמתמלאת 0→pct בכניסה (AnimationController) + טקסט-אחוז.
// תפר-דאטה (G21 · §20-ג): pct = האחוז האמיתי (0–100) מוזרק בחיווט — האטום לא ממציא ערך.
// עיצוב — גובה/קוטר · צבע-מילוי/מסלול/טקסט מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatefulWidget {
  const ProgressRing({
    required this.pct,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  /// האחוז האמיתי 0–100 (שקע-דאטה).
  final double pct;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  @override
  void didUpdateWidget(ProgressRing old) { super.didUpdateWidget(old); if (old.pct != widget.pct) _c.forward(from: 0); }

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
            builder: (context, _) { final v = Curves.easeOut.transform(_c.value) * (widget.pct / 100).clamp(0.0, 1.0); return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(widget.height, widget.height),
                  painter: _RingPainter(
                    value: v,
                    accent: widget.accentColor,
                    base: widget.baseColor,
                  ),
                ),
                Text(
                  '${(v * 100).round()}%',
                  style: TextStyle(
                    color: widget.baseColor,
                    fontWeight: FontWeight.w800,
                    fontSize: widget.height * 0.2,
                  ),
                ),
              ],
            ); },
          ),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.accent, required this.base});

  final double value;
  final Color accent, base;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.11;
    final r = size.shortestSide / 2 - stroke;
    final center = Offset(size.width / 2, size.height / 2);
    if (r <= 0) return;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = base.withValues(alpha: 0.16),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = accent,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}
