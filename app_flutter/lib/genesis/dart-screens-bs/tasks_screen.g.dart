// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__tasks_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/approval_card.dart';
import '../dart-ui-bs/auto/card.dart';
import '../dart-ui-bs/auto/done_all.dart';
import '../dart-ui-bs/auto/intro.dart';
import '../dart-ui-bs/auto/log_button.dart';
import '../dart-ui-bs/auto/new_task_button.dart';
import '../dart-ui-bs/auto/primary_btn.dart';
import '../dart-ui-bs/auto/proposal_card.dart';
import '../dart-ui-bs/auto/sec_h.dart';
import '../dart-data-bs/auto/screens__tasks_screen_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class ApprovalCardItem {
  const ApprovalCardItem({required this.name, required this.workerLabel, required this.onApprove, required this.onReject});
  final String name;
  final String workerLabel;
  final VoidCallback onApprove;
  final VoidCallback onReject;
}

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class ProposalCardItem {
  const ProposalCardItem({required this.id, required this.name, required this.workerLabel, required this.days, required this.onApprove, required this.onReject});
  final int id;
  final String name;
  final String workerLabel;
  final int days;
  final VoidCallback onApprove;
  final VoidCallback onReject;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TasksScreenTokens {
  const TasksScreenTokens();

}

class TasksScreenComposed extends StatelessWidget {
  const TasksScreenComposed({required this.onTap, required this.approvalCardItems, required this.children, required this.detail, required this.label, required this.proposalCardItems, required this.text, required this.title, required this.titleId, required this.t, super.key});

  final VoidCallback onTap;
  final List<ApprovalCardItem> approvalCardItems;
  final List<Widget> children;
  final String detail;
  final String label;
  final List<ProposalCardItem> proposalCardItems;
  final String text;
  final String title;
  final String? titleId;
  final TasksScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Intro(
            text: text,
          ),
          NewTaskButton(
            fallback: new_task_button_fallback,
            onTap: onTap,
          ),
          LogButton(
            fallback: log_button_fallback,
            onTap: onTap,
          ),
          DoneAll(
            text: text,
          ),
          for (final t in approvalCardItems) ...[
          ApprovalCard(
            label: approval_card_label,
            fallback: approval_card_fallback,
            label2: approval_card_label2,
            name: t.name,
            workerLabel: t.workerLabel,
            onApprove: t.onApprove,
            onReject: t.onReject,
          ),
          const SizedBox(height: 8),
        ],
          for (final t in proposalCardItems) ...[
          ProposalCard(
            label: proposal_card_label,
            fallback: proposal_card_fallback,
            label2: proposal_card_label2,
            id: t.id,
            name: t.name,
            detail: detail,
            workerLabel: t.workerLabel,
            days: t.days,
            onApprove: t.onApprove,
            onReject: t.onReject,
          ),
          const SizedBox(height: 8),
        ],
          PrimaryBtn(
            label: label,
            onTap: onTap,
          ),
          Card(
            title: title,
            titleId: titleId,
            children: children,
          ),
          SecH(
            text: text,
          ),
        ],
      );
}
