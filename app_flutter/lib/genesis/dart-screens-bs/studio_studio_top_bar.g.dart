// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__studio__studio_top_bar.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/draft_badge.dart';
import '../dart-data-bs/auto/screens__studio__studio_top_bar_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class StudioStudioTopBarTokens {
  const StudioStudioTopBarTokens();

}

class StudioStudioTopBarComposed extends StatelessWidget {
  const StudioStudioTopBarComposed({required this.count, required this.t, super.key});


  final int count;
  final StudioStudioTopBarTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          DraftBadge(
            label: draft_badge_label,
            label2: draft_badge_label2,
            label3: draft_badge_label3,
            count: count,
          ),
        ],
      );
}
