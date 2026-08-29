// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__manager_profile_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/rstat.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ManagerProfileScreenTokens {
  const ManagerProfileScreenTokens();

}

class ManagerProfileScreenComposed extends StatelessWidget {
  const ManagerProfileScreenComposed({required this.label, required this.value, required this.t, super.key});


  final String label;
  final String value;
  final ManagerProfileScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          RStat(
            value: value,
            label: label,
          ),
        ],
      );
}
