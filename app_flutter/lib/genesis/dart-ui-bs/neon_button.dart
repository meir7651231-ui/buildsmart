// 🎨 חוט-תצוגה · NeonButton — כפתור-ניאון עם הילה נושמת + לחיצה-מכווצת (חוק-1/חוק-5).
// המנוע: מסגרת-זוהר שפועמת (AnimationController) + כיווץ-סקייל בלחיצה. אפס-דאטה —
// תווית · גובה · צבע-ניאון/רקע · onPressed מוזרקים בחיווט.
import 'package:flutter/material.dart';

class NeonButton extends StatefulWidget {
  const NeonButton({
    required this.label,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.onPressed,
    super.key,
  });

  final String label;
  final double height, radius;
  final Color accentColor, baseColor;
  final VoidCallback onPressed;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);
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
          final g = 0.4 + 0.6 * _c.value;
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
                  color: widget.baseColor,
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.5 * g),
                      blurRadius: 18 * g,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      );
}
