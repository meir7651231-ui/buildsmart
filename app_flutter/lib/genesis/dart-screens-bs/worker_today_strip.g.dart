// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_today_strip.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/stage_row.dart';
import '../dart-data-bs/auto/screens__worker_today_strip_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerTodayStripTokens {
  const WorkerTodayStripTokens();

}

class WorkerTodayStripComposed extends StatelessWidget {
  const WorkerTodayStripComposed({required this.onMarkDone, required this.onTap, required this.emphasized, required this.name, required this.tag, required this.t, super.key});

  final VoidCallback onMarkDone;
  final VoidCallback onTap;
  final bool emphasized;
  final String name;
  final String tag;
  final WorkerTodayStripTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          StageRow(
            title: stage_row_title,
            body: stage_row_body,
            label: stage_row_label,
            title2: stage_row_title2,
            body2: stage_row_body2,
            label2: stage_row_label2,
            message: stage_row_message,
            name: name,
            onTap: onTap,
            tag: tag,
            emphasized: emphasized,
            onMarkDone: onMarkDone,
          ),
        ],
      );
}
