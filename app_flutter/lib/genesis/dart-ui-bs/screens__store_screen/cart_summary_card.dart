// 🧼 אטום · CartSummaryCard — כרטיס-סיכום-סל: שורות-ביניים, מפריד, ושורת-סה״כ מודגשת.
// מוצא: screens__store_screen.dart:2571 (_SummaryCard). דין-המע״מ (vatInclusive —
// t_2c14716d מול t_2fbec343, וחישובי cartVat/cartTotal) = קופסה: היא מפרמטת את
// lines ואת totalLabel/totalValue (t_33de167e). שורת-הסיכום ממומשת inline (חוק-1).
import 'package:flutter/material.dart';

typedef CartSummaryLineData = ({String label, String value});

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({
    required this.lines, required this.totalLabel, required this.totalValue,
    required this.surfaceColor, required this.inkColor, required this.mutedColor,
    required this.dividerColor, super.key,
  });
  final List<CartSummaryLineData> lines;
  final String totalLabel, totalValue;
  final Color surfaceColor, inkColor, mutedColor, dividerColor;

  Widget _line(String label, String value, TextStyle style) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      );

  @override
  Widget build(BuildContext context) {
    final mutedStyle = TextStyle(color: mutedColor, fontSize: 13);
    final boldStyle = TextStyle(color: inkColor, fontSize: 15, fontWeight: FontWeight.w800);
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _line(lines[i].label, lines[i].value, mutedStyle),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: dividerColor, height: 1),
          ),
          _line(totalLabel, totalValue, boldStyle),
        ],
      ),
    );
  }
}
