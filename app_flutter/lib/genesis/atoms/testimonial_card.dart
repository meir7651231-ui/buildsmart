// 🎨 חוט-תצוגה · TestimonialCard — כרטיס-המלצה עם ציטוט וכוכבים (חוק-1/חוק-5).
// המנוע: ציטוט + אווטאר + שם + חמישה כוכבים. אפס-דאטה —
// ציטוט · שם · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class TestimonialCard extends StatelessWidget {
  const TestimonialCard({required this.title, required this.sub, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String title, sub; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override Widget build(BuildContext context) => Container(
    height: height, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(radius * 1.3)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.format_quote, color: accentColor.withValues(alpha: 0.5), size: 28),
      const SizedBox(height: 4),
      Expanded(child: Text(title, style: TextStyle(color: baseColor, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500))),
      const SizedBox(height: 12),
      Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(Icons.person, color: accentColor, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text(sub, style: TextStyle(color: baseColor, fontSize: 13, fontWeight: FontWeight.w700))),
        Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: accentColor, size: 15))),
      ]),
    ]));
}
