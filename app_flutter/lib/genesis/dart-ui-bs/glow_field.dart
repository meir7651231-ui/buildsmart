// 🎨 חוט-תצוגה · GlowField — שדה-קלט עם הילת-מיקוד מונפשת (חוק-1/חוק-5).
// המנוע: מסגרת+צל שמתעצמים בפוקוס (AnimatedContainer + FocusNode). אפס-דאטה —
// רמז · גובה · צבע-מיקוד/טקסט/רקע מוזרקים בחיווט; הבקר הפנימי שלו.
import 'package:flutter/material.dart';

class GlowField extends StatefulWidget {
  const GlowField({
    required this.hint,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final String hint;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<GlowField> createState() => _GlowFieldState();
}

class _GlowFieldState extends State<GlowField> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: widget.fillColor,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: _focused ? 0.95 : 0.25),
            width: _focused ? 1.8 : 1,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                  ),
                ]
              : const [],
        ),
        child: Center(
          child: TextField(
            controller: _ctrl,
            focusNode: _node,
            cursorColor: widget.accentColor,
            style: TextStyle(color: widget.baseColor, fontSize: 15),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: widget.baseColor.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      );
}
