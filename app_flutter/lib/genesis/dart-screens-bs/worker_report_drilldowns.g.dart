// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_report_drilldowns.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import '../dart-ui-bs/auto/mini_status_pill.dart';
import '../dart-ui-bs/auto/worker_equipment_checklist_sheet_sec_h.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class KvLineItem {
  const KvLineItem({required this.label, required this.value});
  final String label;
  final String value;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerReportDrilldownsTokens {
  const WorkerReportDrilldownsTokens();

}

class WorkerReportDrilldownsComposed extends StatelessWidget {
  const WorkerReportDrilldownsComposed({required this.kvLineItems, required this.status, required this.text, required this.t, super.key});


  final List<KvLineItem> kvLineItems;
  final String status;
  final String text;
  final WorkerReportDrilldownsTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          MiniStatusPill(
            status: status,
          ),
          WorkerEquipmentChecklistSheetSecH(
            text: text,
          ),
          for (final c in kvLineItems) ...[
          KvLine(
            label: c.label,
            value: c.value,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
