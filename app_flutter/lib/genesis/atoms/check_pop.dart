// 🎨 חוט-תצוגה · CheckPop — תיבת-סימון עם וי מצויר וקפיצה (חוק-1/חוק-5).
// המנוע: התיבה מתמלאת + הוי נכנס בקפיצת-סקייל (AnimatedScale/Container). אפס-דאטה —
// תווית · גובה · צבע-סימון/וי/רקע מוזרקים; המצב הפנימי שלו.
import 'package:flutter/material.dart';

class CheckPop extends StatefulWidget {
  const CheckPop({
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
  State<CheckPop> createState() => _CheckPopState();
}

class _CheckPopState extends State<CheckPop> {
  bool _on = false;

  @override
  Widget build(BuildContext context) {
    final box = widget.height;
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: _on ? widget.accentColor : widget.fillColor,
              borderRadius: BorderRadius.circular(widget.radius * 0.5),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: _on ? 1 : 0.4),
                width: 1.5,
              ),
            ),
            child: AnimatedScale(
              scale: _on ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(Icons.check, color: widget.baseColor, size: box * 0.7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(color: widget.baseColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
