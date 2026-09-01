// ✨ RatingStars — 5 כוכבים לפי value 0..5 (מלא/חצי/ריק), זהב זוהר; דאטה: double value + size
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double value;
  final double size;
  const RatingStars({super.key, required this.value, this.size = 22});

  static const Color _gold = Color(0xFFF59E0B);
  static const Color _empty = Color(0xFF3A3352);

  @override
  Widget build(BuildContext context) {
    final double v = value.clamp(0.0, 5.0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (i) {
        final double fill = (v - i).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _StarPainter(fill),
            ),
          ),
        );
      }),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double fill;
  _StarPainter(this.fill);

  Path _starPath(Size size) {
    final double cx = size.width / 2, cy = size.height / 2;
    final double outer = size.width / 2;
    final double inner = outer * 0.42;
    final Path p = Path();
    for (int i = 0; i < 10; i++) {
      final double r = i.isEven ? outer : inner;
      final double a = -math.pi / 2 + i * math.pi / 5;
      final double x = cx + r * math.cos(a);
      final double y = cy + r * math.sin(a);
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Path star = _starPath(size);
    // ריק
    canvas.drawPath(
      star,
      Paint()
        ..color = RatingStars._empty
        ..style = PaintingStyle.fill,
    );
    // מלא (חתוך לפי fill)
    if (fill > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * fill, size.height));
      final Paint glow = Paint()
        ..color = RatingStars._gold.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(star, glow);
      canvas.drawPath(
        star,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFD98A), RatingStars._gold],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
      canvas.restore();
    }
    // מסגרת עדינה
    canvas.drawPath(
      star,
      Paint()
        ..color = RatingStars._gold.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.fill != fill;
}
