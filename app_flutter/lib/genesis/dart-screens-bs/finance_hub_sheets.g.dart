// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__finance_hub_sheets.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/approval_card.dart';
import '../dart-ui-bs/auto/ca_empty.dart';
import '../dart-ui-bs/auto/ca_primary.dart';
import '../dart-ui-bs/auto/fin_callout.dart';
import '../dart-ui-bs/auto/fin_head.dart';
import '../dart-ui-bs/auto/fin_row.dart';
import '../dart-ui-bs/auto/fin_rows.dart';
import '../dart-ui-bs/auto/fin_tile.dart';
import '../dart-ui-bs/auto/penalty_card.dart';
import '../dart-ui-bs/auto/report_h2.dart';
import '../dart-ui-bs/auto/report_table.dart';
import '../dart-ui-bs/auto/sub_row.dart';
import '../dart-ui-bs/auto/thr_row.dart';
import '../dart-data-bs/auto/screens__finance_hub_sheets_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class ThrRowItem {
  const ThrRowItem({required this.label, required this.hit});
  final String label;
  final bool hit;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class FinanceHubSheetsTokens {
  const FinanceHubSheetsTokens({required this.valueColor});
  final Color valueColor;
}

class FinanceHubSheetsComposed extends StatelessWidget {
  const FinanceHubSheetsComposed({required this.onApprove, required this.onReject, required this.onTap, required this.allocated, required this.amount, required this.big, required this.children, required this.createdAt, required this.days, required this.fallback, required this.ic, required this.id, required this.label, required this.label2, required this.name, required this.note, required this.perDay, required this.rows, required this.secondLabel, required this.secondValue, required this.spent, required this.sub, required this.text, required this.thrRowItems, required this.title, required this.value, required this.workerLabel, required this.t, super.key});

  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onTap;
  final int allocated;
  final int amount;
  final bool big;
  final List<Widget> children;
  final String createdAt;
  final int days;
  final String fallback;
  final String ic;
  final String id;
  final String label;
  final String label2;
  final String name;
  final String? note;
  final int perDay;
  final List<(String, String, bool)> rows;
  final String? secondLabel;
  final String? secondValue;
  final int spent;
  final String sub;
  final String text;
  final List<ThrRowItem> thrRowItems;
  final String title;
  final String value;
  final String workerLabel;
  final FinanceHubSheetsTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          FinHead(
            ic: ic,
            title: title,
            sub: sub,
          ),
          FinRow(
            label,
            value,
            valueColor: t.valueColor,
          ),
          FinRows(
            children,
          ),
          FinCallout(
            label: label,
            value: value,
            big: big,
            valueColor: t.valueColor,
            note: note,
            secondLabel: secondLabel,
            secondValue: secondValue,
          ),
          CaPrimary(
            label: label,
            onTap: onTap,
          ),
          FinTile(
            ic: ic,
            title: title,
            sub: sub,
            onTap: onTap,
          ),
          SubRow(
            label: sub_row_label,
            label2: sub_row_label2,
            allocated: allocated,
            spent: spent,
            ic: ic,
            name: name,
          ),
          CaEmpty(
            text,
          ),
          ApprovalCard(
            label: label,
            fallback: fallback,
            label2: label2,
            name: name,
            workerLabel: workerLabel,
            onApprove: onApprove,
            onReject: onReject,
          ),
          for (final t in thrRowItems) ...[
          ThrRow(
            label: t.label,
            hit: t.hit,
          ),
          const SizedBox(height: 8),
        ],
          PenaltyCard(
            label: penalty_card_label,
            label2: penalty_card_label2,
            id: id,
            amount: amount,
            days: days,
            perDay: perDay,
            createdAt: createdAt,
          ),
          ReportH2(
            text,
          ),
          ReportTable(
            rows: rows,
          ),
        ],
      );
}
