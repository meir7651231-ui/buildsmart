// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__ai_hub_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/ai_bar.dart';
import '../dart-ui-bs/auto/ai_card.dart';
import '../dart-ui-bs/auto/ai_card_btn.dart';
import '../dart-ui-bs/auto/ai_card_sub.dart';
import '../dart-ui-bs/auto/ai_card_top.dart';
import '../dart-ui-bs/auto/ai_fin_tile.dart';
import '../dart-ui-bs/auto/ai_md_head.dart';
import '../dart-ui-bs/auto/ai_primary.dart';
import '../dart-ui-bs/auto/ai_server_note.dart';
import '../dart-ui-bs/auto/three_col.dart';
import '../dart-ui-bs/auto/three_way.dart';
import '../dart-ui-bs/auto/wear.dart';
import '../dart-data-bs/auto/screens__ai_hub_screen_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class AiFinTileItem {
  const AiFinTileItem({required this.ic, required this.title, required this.sub, required this.onTap});
  final String ic;
  final String title;
  final String sub;
  final VoidCallback onTap;
}

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class AiCardItem {
  const AiCardItem({required this.child, required this.overdue});
  final Widget child;
  final bool overdue;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class AiHubScreenTokens {
  const AiHubScreenTokens();

}

class AiHubScreenComposed extends StatelessWidget {
  const AiHubScreenComposed({required this.onTap, required this.aiCardItems, required this.aiFinTileItems, required this.bad, required this.danger, required this.ic, required this.label, required this.pct, required this.pill, required this.sub, required this.text, required this.title, required this.value, required this.t, super.key});

  final VoidCallback onTap;
  final List<AiCardItem> aiCardItems;
  final List<AiFinTileItem> aiFinTileItems;
  final bool bad;
  final bool danger;
  final String ic;
  final String label;
  final int pct;
  final String pill;
  final String sub;
  final String text;
  final String title;
  final String value;
  final AiHubScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          AiMdHead(
            ic: ic,
            title: title,
            sub: sub,
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
          ThreeWay(
            title: three_way_title,
            sub: three_way_sub,
            text: three_way_text,
            pill: three_way_pill,
            pill2: three_way_pill2,
            label: three_way_label,
            label2: three_way_label2,
            label3: three_way_label3,
            fallback: three_way_fallback,
          ),
          Wear(
            title: wear_title,
            sub: wear_sub,
            text: wear_text,
            text2: wear_text2,
            fallback: wear_fallback,
          ),
          AiServerNote(
            text: text,
          ),
          for (final p in aiCardItems) ...[
          AiCard(
            child: p.child,
            overdue: p.overdue,
          ),
          const SizedBox(height: 8),
        ],
          AiCardSub(
            text: text,
          ),
          AiCardTop(
            title: title,
            pill: pill,
            danger: danger,
          ),
          AiCardBtn(
            label: label,
            onTap: onTap,
          ),
          ThreeCol(
            label: label,
            value: value,
            bad: bad,
          ),
          AiBar(
            pct: pct,
            danger: danger,
          ),
          AiPrimary(
            label: label,
            onTap: onTap,
          ),
        ],
      );
}
