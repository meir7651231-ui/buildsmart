// 🎨 חוט-תצוגה · Marquee — כיתוב-רץ אופקי רציף (חוק-1/חוק-5).
// המנוע: הטקסט מוסע שמאלה ברציפות (AnimationController), שני עותקים לתפר-חלק.
// אפס-דאטה — טקסט · גובה · צבע-טקסט/מבטא/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class Marquee extends StatefulWidget {
  const Marquee({
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
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final unit = '${widget.text}      ';
    final w = unit.length * 9.5;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Container(
        height: widget.height,
        color: widget.fillColor,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(-_c.value * w, 0),
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(children: [
                          Icon(Icons.bolt, color: widget.accentColor, size: widget.height * 0.4),
                          const SizedBox(width: 6),
                          Text(unit,
                              style: TextStyle(color: widget.baseColor, fontSize: widget.height * 0.34, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
