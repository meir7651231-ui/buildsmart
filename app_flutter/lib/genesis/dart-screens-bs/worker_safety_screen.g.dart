// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_safety_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/training_action.dart';
import '../dart-data-bs/auto/screens__worker_safety_screen_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerSafetyScreenTokens {
  const WorkerSafetyScreenTokens();

}

class WorkerSafetyScreenComposed extends StatelessWidget {
  const WorkerSafetyScreenComposed({required this.onTap, required this.icon, required this.t, super.key});

  final VoidCallback onTap;
  final IconData icon;
  final WorkerSafetyScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          TrainingAction(
            icon: icon,
            label: training_action_label,
            onTap: onTap,
          ),
        ],
      );
}
