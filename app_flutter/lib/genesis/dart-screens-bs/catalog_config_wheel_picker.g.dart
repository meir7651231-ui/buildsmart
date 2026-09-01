// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: features__catalog_config__wheel_picker.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/selection_band.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CatalogConfigWheelPickerTokens {
  const CatalogConfigWheelPickerTokens();

}

class CatalogConfigWheelPickerComposed extends StatelessWidget {
  const CatalogConfigWheelPickerComposed({required this.t, super.key});



  final CatalogConfigWheelPickerTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SelectionBand(
            
          ),
        ],
      );
}
