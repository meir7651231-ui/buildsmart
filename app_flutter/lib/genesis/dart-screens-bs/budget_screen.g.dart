// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__budget_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/field.dart';
import '../dart-ui-bs/auto/num_box.dart';
import '../dart-ui-bs/auto/site_row.dart';
import '../dart-ui-bs/auto/tappable.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class BudgetScreenTokens {
  const BudgetScreenTokens({required this.color});
  final Color color;
}

class BudgetScreenComposed extends StatelessWidget {
  const BudgetScreenComposed({required this.onTap, required this.validator, required this.child, required this.controller, required this.label, required this.name, required this.number, required this.value, required this.t, super.key});

  final VoidCallback onTap;
  final String? Function(String value)? validator;
  final Widget child;
  final TextEditingController controller;
  final String label;
  final String name;
  final bool number;
  final String value;
  final BudgetScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Tappable(
            child: child,
            onTap: onTap,
          ),
          NumBox(
            value: value,
            label: label,
            color: t.color,
            onTap: onTap,
          ),
          SiteRow(
            name: name,
            value: value,
          ),
          Field(
            label: label,
            controller: controller,
            number: number,
            validator: validator,
          ),
        ],
      );
}
