// 🎨 חוט-תצוגה · BarChart — תרשים-עמודות שצומח בכניסה (חוק-1/חוק-5).
// המנוע: עמודה לכל ערך, גובה יחסי-למקסימום, צומחות 0→שיא בכניסה (AnimationController).
// תפר-דאטה (G21 · §20-ג): values = הערכים האמיתיים מוזרקים בחיווט — האטום לא ממציא גבהים (היה seed).
// עיצוב — גובה · צבע-עמודה/מבטא/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class BarChart extends StatefulWidget {
  const BarChart({
    required this.values,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  /// הערכים האמיתיים, עמודה לכל ערך (שקע-דאטה).
  final List<double> values;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Container(
          height: widget.height,
          color: widget.fillColor,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _BarPainter(
                t: Curves.easeOutCubic.transform(_c.value),
                values: widget.values,
                accent: widget.accentColor,
                base: widget.baseColor,
              ),
            ),
          ),
        ),
      );
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.t, required this.values, required this.accent, required this.base});
  final double t;
  final List<double> values;
  final Color accent, base;
  @override
  void paint(Canvas canvas, Size size) {
    final pad = 14.0;
    final bars = values.isEmpty ? 1 : values.length;
    final w = (size.width - pad * 2) / bars;
    final mx = values.fold<double>(0, (m, v) => v > m ? v : m);
    for (var i = 0; i < values.length; i++) {
      final r = mx <= 0 ? 0.0 : (values[i] / mx).clamp(0.0, 1.0);
      final h = (size.height - pad * 2) * r * t;
      final x = pad + i * w;
      final col = Color.lerp(base, accent, r) ?? accent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + w * 0.15, size.height - pad - h, w * 0.7, h),
          const Radius.circular(4),
        ),
        Paint()..color = col.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.t != t || old.values != values;
}
