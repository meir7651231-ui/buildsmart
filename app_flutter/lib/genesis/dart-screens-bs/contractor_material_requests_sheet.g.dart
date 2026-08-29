// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__contractor_material_requests_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/action_button.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ContractorMaterialRequestsSheetTokens {
  const ContractorMaterialRequestsSheetTokens({required this.color});
  final Color color;
}

class ContractorMaterialRequestsSheetComposed extends StatelessWidget {
  const ContractorMaterialRequestsSheetComposed({required this.onTap, required this.label, required this.t, super.key});

  final VoidCallback onTap;
  final String label;
  final ContractorMaterialRequestsSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          ActionButton(
            label: label,
            color: t.color,
            onTap: onTap,
          ),
        ],
      );
}
