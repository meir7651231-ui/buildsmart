// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_employer_stock_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/request_composer.dart';
import '../dart-ui-bs/auto/worker_employer_stock_sheet_stock_row.dart';
import '../dart-data-bs/auto/screens__worker_employer_stock_sheet_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerEmployerStockSheetTokens {
  const WorkerEmployerStockSheetTokens();

}

class WorkerEmployerStockSheetComposed extends StatelessWidget {
  const WorkerEmployerStockSheetComposed({required this.onSend, required this.onToggle, required this.composing, required this.itemsCtrl, required this.location, required this.name, required this.noteCtrl, required this.t, super.key});

  final VoidCallback onSend;
  final VoidCallback onToggle;
  final bool composing;
  final TextEditingController itemsCtrl;
  final String location;
  final String name;
  final TextEditingController noteCtrl;
  final WorkerEmployerStockSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          WorkerEmployerStockSheetStockRow(
            label: worker_employer_stock_sheet_stock_row_label,
            label2: worker_employer_stock_sheet_stock_row_label2,
            location: location,
            name: name,
          ),
          RequestComposer(
            fallback: request_composer_fallback,
            fallback2: request_composer_fallback2,
            fallback3: request_composer_fallback3,
            hintText: request_composer_hint_text,
            labelText: request_composer_label_text,
            hintText2: request_composer_hint_text2,
            fallback4: request_composer_fallback4,
            fallback5: request_composer_fallback5,
            composing: composing,
            itemsCtrl: itemsCtrl,
            noteCtrl: noteCtrl,
            onToggle: onToggle,
            onSend: onSend,
          ),
        ],
      );
}
