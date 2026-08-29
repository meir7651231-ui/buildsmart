// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__projects_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/link_btn.dart';
import '../dart-ui-bs/auto/site_card.dart';
import '../dart-data-bs/auto/screens__projects_screen_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class SiteCardItem {
  const SiteCardItem({required this.isActive, required this.onSwitch, required this.onStatus, required this.onCart});
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback onStatus;
  final VoidCallback onCart;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ProjectsScreenTokens {
  const ProjectsScreenTokens();

}

class ProjectsScreenComposed extends StatelessWidget {
  const ProjectsScreenComposed({required this.onTap, required this.addr, required this.label, required this.name, required this.siteCardItems, required this.t, super.key});

  final VoidCallback onTap;
  final String addr;
  final String label;
  final String name;
  final List<SiteCardItem> siteCardItems;
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
          for (final p in siteCardItems) ...[
          SiteCard(
            label: site_card_label,
            label2: site_card_label2,
            label3: site_card_label3,
            label4: site_card_label4,
            label5: site_card_label5,
            fallback: site_card_fallback,
            name: name,
            addr: addr,
            isActive: p.isActive,
            onSwitch: p.onSwitch,
            onStatus: p.onStatus,
            onCart: p.onCart,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
