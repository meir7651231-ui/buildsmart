// 🎨 חוט-תצוגה · SpotlightCard — כרטיס עם זרקור-אור נע (חוק-1/חוק-5).
// המנוע: הילת-אור רדיאלית שסורקת את הכרטיס (CustomPaint) מתחת לטקסט. אפס-דאטה —
// כותרת · תת-כותרת · גובה · צבע-זוהר/טקסט/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpotlightCard extends StatefulWidget {
  const SpotlightCard({
    required this.title,
    required this.sub,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final String title, sub;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<SpotlightCard> createState() => _SpotlightCardState();
}

class _SpotlightCardState extends State<SpotlightCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
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
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => CustomPaint(
                    painter: _SpotlightPainter(
                      t: _c.value,
                      glow: widget.accentColor,
                      fill: widget.fillColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.baseColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.sub,
                      style: TextStyle(
                        color: widget.baseColor.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.t, required this.glow, required this.fill});

  final double t;
  final Color glow, fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = fill);
    final cx = size.width * (0.5 + 0.4 * math.sin(t * 2 * math.pi));
    final cy = size.height * (0.4 + 0.2 * math.cos(t * 2 * math.pi * 0.8));
    final r = math.max(size.width, size.height) * 0.55;
    final shader = RadialGradient(
      colors: [glow.withValues(alpha: 0.4), glow.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.t != t;
}
