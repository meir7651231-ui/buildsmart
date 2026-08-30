// 🎨 חוט-תצוגה · ShimmerSkeleton — שלד-טעינה עם גל-ריצוד (מנוע-הנפשה טהור, חוק-1/חוק-5).
// המנוע: N פסי-שלד + פס-הבהקה שנע לרוחב (LinearGradient נודד). אפס-דאטה —
// צבע-בסיס/הבהקה/רקע · גובה · מספר-פסים · מהירות מוזרקים בחיווט.
import 'package:flutter/material.dart';

class ShimmerSkeleton extends StatefulWidget {
  const ShimmerSkeleton({
    required this.height,
    required this.bars,
    required this.speed,
    required this.radius,
    required this.baseColor,
    required this.accentColor,
    required this.fillColor,
    super.key,
  });

  final double height;
  final int bars;
  final double speed;
  final double radius;
  final Color baseColor, accentColor, fillColor;

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
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
              painter: _ShimmerPainter(
                t: _c.value,
                bars: widget.bars < 1 ? 1 : widget.bars,
                speed: widget.speed <= 0 ? 1 : widget.speed,
                base: widget.baseColor,
                accent: widget.accentColor,
                fill: widget.fillColor,
              ),
            ),
          ),
        ),
      );
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({
    required this.t,
    required this.bars,
    required this.speed,
    required this.base,
    required this.accent,
    required this.fill,
  });

  final double t;
  final int bars;
  final double speed;
  final Color base, accent, fill;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width, H = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    if (W <= 0 || H <= 0) return;
    final gap = H * 0.06;
    final barH = (H - gap * (bars + 1)) / bars;
    if (barH <= 0) return;

    final sweep = (((t * speed) % 1) + 1) % 1;
    final hx = sweep * (W * 1.4) - W * 0.2;
    final band = W * 0.28;
    final highlight = Paint()
      ..blendMode = BlendMode.plus
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0),
          accent.withValues(alpha: 0.5),
          accent.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(hx - band, 0, band * 2, H));

    for (var i = 0; i < bars; i++) {
      final top = gap + i * (barH + gap);
      final w = W * (i.isEven ? 0.92 : 0.7);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(W * 0.04, top, w, barH),
        Radius.circular(barH * 0.35),
      );
      canvas.drawRRect(r, Paint()..color = base.withValues(alpha: 0.35));
      canvas.save();
      canvas.clipRRect(r);
      canvas.drawRect(Rect.fromLTWH(0, top, W, barH), highlight);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.t != t || old.bars != bars;
}
