// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_forms_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/form_card.dart';
import '../dart-ui-bs/auto/vacation_row.dart';
import '../dart-ui-bs/auto/worker_forms_pill_button.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerFormsScreenTokens {
  const WorkerFormsScreenTokens();

}

class WorkerFormsScreenComposed extends StatelessWidget {
  const WorkerFormsScreenComposed({required this.onApprove, required this.onPressed, required this.children, required this.filled, required this.label, required this.label2, required this.label3, required this.label4, required this.reason, required this.status, required this.title, required this.t, super.key});

  final VoidCallback onApprove;
  final VoidCallback onPressed;
  final List<Widget> children;
  final bool filled;
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final String reason;
  final String status;
  final String title;
  final WorkerFormsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          FormCard(
            title: title,
            children: children,
          ),
          WorkerFormsPillButton(
            label: label,
            onPressed: onPressed,
            filled: filled,
          ),
          VacationRow(
            label: label,
            label2: label2,
            status: status,
            reason: reason,
            label3: label3,
            label4: label4,
            onApprove: onApprove,
          ),
        ],
      );
}
