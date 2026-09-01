// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__regression_panel_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/summary_card.dart';
import '../dart-data-bs/auto/screens__regression_panel_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class RegressionPanelScreenTokens {
  const RegressionPanelScreenTokens();

}

class RegressionPanelScreenComposed extends StatelessWidget {
  const RegressionPanelScreenComposed({required this.deliveryFee, required this.label, required this.label2, required this.label3, required this.label4, required this.label5, required this.subtotal, required this.total, required this.value, required this.vat, required this.vatInclusive, required this.t, super.key});


  final int deliveryFee;
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final String label5;
  final int subtotal;
  final int total;
  final String value;
  final int vat;
  final bool vatInclusive;
  final RegressionPanelScreenTokens t;

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
        ],
      );
}
