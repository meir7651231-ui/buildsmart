// 🎨 חוט-תצוגה · ParticleField — שדה-חלקיקים מונפש (מנוע-הנפשה טהור, חוק-1/חוק-5).
// המנוע: N חלקיקים נודדים כלפי-מעלה במהירות פסאודו-אקראית דטרמיניסטית (seed), עוטפים
// בקצה. אפס-דאטה צרובה — צבע/גובה/כמות/מהירות/seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleField extends StatefulWidget {
  const ParticleField({
    required this.height,
    required this.dots,
    required this.speed,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });

  final double height;
  final int dots;
  final double speed;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  final int seed;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
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
              painter: _ParticlePainter(
                t: _c.value,
                dots: widget.dots < 0 ? 0 : widget.dots,
                speed: widget.speed <= 0 ? 1 : widget.speed,
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

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.t,
    required this.dots,
    required this.speed,
    required this.seed,
    required this.accent,
    required this.base,
    required this.fill,
  });

  final double t;
  final int dots;
  final double speed;
  final int seed;
  final Color accent, base, fill;

  double _rnd(int i, int k) {
    final n = math.sin(i * 12.9898 + k * 78.233 + seed * 3.7) * 43758.5453;
    return n - n.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    if (dots <= 0 || size.width <= 0 || size.height <= 0) return;
    final phase = t * 2 * math.pi;
    for (var i = 0; i < dots; i++) {
      final rise = 0.2 + 0.8 * _rnd(i, 3);
      final yNorm = ((_rnd(i, 2) + t * rise * speed) % 1 + 1) % 1;
      final y = (1 - yNorm) * size.height;
      final x = _rnd(i, 1) * size.width + math.sin(phase + i) * size.width * 0.02;
      final rad = 0.8 + _rnd(i, 4) * 2.6;
      final col = Color.lerp(base, accent, _rnd(i, 6)) ?? accent;
      canvas.drawCircle(
        Offset(x, y),
        rad,
        Paint()..color = col.withValues(alpha: 0.18 + 0.55 * _rnd(i, 5)),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.t != t || old.dots != dots || old.seed != seed;
}
