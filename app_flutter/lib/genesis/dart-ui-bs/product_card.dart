// 🎨 חוט-תצוגה · ProductCard — כרטיס-מוצר עם תמונה ומחיר (חוק-1/חוק-5).
// המנוע: משטח-תמונה גרדיאנט + שם + מחיר + כפתור-קנייה. אפס-דאטה —
// שם · מחיר · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class ProductCard extends StatelessWidget {
  const ProductCard({required this.title, required this.sub, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String title, sub; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override Widget build(BuildContext context) => Container(
    height: height, clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(radius * 1.3)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(child: Container(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topRight, end: Alignment.bottomLeft,
        colors: [accentColor.withValues(alpha: 0.7), Color.lerp(accentColor, baseColor, 0.6) ?? baseColor])),
        child: Icon(Icons.image, color: fillColor.withValues(alpha: 0.6), size: 40))),
      Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: baseColor, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.w900)),
        ])),
        Container(width: 40, height: 40, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(radius)),
          child: Icon(Icons.add_shopping_cart, color: fillColor, size: 20)),
      ])),
    ]));
}
