// 🎨 חוט-תצוגה · ParallaxTilt — עומק תלת-ממדי בהטיה מתנדנדת (מנוע-הנפשה טהור, חוק-1/חוק-5).
// המנוע: Matrix4 פרספקטיבה + שכבות-כרטיס בעומק שזזות ביחס-הפוך למרחק (parallax),
// ההטיה מתנדנדת אוטומטית (sin/cos). אפס-דאטה — צבע-קרוב/רחוק/רקע · גובה · שכבות · מהירות מוזרקים.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParallaxTilt extends StatefulWidget {
  const ParallaxTilt({
    required this.height,
    required this.layers,
    required this.speed,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final double height;
  final int layers;
  final double speed;
  final double radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<ParallaxTilt> createState() => _ParallaxTiltState();
}

class _ParallaxTiltState extends State<ParallaxTilt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.layers < 1 ? 1 : widget.layers;
    final speed = widget.speed <= 0 ? 1 : widget.speed;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: widget.fillColor,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final phase = _c.value * 2 * math.pi * speed;
            final ax = math.sin(phase) * 0.28;
            final ay = math.cos(phase * 0.8) * 0.18;
            return Center(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(ay)
                  ..rotateY(ax),
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(n, (k) {
                    final depth = n == 1 ? 0.0 : k / (n - 1);
                    final side = widget.height * (0.6 - depth * 0.32);
                    return Transform.translate(
                      offset: Offset(ax * depth * 60, ay * depth * 60),
                      child: Container(
                        width: side,
                        height: side,
                        decoration: BoxDecoration(
                          color: (Color.lerp(widget.baseColor, widget.accentColor, depth) ??
                                  widget.accentColor)
                              .withValues(alpha: 0.35 + 0.5 * depth),
                          borderRadius: BorderRadius.circular(widget.radius),
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
