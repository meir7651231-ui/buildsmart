// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__contractor_hr_sheet:_StatusChip (בנייה-חכמה main) · צרור-1 · props-שורש: label, label2
// התוכן: new/dart-data-bs/auto/screens__contractor_hr_sheet_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class StatusChip extends StatelessWidget {
  StatusChip({required this.label, required this.label2, required this.status});
  final String label;
  final String label2;
  final String status;

  @override
  Widget build(BuildContext context) {
    final approved = status == kVacationApproved;
    final color = approved ? const Color(0xFF1F8A4C) : BsTokens.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        approved ? label : label2,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
