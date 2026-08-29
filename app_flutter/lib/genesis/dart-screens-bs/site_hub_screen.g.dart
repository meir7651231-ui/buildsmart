// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__site_hub_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/ca_pill.dart';
import '../dart-ui-bs/auto/ca_sub_title.dart';
import '../dart-ui-bs/auto/card_done.dart';
import '../dart-ui-bs/auto/card_top.dart';
import '../dart-ui-bs/auto/hub_tile.dart';
import '../dart-ui-bs/auto/site_hub_ca_card.dart';
import '../dart-ui-bs/auto/site_hub_ca_empty.dart';
import '../dart-ui-bs/auto/site_hub_ca_primary.dart';
import '../dart-ui-bs/auto/site_hub_card_btn.dart';
import '../dart-ui-bs/auto/site_hub_md_head.dart';
import '../dart-ui-bs/auto/site_server_note.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class SiteHubCaCardItem {
  const SiteHubCaCardItem({required this.child});
  final Widget child;
}

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
  const SiteHubScreenComposed({required this.onTap, required this.done, required this.hubTileItems, required this.icon, required this.label, required this.left, required this.overdue, required this.siteHubCaCardItems, required this.sub, required this.text, required this.title, required this.trailing, required this.t, super.key});

  final VoidCallback onTap;
  final bool done;
  final List<HubTileItem> hubTileItems;
  final String icon;
  final String label;
  final String left;
  final bool overdue;
  final List<SiteHubCaCardItem> siteHubCaCardItems;
  final String sub;
  final String text;
  final String title;
  final Widget trailing;
  final SiteHubScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SiteHubMdHead(
            icon: icon,
            title: title,
            sub: sub,
          ),
          for (final p in siteHubCaCardItems) ...[
          SiteHubCaCard(
            child: p.child,
            overdue: overdue,
          ),
          const SizedBox(height: 8),
        ],
          SiteHubCaPrimary(
            label: label,
            onTap: onTap,
          ),
          CaSubTitle(
            text: text,
          ),
          SiteHubCaEmpty(
            text: text,
          ),
          SiteServerNote(
            text: text,
          ),
          CaPill(
            label: label,
            done: done,
          ),
          CardTop(
            left: left,
            trailing: trailing,
          ),
          SiteHubCardBtn(
            label: label,
            onTap: onTap,
          ),
          CardDone(
            text: text,
          ),
          for (final t in hubTileItems) ...[
          HubTile(
            ic: t.ic,
            t: t.t,
            s: t.s,
            onTap: t.onTap,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
