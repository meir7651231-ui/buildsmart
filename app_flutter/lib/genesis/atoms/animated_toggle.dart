// 🎨 חוט-תצוגה · AnimatedToggle — מתג-החלקה מונפש (חוק-1/חוק-5).
// המנוע: כדור-מתג שמחליק בין שני קצוות + מסלול שמשנה צבע (AnimatedAlign/Container).
// אפס-דאטה — תווית · גובה · צבע-דלוק/כדור/כבוי מוזרקים; המצב הפנימי שלו.
import 'package:flutter/material.dart';

class AnimatedToggle extends StatefulWidget {
  const AnimatedToggle({
    required this.label,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final String label;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  bool _on = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.label,
            style: TextStyle(color: widget.baseColor, fontSize: 15),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _on = !_on),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            width: h * 1.9,
            height: h,
            padding: const EdgeInsets.all(3),
            alignment: _on ? Alignment.centerLeft : Alignment.centerRight,
            decoration: BoxDecoration(
              color: _on
                  ? widget.accentColor
                  : widget.fillColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(h),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: _on ? 0 : 0.4),
              ),
            ),
            child: Container(
              width: h - 6,
              height: h - 6,
              decoration: BoxDecoration(
                color: widget.baseColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
