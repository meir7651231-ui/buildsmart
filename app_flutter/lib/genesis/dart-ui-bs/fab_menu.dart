// 🎨 חוט-תצוגה · FabMenu — כפתור-צף שנפתח לתפריט-מיני (חוק-1/חוק-5).
// המנוע: הקשה מסובבת + ⇒ × ופורשת 3 כפתורי-מיני כלפי-מעלה (Animated*). אפס-דאטה —
// גובה · צבע-כפתור/אייקון/מיני מוזרקים בחיווט; מצב-הפתיחה הפנימי שלו.
import 'package:flutter/material.dart';

class FabMenu extends StatefulWidget {
  const FabMenu({
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
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> {
  bool _open = false;
  static const _icons = [Icons.edit, Icons.share, Icons.favorite];

  @override
  Widget build(BuildContext context) {
    final s = widget.height;
    return SizedBox(
      height: s * 3.4,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          for (var i = 0; i < 3; i++)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              bottom: _open ? s * (1.1 + i * 0.75) : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _open ? 1 : 0,
                child: Container(
                  width: s * 0.72, height: s * 0.72,
                  decoration: BoxDecoration(color: widget.fillColor, shape: BoxShape.circle,
                      border: Border.all(color: widget.accentColor.withValues(alpha: 0.5))),
                  child: Icon(_icons[i], color: widget.accentColor, size: s * 0.34),
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
