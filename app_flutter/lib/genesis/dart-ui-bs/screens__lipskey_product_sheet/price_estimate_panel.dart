// 🧼 אטום · PriceEstimatePanel — פאנל-מחיר-משוער: סמל-מטבע + סכום גדול (+סיומת-יחידה)
// + תג-הערכה + שורת-הסתייגות.
// מוצא: screens__lipskey_product_sheet.dart:2963-3019 (_buildPrice, בלי ה-Consumer).
// התרת-סבך: ref.watch(catalogSettingsProvider) (מע"מ/מטבע/ליחידה) ⇒ הקופסה מחשבת
// ומזרימה currencyText ('~'+סמל), amountText, unitSuffixText (t_98f13081 או null),
// badgeLabel (t_c242b4ba), noteText (t_f4ca49bd); bsSuccess(context) ⇒ priceColor.
import 'package:flutter/material.dart';

class PriceEstimatePanel extends StatelessWidget {
  const PriceEstimatePanel({
    required this.currencyText,
    required this.amountText,
    required this.badgeLabel,
    required this.noteText,
    required this.priceColor,
    required this.badgeBgColor,
    required this.badgeFgColor,
    required this.noteColor,
    this.unitSuffixText,
    super.key,
  });
  final String currencyText, amountText, badgeLabel, noteText;
  final String? unitSuffixText;
  final Color priceColor, badgeBgColor, badgeFgColor, noteColor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Text(currencyText,
                    style: TextStyle(
                        color: priceColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Text(amountText,
                    style: TextStyle(
                        color: priceColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
                if (unitSuffixText != null) ...[
                  const SizedBox(width: 6),
                  Text(unitSuffixText!,
                      style: TextStyle(
                          color: priceColor.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badgeLabel,
                      style: TextStyle(
                          color: badgeFgColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(noteText,
                style:
                    TextStyle(color: noteColor, fontSize: 10, height: 1.4)),
          ),
        ],
      );
}
