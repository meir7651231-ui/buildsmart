// 🎨 חוט-תצוגה · PinPad — מקלדת-ספרות 3×4 עם הבהוב-הקשה (חוק-1/חוק-5).
// המנוע: רשת-ספרות; הקשה מדגישה מקש בקפיצה קצרה. אפס-דאטה —
// גובה · צבע-מקש/ספרה/רקע מוזרקים; המקש-האחרון הפנימי שלו.
import 'package:flutter/material.dart';
class PinPad extends StatefulWidget {
  const PinPad({required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<PinPad> createState() => _PinPadState();
}
class _PinPadState extends State<PinPad> {
  int _last = -1;
  @override Widget build(BuildContext context) {
    final keys = [1, 2, 3, 4, 5, 6, 7, 8, 9, -1, 0, -2];
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6),
      itemCount: keys.length, itemBuilder: (context, i) {
        final k = keys[i];
        if (k < 0) return k == -2 ? Icon(Icons.backspace_outlined, color: widget.baseColor.withValues(alpha: 0.6)) : const SizedBox();
        final on = _last == i;
        return GestureDetector(onTap: () => setState(() => _last = i),
          child: AnimatedScale(scale: on ? 0.92 : 1, duration: const Duration(milliseconds: 120),
            child: Container(alignment: Alignment.center,
              decoration: BoxDecoration(color: on ? widget.accentColor : widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
              child: Text('$k', style: TextStyle(color: on ? widget.fillColor : widget.baseColor, fontSize: widget.height * 0.09, fontWeight: FontWeight.w700)))));
      });
  }
}
