// 🎨 חוט-תצוגה · GenerativeCanvas — שדה-רעש גנרטיבי מונפש (מנוע-הנפשה טהור, חוק-1/חוק-5).
// המנוע: רשת NxN תאים, בהירות כל תא = שדה-רעש-ערך (סכום סינוסים מוזז-פאזה). אפס-דאטה —
// שני גוונים · רקע · גובה · צפיפות-רשת · מהירות · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GenerativeCanvas extends StatefulWidget {
  const GenerativeCanvas({
    required this.height,
    required this.cells,
    required this.speed,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });

  final double height;
  final int cells;
  final double speed;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  final int seed;

  @override
  State<GenerativeCanvas> createState() => _GenerativeCanvasState();
}

class _GenerativeCanvasState extends State<GenerativeCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
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
              painter: _NoisePainter(
                t: _c.value,
                cells: widget.cells < 1 ? 1 : widget.cells,
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

class _NoisePainter extends CustomPainter {
  _NoisePainter({
    required this.t,
    required this.cells,
    required this.speed,
    required this.seed,
    required this.accent,
    required this.base,
    required this.fill,
  });

  final double t;
  final int cells;
  final double speed;
  final int seed;
  final Color accent, base, fill;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width, H = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    if (W <= 0 || H <= 0) return;
    final cols = cells;
    final rows = (cells * H / W).clamp(1, cells * 3).round();
    final cw = W / cols, ch = H / rows;
    final ph = t * 2 * math.pi * speed;
    final s = seed * 0.6;
    for (var yy = 0; yy < rows; yy++) {
      for (var xx = 0; xx < cols; xx++) {
        final nx = xx / cols, ny = yy / rows;
        var v = 0.5 +
            0.35 * math.sin(nx * 6.2 + ph + s) +
            0.35 * math.sin(ny * 5.1 - ph * 0.7 + s) +
            0.30 * math.sin((nx + ny) * 4.3 + ph * 0.5);
        v = (v.clamp(0.0, 1.0)).toDouble();
        final col = Color.lerp(base, accent, v) ?? accent;
        canvas.drawRect(
          Rect.fromLTWH(xx * cw, yy * ch, cw + 0.5, ch + 0.5),
          Paint()..color = col.withValues(alpha: 0.35 + 0.5 * v),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => old.t != t || old.cells != cells;
}
