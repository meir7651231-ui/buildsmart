// 🎨 חוט-תצוגה · ConfettiBurst — התפרצות-קונפטי מחזורית (מנוע-הנפשה טהור, חוק-1/חוק-5).
// המנוע: N פיסות משוגרות מהמרכז-התחתון בזווית-פיזור, נופלות בכובד (v*t + ½g·t²)
// ודועכות; המחזור חוזר. אפס-דאטה — שלושה גוונים · רקע · גובה · כמות · מהירות · seed מוזרקים.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    required this.height,
    required this.pieces,
    required this.speed,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.mutedColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });

  final double height;
  final int pieces;
  final double speed;
  final double radius;
  final Color accentColor, baseColor, mutedColor, fillColor;
  final int seed;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
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
              painter: _ConfettiPainter(
                t: _c.value,
                pieces: widget.pieces < 0 ? 0 : widget.pieces,
                speed: widget.speed <= 0 ? 1 : widget.speed,
                seed: widget.seed,
                palette: [widget.accentColor, widget.baseColor, widget.mutedColor],
                fill: widget.fillColor,
              ),
            ),
          ),
        ),
      );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.t,
    required this.pieces,
    required this.speed,
    required this.seed,
    required this.palette,
    required this.fill,
  });

  final double t;
  final int pieces;
  final double speed;
  final int seed;
  final List<Color> palette;
  final Color fill;

  double _rnd(int i, int k) {
    final n = math.sin(i * 12.9898 + k * 78.233 + seed * 3.7) * 43758.5453;
    return n - n.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width, H = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    if (pieces <= 0 || W <= 0 || H <= 0) return;
    final tt = (t * speed) % 1;
    final originX = W / 2, originY = H * 0.85;
    for (var i = 0; i < pieces; i++) {
      final ang = -math.pi / 2 + (_rnd(i, 1) - 0.5) * math.pi * 0.85;
      final sp = 0.45 + _rnd(i, 2) * 0.8;
      final vx = math.cos(ang) * sp, vy = math.sin(ang) * sp;
      final x = originX + vx * W * 0.55 * tt;
      final y = originY + vy * H * 0.9 * tt + 0.5 * (H * 1.4) * tt * tt;
      if (y > H + 8) continue;
      final size2 = 2 + _rnd(i, 3) * 3.5;
      final col = palette[i % palette.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((_rnd(i, 4) * 2 + tt * 6) * math.pi);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: size2, height: size2 * 0.6),
        Paint()..color = col.withValues(alpha: (1 - tt).clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t || old.pieces != pieces;
}
