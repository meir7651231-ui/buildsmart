// 🎨 חוט-תצוגה · ColorSwatchRow — בורר-צבעים בגלגול-גוון (חוק-1/חוק-5).
// המנוע: N דגימות בגוונים נגזרים מהמבטא (סיבוב-גוון HSL); הקשה מסמנת בטבעת.
// אפס-דאטה — גובה · מספר-דגימות · צבע-מבטא/מסגרת/רקע מוזרקים; הבחירה הפנימית שלו.
import 'package:flutter/material.dart';
class ColorSwatchRow extends StatefulWidget {
  const ColorSwatchRow({required this.height, required this.swatches, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final double height; final int swatches; final double radius;
  final Color accentColor, baseColor, fillColor;
  @override State<ColorSwatchRow> createState() => _ColorSwatchRowState();
}
class _ColorSwatchRowState extends State<ColorSwatchRow> {
  int _sel = 0;
  @override Widget build(BuildContext context) {
    final n = (widget.swatches < 1 ? 1 : widget.swatches).clamp(1, 10);
    final base = HSLColor.fromColor(widget.accentColor);
    return SizedBox(height: widget.height, child: Row(mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(n, (i) {
        final c = base.withHue((base.hue + i * (360 / n)) % 360).toColor();
        final on = i == _sel; final d = widget.height.clamp(24.0, 48.0);
        return GestureDetector(onTap: () => setState(() => _sel = i),
          child: AnimatedContainer(duration: const Duration(milliseconds: 180),
            width: d, height: d, margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(color: c, shape: BoxShape.circle,
              border: Border.all(color: on ? widget.baseColor : Colors.transparent, width: 3))));
      })));
  }
}
