// 🎨 חוט-תצוגה · PricingCard — כרטיס-מחירון עם מחיר גדול ו-CTA (חוק-1/חוק-5).
// המנוע: כותרת-חבילה + מחיר + שלוש שורות-תכונה + כפתור. אפס-דאטה —
// שם-חבילה · מחיר · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class PricingCard extends StatelessWidget {
  const PricingCard({required this.title, required this.sub, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String title, sub; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override Widget build(BuildContext context) => Container(
    height: height, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(radius * 1.4),
      border: Border.all(color: accentColor.withValues(alpha: 0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: accentColor, fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(sub, style: TextStyle(color: baseColor, fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      for (var i = 0; i < 3; i++) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
        Icon(Icons.check_circle, color: accentColor, size: 16), const SizedBox(width: 8),
        Expanded(child: Container(height: 7, decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(7)))),
      ])),
      const Spacer(),
      Container(height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(radius)),
        child: Icon(Icons.arrow_back, color: fillColor)),
    ]));
}
