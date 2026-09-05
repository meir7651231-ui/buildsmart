// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__persona_portal.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/portal_tile_button.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class PortalTileButtonItem {
  const PortalTileButtonItem({required this.title, required this.sub, required this.onTap});
  final String title;
  final String sub;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class PersonaPortalTokens {
  const PersonaPortalTokens();

}

class PersonaPortalComposed extends StatelessWidget {
  const PersonaPortalComposed({required this.portalTileButtonItems, required this.t, super.key});


  final List<PortalTileButtonItem> portalTileButtonItems;
  final PersonaPortalTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          for (final t in portalTileButtonItems) ...[
          PortalTileButton(
            title: t.title,
            sub: t.sub,
            onTap: t.onTap,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
