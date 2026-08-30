// 🎨 חוט-תצוגה · SearchField — שדה-חיפוש עם אייקון מונפש וכפתור-ניקוי (חוק-1/חוק-5).
// המנוע: אייקון-חיפוש שמסתובב-נכנס בפוקוס + כפתור-ניקוי שמופיע כשיש טקסט. אפס-דאטה —
// רמז · גובה · צבע-הדגשה/טקסט/רקע מוזרקים בחיווט; הבקר הפנימי שלו.
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({
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
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: widget.fillColor,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: _focused ? 0.9 : 0.2),
          ),
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: _focused ? 0.05 : 0,
              duration: const Duration(milliseconds: 220),
              child: Icon(Icons.search,
                  color: widget.accentColor.withValues(alpha: 0.9), size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
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
            AnimatedScale(
              scale: _ctrl.text.isEmpty ? 0 : 1,
              duration: const Duration(milliseconds: 180),
              child: GestureDetector(
                onTap: _ctrl.clear,
                child: Icon(Icons.close,
                    color: widget.baseColor.withValues(alpha: 0.5), size: 18),
              ),
            ),
          ],
        ),
      );
}
