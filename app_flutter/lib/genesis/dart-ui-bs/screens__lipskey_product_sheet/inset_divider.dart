// 🧼 אטום · InsetDivider — קו-מפריד דק עם הזחה סימטרית.
// מוצא: screens__lipskey_product_sheet.dart:2030-2036 (_Divider, indent 20) + 2330-2337
// (מפריד-הרצועות ב-_QuickInfoStrips, thickness 0.7 / indent 12) — אותו מנגנון, params.
import 'package:flutter/material.dart';

class InsetDivider extends StatelessWidget {
  const InsetDivider({
    required this.color,
    this.indent = 20,
    this.endIndent = 20,
    this.thickness,
    super.key,
  });
  final Color color;
  final double indent, endIndent;
  final double? thickness;

  @override
  Widget build(BuildContext context) => Divider(
      height: 1,
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent);
}
