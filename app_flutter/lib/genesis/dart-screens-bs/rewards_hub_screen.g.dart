// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__rewards_hub_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/coin_banner.dart';
import '../dart-ui-bs/auto/fin_tile.dart';
import '../dart-ui-bs/auto/md_head.dart';
import '../dart-data-bs/auto/screens__rewards_hub_screen_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class FinTileItem {
  const FinTileItem({required this.ic, required this.title, required this.sub, required this.onTap});
  final String ic;
  final String title;
  final String sub;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class RewardsHubScreenTokens {
  const RewardsHubScreenTokens();

}

class RewardsHubScreenComposed extends StatelessWidget {
  const RewardsHubScreenComposed({required this.coins, required this.finTileItems, required this.ic, required this.sub, required this.title, required this.t, super.key});


  final int coins;
  final List<FinTileItem> finTileItems;
  final String ic;
  final String sub;
  final String title;
  final RewardsHubScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          MdHead(
            ic: ic,
            title: title,
            sub: sub,
          ),
          CoinBanner(
            coins: coins,
            sub: sub,
          ),
          for (final t in finTileItems) ...[
          FinTile(
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
