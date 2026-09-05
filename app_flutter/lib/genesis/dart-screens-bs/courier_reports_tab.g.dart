// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__courier_reports_tab.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/kv_row.dart';
import '../dart-ui-bs/auto/rcard.dart';
import '../dart-ui-bs/auto/rstat.dart';
import '../dart-data-bs/auto/screens__courier_reports_tab_content2.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class KvRowItem {
  const KvRowItem({required this.label, required this.value});
  final String label;
  final String value;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CourierReportsTabTokens {
  const CourierReportsTabTokens();

}

class CourierReportsTabComposed extends StatelessWidget {
  const CourierReportsTabComposed({required this.children, required this.kvRowItems, required this.value, required this.t, super.key});


  final List<Widget> children;
  final List<KvRowItem> kvRowItems;
  final String value;
  final CourierReportsTabTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          RStat(
            value: value,
            label: rstat_label,
          ),
          RCard(
            title: rcard_title,
            children: children,
          ),
          for (final o in kvRowItems) ...[
          KvRow(
            label: o.label,
            value: o.value,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
