// 🎨 חוט-תצוגה · GradientSweep — מטאטא-גרדיאנט מסתובב (מנוע-הנפשה טהור, חוק-1/חוק-5).
// המנוע: SweepGradient תלת-גוני שמסתובב בפאזה מתמשכת (GradientRotation). אפס-דאטה —
// שלושת הגוונים · רקע · גובה · מהירות מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GradientSweep extends StatefulWidget {
  const GradientSweep({
    required this.height,
    required this.speed,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.mutedColor,
    required this.fillColor,
    super.key,
  });

  final double height;
  final double speed;
  final double radius;
  final Color accentColor, baseColor, mutedColor, fillColor;

  @override
  State<GradientSweep> createState() => _GradientSweepState();
}

class _GradientSweepState extends State<GradientSweep>
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
  Widget build(BuildContext context) {
    final speed = widget.speed <= 0 ? 1 : widget.speed;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: SweepGradient(
              transform: GradientRotation(_c.value * 2 * math.pi * speed),
              colors: [
                widget.baseColor,
                widget.accentColor,
                widget.mutedColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
