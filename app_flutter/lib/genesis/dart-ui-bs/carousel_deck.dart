// 🎨 חוט-תצוגה · CarouselDeck — קרוסלת-כרטיסים בהחלקה עם נקודות (חוק-1/חוק-5).
// המנוע: PageView של כרטיסים; הכרטיס-הפעיל גדל, נקודות-החיווי מתעדכנות. אפס-דאטה —
// תוויות-הכרטיסים · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט; המיקום הפנימי שלו.
import 'package:flutter/material.dart';

class CarouselDeck extends StatefulWidget {
  const CarouselDeck({
    required this.labels,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final List<String> labels;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<CarouselDeck> createState() => _CarouselDeckState();
}

class _CarouselDeckState extends State<CarouselDeck> {
  late final PageController _pc = PageController(viewportFraction: 0.82);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pc.addListener(() => setState(() => _page = _pc.page ?? 0));
  }

  @override
  void dispose() { _pc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels.isEmpty ? const ['—'] : widget.labels;
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pc,
            itemCount: labels.length,
            itemBuilder: (context, i) {
              final scale = (1 - (_page - i).abs() * 0.12).clamp(0.85, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.accentColor, Color.lerp(widget.accentColor, widget.baseColor, 0.6) ?? widget.baseColor],
                      begin: Alignment.topRight, end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(widget.radius * 1.4),
                  ),
                  child: Text(labels[i],
                      style: TextStyle(color: widget.fillColor, fontSize: 20, fontWeight: FontWeight.w900)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(labels.length, (i) {
            final on = (_page.round()) == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: on ? 20 : 7, height: 7,
              decoration: BoxDecoration(
                color: on ? widget.accentColor : widget.baseColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(7),
              ),
            );
          }),
        ),
      ],
    );
  }
}
