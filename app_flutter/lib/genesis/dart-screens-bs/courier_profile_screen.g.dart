// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__courier_profile_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/courier_personal_area_card.dart';
import '../dart-ui-bs/auto/stat.dart';
import '../dart-data-bs/auto/screens__courier_profile_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CourierProfileScreenTokens {
  const CourierProfileScreenTokens();

}

class CourierProfileScreenComposed extends StatelessWidget {
  const CourierProfileScreenComposed({required this.onTap,VoidCallback, required this.onTap2,VoidCallback, required this.onTap3,VoidCallback, required this.onTap4,VoidCallback, required this.label, required this.value, required this.t, super.key});

  final VoidCallback onTap;
  final VoidCallback onTap2;
  final VoidCallback onTap3;
  final VoidCallback onTap4;
  final String label;
  final String value;
  final CourierProfileScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Stat(
            value: value,
            label: label,
          ),
          CourierPersonalAreaCard(
            title: courier_personal_area_card_title,
            body: courier_personal_area_card_body,
            fallback: courier_personal_area_card_fallback,
            fallback2: courier_personal_area_card_fallback2,
            title2: courier_personal_area_card_title2,
            body2: courier_personal_area_card_body2,
            fallback3: courier_personal_area_card_fallback3,
            fallback4: courier_personal_area_card_fallback4,
            title3: courier_personal_area_card_title3,
            body3: courier_personal_area_card_body3,
            fallback5: courier_personal_area_card_fallback5,
            fallback6: courier_personal_area_card_fallback6,
            title4: courier_personal_area_card_title4,
            body4: courier_personal_area_card_body4,
            fallback7: courier_personal_area_card_fallback7,
            fallback8: courier_personal_area_card_fallback8,
            onTap: onTap,
            onTap2: onTap2,
            onTap3: onTap3,
            onTap4: onTap4,
          ),
        ],
      );
}
