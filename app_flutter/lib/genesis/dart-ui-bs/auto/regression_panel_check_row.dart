// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__regression_panel_screen:_CheckRow (בנייה-חכמה main) · צרור-1 · מודל-שוטח: 5 שדות · props-שורש: label, label2, pass, name, detail, expected, got
// התוכן: new/dart-data-bs/auto/screens__regression_panel_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class RegressionPanelCheckRow extends StatelessWidget {
  RegressionPanelCheckRow({required this.label, required this.label2, required this.pass, required this.name, required this.detail, required this.expected, required this.got, });
  final String label;
  final String label2;
  final bool pass;
  final String name;
  final String? detail;
  final String? expected;
  final String? got;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pass ? '✓' : '✗',
            style: TextStyle(
              color: pass
                  ? BsTokens.success
                  : BsTokens.danger,
              fontSize: 13,
              fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 12,
                  ),
                ),
                if (detail != null && detail!.isNotEmpty)
                  Text(
                    detail!,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                    ),
                  ),
                if (!pass && expected != null)
                  Text(
                    '${label}${expected}${label2}${got ?? "—"}',
                    style: const TextStyle(
                      color: BsTokens.danger,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
