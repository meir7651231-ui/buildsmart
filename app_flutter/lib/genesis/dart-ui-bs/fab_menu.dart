// 🎨 חוט-תצוגה · FabMenu — כפתור-צף שנפתח לתפריט-מיני (חוק-1/חוק-5).
// המנוע: הקשה מסובבת + ⇒ × ופורשת כפתור-מיני לכל פעולה כלפי-מעלה (Animated*).
// תפר-דאטה (G21 · §20-ג): labels = הפעולות האמיתיות (עד 3, ראשי-תיבות על הכפתור) · onSelect(i) — מוזרקים בחיווט.
// עיצוב — גובה · צבע-כפתור/אייקון/מיני מוזרקים בחיווט; מצב-הפתיחה הפנימי שלו.
import 'package:flutter/material.dart';

class FabMenu extends StatefulWidget {
  const FabMenu({
    required this.labels,
    required this.onSelect,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  /// הפעולות (שקע-דאטה).
  final List<String> labels;
  /// בחירת-פעולה לפי אינדקס (שקע-קלט).
  final ValueChanged<int> onSelect;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.height;
    return SizedBox(
      height: s * 3.4,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          for (var i = 0; i < widget.labels.length && i < 3; i++)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              bottom: _open ? s * (1.1 + i * 0.75) : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _open ? 1 : 0,
                child: GestureDetector(
                  onTap: () { setState(() => _open = false); widget.onSelect(i); },
                  child: Container(
                    width: s * 0.72, height: s * 0.72, alignment: Alignment.center,
                    decoration: BoxDecoration(color: widget.fillColor, shape: BoxShape.circle,
                        border: Border.all(color: widget.accentColor.withValues(alpha: 0.5))),
                    child: Text(widget.labels[i].trim().isEmpty ? '·' : widget.labels[i].trim().substring(0, 1),
                        style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.w800, fontSize: s * 0.3)),
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: AnimatedRotation(
              turns: _open ? 0.125 : 0,
              duration: const Duration(milliseconds: 260),
              child: Container(
                width: s, height: s,
                decoration: BoxDecoration(
                  color: widget.accentColor, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: widget.accentColor.withValues(alpha: 0.5), blurRadius: 16)],
                ),
                child: Icon(Icons.add, color: widget.baseColor, size: s * 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
