// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__courier_portal_tab.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/destination_card.dart';
import '../dart-ui-bs/auto/portal_tile_button.dart';
import '../dart-data-bs/auto/screens__courier_portal_tab_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CourierPortalTabTokens {
  const CourierPortalTabTokens();

}

class CourierPortalTabComposed extends StatelessWidget {
  const CourierPortalTabComposed({required this.onTap, required this.haul, required this.sub, required this.title, required this.t, super.key});

  final VoidCallback onTap;
  final String haul;
  final String sub;
  final String title;
  final CourierPortalTabTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          PortalTileButton(
            title: title,
            sub: sub,
            onTap: onTap,
          ),
          DestinationCard(
            fallback: destination_card_fallback,
            haul: haul,
          ),
        ],
      );
}
