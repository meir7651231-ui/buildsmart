// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__contractor_tools_sheets.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/contractor_tools_sheets_sheet_handle.dart';
import '../dart-data-bs/auto/screens__contractor_tools_sheets_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ContractorToolsSheetsTokens {
  const ContractorToolsSheetsTokens();

}

class ContractorToolsSheetsComposed extends StatelessWidget {
  const ContractorToolsSheetsComposed({required this.onPressed,VoidCallback, required this.t, super.key});

  final VoidCallback onPressed;

  final ContractorToolsSheetsTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          ContractorToolsSheetsSheetHandle(
            label: contractor_tools_sheets_sheet_handle_label,
            tooltip: contractor_tools_sheets_sheet_handle_tooltip,
            onPressed: onPressed,
          ),
        ],
      );
}
