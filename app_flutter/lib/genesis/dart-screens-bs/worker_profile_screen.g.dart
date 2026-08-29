// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_profile_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/stats_card.dart';
import '../dart-data-bs/auto/screens__worker_profile_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerProfileScreenTokens {
  const WorkerProfileScreenTokens();

}

class WorkerProfileScreenComposed extends StatelessWidget {
  const WorkerProfileScreenComposed({required this.done, required this.inReview, required this.rejected, required this.total, required this.t, super.key});


  final int done;
  final int inReview;
  final int rejected;
  final int total;
  final WorkerProfileScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          StatsCard(
            fallback: stats_card_fallback,
            label: stats_card_label,
            label2: stats_card_label2,
            label3: stats_card_label3,
            done: done,
            inReview: inReview,
            rejected: rejected,
            total: total,
          ),
        ],
      );
}
