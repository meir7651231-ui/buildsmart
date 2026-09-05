// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_notifs_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/notif_row.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class NotifRowItem {
  const NotifRowItem({required this.onTap});
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerNotifsSheetTokens {
  const WorkerNotifsSheetTokens();

}

class WorkerNotifsSheetComposed extends StatelessWidget {
  const WorkerNotifsSheetComposed({required this.fallback, required this.notifRowItems, required this.t, super.key});


  final String fallback;
  final List<NotifRowItem> notifRowItems;
  final WorkerNotifsSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          for (final n in notifRowItems) ...[
          NotifRow(
            fallback: fallback,
            onTap: n.onTap,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
