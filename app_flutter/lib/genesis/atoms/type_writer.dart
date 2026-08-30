// 🎨 חוט-תצוגה · TypeWriter — טקסט שמוקלד אות-אות עם סמן מהבהב (חוק-1/חוק-5).
// המנוע: אורך-התצוגה גדל 0→מלא ואז מתחיל מחדש (AnimationController), סמן מהבהב.
// אפס-דאטה — טקסט · גובה · צבע-טקסט/סמן/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class TypeWriter extends StatefulWidget {
  const TypeWriter({
    required this.text,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final String text;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<TypeWriter> createState() => _TypeWriterState();
}

class _TypeWriterState extends State<TypeWriter> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final chars = widget.text.characters;
            final typed = (_c.value * 1.3).clamp(0.0, 1.0);
            final n = (typed * chars.length).floor();
            final shown = chars.take(n).toString();
            final cursorOn = (_c.value * 8).floor().isEven;
            return Text.rich(TextSpan(children: [
              TextSpan(text: shown, style: TextStyle(color: widget.baseColor, fontSize: 16, fontWeight: FontWeight.w600)),
              TextSpan(text: cursorOn ? '▏' : ' ', style: TextStyle(color: widget.accentColor, fontSize: 16)),
            ]));
          },
        ),
      );
}
