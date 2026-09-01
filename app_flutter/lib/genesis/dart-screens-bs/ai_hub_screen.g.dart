// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__ai_hub_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/ai_fin_tile.dart';
import '../dart-ui-bs/auto/ai_md_head.dart';
import '../dart-data-bs/auto/screens__ai_hub_screen_content.dart';
import '../dart-data-bs/auto/screens__ai_hub_screen_content2.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class AiFinTileItem {
  const AiFinTileItem({required this.ic, required this.title, required this.sub, required this.onTap});
  final String ic;
  final String title;
  final String sub;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class AiHubScreenTokens {
  const AiHubScreenTokens();

}

class AiHubScreenComposed extends StatelessWidget {
  const AiHubScreenComposed({required this.aiFinTileItems, required this.t, super.key});


  final List<AiFinTileItem> aiFinTileItems;
  final AiHubScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          AiMdHead(
            ic: ai_md_head_ic,
            title: ai_md_head_title,
            sub: ai_md_head_sub,
          ),
          for (final t in aiFinTileItems) ...[
          AiFinTile(
            ic: t.ic,
            title: t.title,
            sub: t.sub,
            onTap: t.onTap,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
