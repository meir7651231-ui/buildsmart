// 🎨 חוט-תצוגה · StoryRing — אווטאר עם טבעת-סטורי גרדיאנט מסתובבת (חוק-1/חוק-5).
// המנוע: טבעת-גרדיאנט (SweepGradient) שמסתובבת סביב עיגול-אווטאר (AnimationController).
// אפס-דאטה — גובה · צבע-טבעת/אווטאר/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class StoryRing extends StatefulWidget {
  const StoryRing({
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<StoryRing> createState() => _StoryRingState();
}

class _StoryRingState extends State<StoryRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final d = widget.height.clamp(44.0, 96.0);
    return Center(
      child: SizedBox(
        width: d, height: d,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: d, height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    transform: GradientRotation(_c.value * 2 * math.pi),
                    colors: [widget.accentColor, widget.baseColor, widget.accentColor],
                  ),
                ),
              ),
              Container(
                width: d - 8, height: d - 8,
                decoration: BoxDecoration(color: widget.fillColor, shape: BoxShape.circle),
              ),
              Container(
                width: d - 14, height: d - 14,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(Icons.person, color: widget.accentColor, size: d * 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
