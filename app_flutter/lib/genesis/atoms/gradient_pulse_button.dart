// 🎨 חוט-תצוגה · GradientPulseButton — כפתור עם גרדיאנט נודד + כיווץ-לחיצה (חוק-1/חוק-5).
// המנוע: הגרדיאנט מסתובב בזווית מתמשכת (AnimationController). אפס-דאטה —
// תווית · גובה · שני גווני-גרדיאנט · צבע-טקסט · onPressed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GradientPulseButton extends StatefulWidget {
  const GradientPulseButton({
    required this.label,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.labelColor,
    required this.onPressed,
    super.key,
  });

  final String label;
  final double height, radius;
  final Color accentColor, baseColor, labelColor;
  final VoidCallback onPressed;

  @override
  State<GradientPulseButton> createState() => _GradientPulseButtonState();
}

class _GradientPulseButtonState extends State<GradientPulseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();
  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final a = _c.value * 2 * math.pi;
          return GestureDetector(
            onTapDown: (_) => setState(() => _down = true),
            onTapCancel: () => setState(() => _down = false),
            onTapUp: (_) {
              setState(() => _down = false);
              widget.onPressed();
            },
            child: AnimatedScale(
              scale: _down ? 0.95 : 1,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: widget.height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius),
                  gradient: LinearGradient(
                    begin: Alignment(math.cos(a), math.sin(a)),
                    end: Alignment(-math.cos(a), -math.sin(a)),
                    colors: [widget.accentColor, widget.baseColor],
                  ),
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.labelColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      );
}
