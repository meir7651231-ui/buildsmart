// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_task_detail_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/worker_equipment_checklist_sheet_sec_h.dart';
import '../dart-ui-bs/auto/worker_task_detail_sheet_primary_btn.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerTaskDetailSheetTokens {
  const WorkerTaskDetailSheetTokens();

}

class WorkerTaskDetailSheetComposed extends StatelessWidget {
  const WorkerTaskDetailSheetComposed({required this.onTap, required this.label, required this.text, required this.t, super.key});

  final VoidCallback onTap;
  final String label;
  final String text;
  final WorkerTaskDetailSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          WorkerEquipmentChecklistSheetSecH(
            text,
          ),
          WorkerTaskDetailSheetPrimaryBtn(
            label: label,
            onTap: onTap,
          ),
        ],
      );
}
