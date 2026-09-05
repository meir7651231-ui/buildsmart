// 🧼 חוט-תצוגה · WorkPathCard — כרטיס-מסלול-עבודה. מנגנון-בלבד: אפס תוכן,
// אפס מודולים, אפס store. כל הטקסטים/צבעים/פעולה מוזרקים. מוצא: _WorkPath
// (smart_home_screen.dart) אחרי חילוץ-הדאטה ל-dart-data-bs/home_content.dart.
import 'package:flutter/material.dart';

class WorkPathCard extends StatelessWidget {
  const WorkPathCard({
    required this.badge, required this.title, required this.sub,
    required this.gradStart, required this.gradEnd, required this.radius,
    this.pillRadius = 999, super.key,
  });
  final String badge, title, sub;
  final Color gradStart, gradEnd;
  final double radius, pillRadius;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [gradStart, gradEnd]),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(pillRadius),
              ),
              child: Text(badge,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      );
}
