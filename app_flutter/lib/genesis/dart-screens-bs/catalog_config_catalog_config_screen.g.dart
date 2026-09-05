// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: features__catalog_config__catalog_config_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/catalog_config_catalog_config_count_badge.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/auto/material_dots.dart';
import '../dart-data-bs/auto/features__catalog_config__catalog_config_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CatalogConfigCatalogConfigScreenTokens {
  const CatalogConfigCatalogConfigScreenTokens();

}

class CatalogConfigCatalogConfigScreenComposed extends StatelessWidget {
  const CatalogConfigCatalogConfigScreenComposed({required this.count, required this.index, required this.t, super.key});


  final int count;
  final int index;
  final CatalogConfigCatalogConfigScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          EmptyState(
            label: empty_state_label,
          ),
          CatalogConfigCatalogConfigCountBadge(
            count: count,
          ),
          MaterialDots(
            count: count,
            index: index,
          ),
        ],
      );
}
