// 🎨 חוט-תצוגה · AuroraField — שדה-אורות מונפש (מנוע-הנפשה טהור, חוק-1/חוק-5).
// המנוע: N פסי-גל סינוסיים נעים בפאזה מתמשכת (AnimationController), נצבעים בגרדיאנט
// בין accentColor⇄baseColor מעל fillColor. אפס-תוכן צרוב: צבעים · גובה · מספר-פסים ·
// מהירות · seed — כולם props מוזרקים (הקופסה/המחולל מחווטים; האטום לא יודע הקשר).
// חוזה: bands פסים · speed=סל"ד-פאזה · seed=היסט-פאזה דטרמיניסטי · height=גובה-משטח.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AuroraField extends StatefulWidget {
  const AuroraField({
    required this.height,
    required this.bands,
    required this.speed,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });

  /// גובה משטח-הציור (הכרעה: האטום נצרך בתוך ListView ⇒ חייב גובה מוגדר).
  final double height;

  /// מספר פסי-הגל. 0 ⇒ משטח-רקע חלק (מגן-קצה, בלי קריסה).
  final int bands;

  /// סיבובי-פאזה למחזור-הנפשה מלא (6 שניות). ↑ = תנועה מהירה יותר.
  final double speed;

  final double radius;

  /// גוון-השיא של הגל.
  final Color accentColor;

  /// גוון-השפל של הגל (הגרדיאנט נמתח accent⇄base).
  final Color baseColor;

  /// רקע המשטח שמאחורי הגלים.
  final Color fillColor;

  /// היסט-פאזה דטרמיניסטי — אותו seed ⇒ אותה תבנית בדיוק (ניתן-לחילול-מדאטה).
  final int seed;

  @override
  State<AuroraField> createState() => _AuroraFieldState();
}

class _AuroraFieldState extends State<AuroraField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _AuroraPainter(
                t: _c.value,
                bands: widget.bands < 0 ? 0 : widget.bands,
                speed: widget.speed,
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

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.t,
    required this.bands,
    required this.speed,
    required this.seed,
    required this.accent,
    required this.base,
    required this.fill,
  });

  final double t;
  final int bands;
  final double speed;
  final int seed;
  final Color accent, base, fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = fill);
    if (bands <= 0 || size.width <= 0 || size.height <= 0) return;

    final phase = t * 2 * math.pi * (speed <= 0 ? 1 : speed);
    for (var i = 0; i < bands; i++) {
      final f = bands == 1 ? 0.5 : i / (bands - 1);
      final off = seed * 0.37 + i * 1.13; // היסט-פאזה דטרמיניסטי לכל פס
      final amp = size.height * (0.10 + 0.06 * math.sin(off));
      final midY = size.height * (0.15 + 0.7 * f);
      final path = Path()..moveTo(0, midY);
      const steps = 48;
      for (var s = 0; s <= steps; s++) {
        final x = size.width * s / steps;
        final y = midY +
            amp * math.sin(phase + off + (x / size.width) * 2 * math.pi * (1 + f));
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final color = Color.lerp(base, accent, f) ?? accent;
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.22 + 0.20 * f)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.t != t ||
      old.bands != bands ||
      old.speed != speed ||
      old.seed != seed ||
      old.accent != accent ||
      old.base != base ||
      old.fill != fill;
}
