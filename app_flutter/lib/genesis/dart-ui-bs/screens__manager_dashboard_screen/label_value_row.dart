// 🧼 אטום · LabelValueRow — שורת תווית⇄ערך. איחד 4 מנגנונים כמעט-זהים:
// row() של _OrderDetailSheet/_CustomerDetailSheet (תווית מושתקת 13 / ערך דיו 13 w700,
// ריפוד-אנכי 6) · _ManageRow (תווית דיו 13.5 w600 / ערך מושתק 13.5 w700, ריפוד 7,
// gap space3) · שורת _SavedCustomerSection (ערך Flexible מיושר-סוף) — הכול params.
import 'package:flutter/material.dart';

class LabelValueRow extends StatelessWidget {
  const LabelValueRow({
    required this.label, required this.value,
    required this.labelColor, required this.valueColor,
    this.labelSize = 13, this.valueSize = 13,
    this.labelWeight = FontWeight.w400, this.valueWeight = FontWeight.w700,
    this.verticalPadding = 6, this.gap = 0,
    this.flexibleValue = false, this.alignTop = false, super.key,
  });

  final String label, value;
  final Color labelColor, valueColor;
  final double labelSize, valueSize, verticalPadding, gap;
  final FontWeight labelWeight, valueWeight;

  /// true ⇒ הערך Flexible + TextAlign.end (וריאנט הלקוח-השמור).
  final bool flexibleValue;

  /// true ⇒ CrossAxisAlignment.start (וריאנט _ManageRow).
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      textAlign: flexibleValue ? TextAlign.end : null,
      style: TextStyle(
        color: valueColor,
        fontSize: valueSize,
        fontWeight: valueWeight,
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment:
            alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: labelSize,
                fontWeight: labelWeight,
              ),
            ),
          ),
          if (gap > 0) SizedBox(width: gap),
          if (flexibleValue) Flexible(child: valueText) else valueText,
        ],
      ),
    );
  }
}
