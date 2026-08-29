// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_CreditBar (בנייה-חכמה main) · צרור-1 · props-שורש: label
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class ManagerDashboardCreditBar extends StatelessWidget {
  ManagerDashboardCreditBar({required this.label, required this.pct, required this.color});
  final String label;

  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${label}$pct%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: LinearProgressIndicator(
          value: (pct / 100).clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
