// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__finance_hub_sheets:_PenaltyCard (בנייה-חכמה main) · צרור-2 · מודל-שוטח: 5 שדות · props-שורש: label, label2, id, amount, days, perDay, createdAt
// התוכן: new/dart-data-bs/auto/screens__finance_hub_sheets_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';
import 'package:buildsmart/data/contractor_seeds.dart';

class PenaltyCard extends StatelessWidget {
  PenaltyCard({required this.label, required this.label2, required this.id, required this.amount, required this.days, required this.perDay, required this.createdAt, });
  final String label;
  final String label2;
  final String id;
  final int amount;
  final int days;
  final int perDay;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
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
                  id,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _kDn.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: Text(
                  fMoney(amount),
                  style: const TextStyle(
                    color: _kDn,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            // proto: days+' ימי איחור · '+finMoney(perDay)+' ליום · 📅 '+createdAt
            '${days}${label}${fMoney(perDay)}${label2}${createdAt}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

const Color _kDn = Color(
  0xFFE5484D,
);
