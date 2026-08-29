// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__smart_project_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/project_done.dart';
import '../dart-ui-bs/auto/smart_project_hero.dart';
import '../dart-data-bs/auto/screens__smart_project_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class SmartProjectScreenTokens {
  const SmartProjectScreenTokens();

}

class SmartProjectScreenComposed extends StatelessWidget {
  const SmartProjectScreenComposed({required this.done, required this.pct, required this.title, required this.total, required this.t, super.key});


  final int done;
  final int pct;
  final String title;
  final int total;
  final SmartProjectScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SmartProjectHero(
            label: smart_project_hero_label,
            label2: smart_project_hero_label2,
            title: title,
            done: done,
            total: total,
            pct: pct,
          ),
          ProjectDone(
            fallback: project_done_fallback,
          ),
        ],
      );
}
