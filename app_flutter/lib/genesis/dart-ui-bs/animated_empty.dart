// 🎨 חוט-תצוגה · AnimatedEmpty — מצב-ריק מאויר עם אייקון מרחף (חוק-1/חוק-5).
// המנוע: אייקון שמרחף מעלה-מטה (AnimationController) + כותרת+תת-כותרת. אפס-דאטה —
// אייקון · כותרת · תת-כותרת · גובה · צבע-אייקון/טקסט/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedEmpty extends StatefulWidget {
  const AnimatedEmpty({
    required this.icon,
    required this.title,
    required this.sub,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final IconData icon;
  final String title, sub;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<AnimatedEmpty> createState() => _AnimatedEmptyState();
}

class _AnimatedEmptyState extends State<AnimatedEmpty>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.fillColor,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _c,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, math.sin(_c.value * 2 * math.pi) * 6),
                  child: child,
                ),
                child: Icon(widget.icon,
                    size: widget.height * 0.28, color: widget.accentColor),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.baseColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.sub,
                style: TextStyle(
                  color: widget.baseColor.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
}
