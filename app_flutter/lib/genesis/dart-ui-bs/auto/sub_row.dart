// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__finance_hub_sheets:_SubRow (בנייה-חכמה main) · צרור-2 · מודל-שוטח: 4 שדות · props-שורש: label, label2, allocated, spent, ic, name
// התוכן: new/dart-data-bs/auto/screens__finance_hub_sheets_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';
import 'package:buildsmart/data/contractor_seeds.dart';

class SubRow extends StatelessWidget {
  SubRow({required this.label, required this.label2, required this.allocated, required this.spent, required this.ic, required this.name, });
  final String label;
  final String label2;
  final int allocated;
  final int spent;
  final String ic;
  final String name;

  @override
  Widget build(BuildContext context) {
    // Guard the divisor (mirrors the guarded aggregate above): allocated == 0
    // would make spent/allocated NaN/Infinity and .round() THROW.
    late final pct =
        allocated > 0 ? (spent / allocated * 100).round() : 0;
    final over = pct > 100;
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space3),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFE6E8EC))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${ic} ${name}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: over ? _kDn : BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: (pct.clamp(0, 100)) / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFE6E8EC),
              valueColor: AlwaysStoppedAnimation<Color>(
                over ? _kDn : BsTokens.brand,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${label}${fMoney(spent)}${label2}${fMoney(allocated)}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

const Color _kDn = Color(
  0xFFE5484D,
);
