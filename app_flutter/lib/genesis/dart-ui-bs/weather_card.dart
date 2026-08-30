// 🎨 חוט-תצוגה · WeatherCard — כרטיס-מזג-אוויר עם גרדיאנט ואייקון (חוק-1/חוק-5).
// המנוע: טמפרטורה גדולה + תיאור + אייקון-שמש שמסתובב עדין (AnimationController).
// אפס-דאטה — טמפרטורה · תיאור · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';
class WeatherCard extends StatefulWidget {
  const WeatherCard({required this.title, required this.sub, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String title, sub; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<WeatherCard> createState() => _WeatherCardState();
}
class _WeatherCardState extends State<WeatherCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Container(
    height: widget.height, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.radius * 1.4), gradient: LinearGradient(
      begin: Alignment.topRight, end: Alignment.bottomLeft,
      colors: [widget.accentColor, Color.lerp(widget.accentColor, widget.baseColor, 0.65) ?? widget.baseColor])),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(widget.title, style: TextStyle(color: widget.fillColor, fontSize: 40, fontWeight: FontWeight.w900)),
        Text(widget.sub, style: TextStyle(color: widget.fillColor.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w600)),
      ])),
      AnimatedBuilder(animation: _c, builder: (context, child) => Transform.rotate(angle: _c.value * 2 * math.pi, child: child),
        child: Icon(Icons.wb_sunny, color: widget.fillColor, size: 48)),
    ]));
}
