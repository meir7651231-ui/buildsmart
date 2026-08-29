// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__site_hub_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/hub_tile.dart';
import '../dart-ui-bs/auto/site_server_note.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class HubTileItem {
  const HubTileItem({required this.ic, required this.t, required this.s, required this.onTap});
  final String ic;
  final String t;
  final String s;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class SiteHubScreenTokens {
  const SiteHubScreenTokens();

}

class SiteHubScreenComposed extends StatelessWidget {
  const SiteHubScreenComposed({required this.hubTileItems, required this.text, required this.t, super.key});


  final List<HubTileItem> hubTileItems;
  final String text;
  final SiteHubScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          for (final t in hubTileItems) ...[
          HubTile(
            ic: t.ic,
            t: t.t,
            s: t.s,
            onTap: t.onTap,
          ),
          const SizedBox(height: 8),
        ],
          SiteServerNote(
            text: text,
          ),
        ],
      );
}
