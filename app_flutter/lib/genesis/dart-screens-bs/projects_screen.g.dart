// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__projects_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/link_btn.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ProjectsScreenTokens {
  const ProjectsScreenTokens();

}

class ProjectsScreenComposed extends StatelessWidget {
  const ProjectsScreenComposed({required this.onTap,VoidCallback, required this.label, required this.t, super.key});

  final VoidCallback onTap;
  final String label;
  final ProjectsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          LinkBtn(
            label: label,
            onTap: onTap,
          ),
        ],
      );
}
