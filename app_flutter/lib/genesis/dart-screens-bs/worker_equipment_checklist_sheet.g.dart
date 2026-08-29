// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_equipment_checklist_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/worker_equipment_checklist_sheet_primary_btn.dart';
import '../dart-ui-bs/auto/worker_equipment_checklist_sheet_sec_h.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerEquipmentChecklistSheetTokens {
  const WorkerEquipmentChecklistSheetTokens();

}

class WorkerEquipmentChecklistSheetComposed extends StatelessWidget {
  const WorkerEquipmentChecklistSheetComposed({required this.onTap,VoidCallback?, required this.label, required this.text, required this.t, super.key});

  final VoidCallback? onTap;
  final String label;
  final String text;
  final WorkerEquipmentChecklistSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          WorkerEquipmentChecklistSheetSecH(
            text,
          ),
          WorkerEquipmentChecklistSheetPrimaryBtn(
            label: label,
            onTap: onTap,
          ),
        ],
      );
}
