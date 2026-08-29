// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_reports_tab.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/kpi_box.dart';
import '../dart-ui-bs/auto/proof_thumb.dart';
import '../dart-ui-bs/auto/thumb_placeholder.dart';
import '../dart-ui-bs/auto/worker_reports_tab_card.dart';
import '../dart-ui-bs/auto/worker_reports_tab_kv_row.dart';
import '../dart-data-bs/auto/screens__worker_reports_tab_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerReportsTabTokens {
  const WorkerReportsTabTokens();

}

class WorkerReportsTabComposed extends StatelessWidget {
  const WorkerReportsTabComposed({required this.onTap, required this.children, required this.glyph, required this.label, required this.photo, required this.title, required this.titleId, required this.value, required this.t, super.key});

  final VoidCallback onTap;
  final List<Widget> children;
  final String glyph;
  final String label;
  final String? photo;
  final String title;
  final String? titleId;
  final String value;
  final WorkerReportsTabTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          KpiBox(
            label2: kpi_box_label2,
            value: value,
            label: label,
            onTap: onTap,
          ),
          WorkerReportsTabCard(
            title: title,
            titleId: titleId,
            children: children,
          ),
          WorkerReportsTabKvRow(
            label2: worker_reports_tab_kv_row_label2,
            label: label,
            value: value,
            onTap: onTap,
          ),
          ProofThumb(
            title: proof_thumb_title,
            body: proof_thumb_body,
            label: proof_thumb_label,
            onTap: onTap,
            photo: photo,
          ),
          ThumbPlaceholder(
            glyph: glyph,
          ),
        ],
      );
}
