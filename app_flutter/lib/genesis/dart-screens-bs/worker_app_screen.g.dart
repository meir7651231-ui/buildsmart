// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_app_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/equipment_button.dart';
import '../dart-ui-bs/auto/propose_primary_btn.dart';
import '../dart-ui-bs/auto/propose_sec_h.dart';
import '../dart-ui-bs/auto/propose_task_button.dart';
import '../dart-ui-bs/auto/submit_button.dart';
import '../dart-ui-bs/auto/summary_card.dart';
import '../dart-ui-bs/auto/today_stat.dart';
import '../dart-ui-bs/auto/worker_app_stat.dart';
import '../dart-data-bs/auto/screens__worker_app_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerAppScreenTokens {
  const WorkerAppScreenTokens();

}

class WorkerAppScreenComposed extends StatelessWidget {
  const WorkerAppScreenComposed({required this.onPressed, required this.onTap, required this.deliveryFee, required this.label, required this.label2, required this.label3, required this.label4, required this.label5, required this.subtotal, required this.text, required this.total, required this.value, required this.vat, required this.vatInclusive, required this.t, super.key});

  final VoidCallback onPressed;
  final VoidCallback onTap;
  final int deliveryFee;
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final String label5;
  final int subtotal;
  final String text;
  final int total;
  final String value;
  final int vat;
  final bool vatInclusive;
  final WorkerAppScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SummaryCard(
            label: label,
            label2: label2,
            label3: label3,
            label4: label4,
            value: value,
            label5: label5,
            subtotal: subtotal,
            vat: vat,
            deliveryFee: deliveryFee,
            total: total,
            vatInclusive: vatInclusive,
          ),
          EquipmentButton(
            title: equipment_button_title,
            body: equipment_button_body,
            label: equipment_button_label,
            fallback: equipment_button_fallback,
            onPressed: onPressed,
          ),
          ProposeTaskButton(
            title: propose_task_button_title,
            body: propose_task_button_body,
            label: propose_task_button_label,
            fallback: propose_task_button_fallback,
            onPressed: onPressed,
          ),
          TodayStat(
            label: label,
            value: value,
          ),
          WorkerAppStat(
            value: value,
            label: label,
          ),
          SubmitButton(
            label: submit_button_label,
            fallback: submit_button_fallback,
            onPressed: onPressed,
          ),
          ProposeSecH(
            text: text,
          ),
          ProposePrimaryBtn(
            label: label,
            onTap: onTap,
          ),
        ],
      );
}
