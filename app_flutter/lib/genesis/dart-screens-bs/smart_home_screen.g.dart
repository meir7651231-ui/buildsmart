// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__smart_home_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/pad.dart';
import '../dart-ui-bs/auto/section_title.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class SmartHomeScreenTokens {
  const SmartHomeScreenTokens();

}

class SmartHomeScreenComposed extends StatelessWidget {
  const SmartHomeScreenComposed({required this.child, required this.emoji, required this.subtitle, required this.title, required this.t, super.key});


  final Widget child;
  final String emoji;
  final String? subtitle;
  final String title;
  final SmartHomeScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Pad(
            child: child,
          ),
          SectionTitle(
            emoji: emoji,
            title: title,
            subtitle: subtitle,
          ),
        ],
      );
}
