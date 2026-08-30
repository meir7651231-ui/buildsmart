// 🎨 חוט-תצוגה · ProfileCard — כרטיס-פרופיל עם אווטאר ומדדים (חוק-1/חוק-5).
// המנוע: עיגול-אווטאר + שם + תפקיד + שורת-מדדים. אפס-דאטה —
// שם · תפקיד · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class ProfileCard extends StatelessWidget {
  const ProfileCard({required this.title, required this.sub, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String title, sub; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override Widget build(BuildContext context) => Container(
    height: height, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(radius * 1.4)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accentColor, Color.lerp(accentColor, baseColor, 0.5) ?? baseColor]), shape: BoxShape.circle),
        child: Icon(Icons.person, color: fillColor, size: 34)),
      const SizedBox(height: 12),
      Text(title, style: TextStyle(color: baseColor, fontSize: 17, fontWeight: FontWeight.w800)),
      Text(sub, style: TextStyle(color: baseColor.withValues(alpha: 0.6), fontSize: 13)),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(3, (i) => Column(children: [
        Container(width: 30, height: 10, decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 5),
        Container(width: 20, height: 6, decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6))),
      ]))),
    ]));
}
