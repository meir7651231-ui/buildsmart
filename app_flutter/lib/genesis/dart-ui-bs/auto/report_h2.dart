// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__finance_hub_sheets:_ReportH2 (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class ReportH2 extends StatelessWidget {
  const ReportH2(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Text(
      text,
      style: const TextStyle(
        color: _kBrandTeal,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
  );
}

const Color _kBrandTeal = BsTokens.brand;
