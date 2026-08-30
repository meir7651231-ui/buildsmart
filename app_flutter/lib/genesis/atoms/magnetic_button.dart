// 🎨 חוט-תצוגה · MagneticButton — כפתור "מגנטי": קפיצת-סקייל + הרמת-צל בלחיצה (חוק-1/חוק-5).
// המנוע: תגובת-מגע קפיצית (AnimatedScale + צל דינמי). אפס-דאטה —
// תווית · גובה · צבע-מילוי/טקסט · onPressed מוזרקים בחיווט.
import 'package:flutter/material.dart';

class MagneticButton extends StatefulWidget {
  const MagneticButton({
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
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          widget.onPressed();
        },
        child: AnimatedScale(
          scale: _down ? 1.06 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: widget.height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: widget.accentColor,
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withValues(alpha: _down ? 0.55 : 0.28),
                  blurRadius: _down ? 26 : 12,
                  offset: Offset(0, _down ? 10 : 5),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.baseColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
}
