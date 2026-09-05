// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__finance_hub_sheets:_FinCallout (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class FinCallout extends StatelessWidget {
  const FinCallout({
    required this.label,
    required this.value,
    this.big = false,
    this.valueColor,
    this.note,
    this.secondLabel,
    this.secondValue,
  });
  final String label;
  final String value;
  final bool big;
  final Color? valueColor;
  final String? note;
  final String? secondLabel;
  final String? secondValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: BsTokens.space4),
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F4),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFCDE7E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: _kBrandTeal, fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: big ? 26 : 18,
            ),
          ),
          if (secondLabel != null) ...[
            const SizedBox(height: BsTokens.space2),
            Text(
              secondLabel!,
              style: const TextStyle(color: _kBrandTeal, fontSize: 12.5),
            ),
            const SizedBox(height: 4),
            Text(
              secondValue ?? '',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(
              note!,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

const Color _kBrandTeal = BsTokens.brand;
