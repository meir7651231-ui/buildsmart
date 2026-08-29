// 🧼 אטום · SheetDragHandle — פס-גרירה עליון של bottom-sheet.
// מוצא: screens__lipskey_product_sheet.dart:755-763 (Container בגוף LipskeyProductSheet).
// הפיגמנט (Colors.black12 במקור) מוזרק — האטום עיוור לתפקיד (חוק-5).
import 'package:flutter/material.dart';

class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({
    required this.color,
    this.width = 38,
    this.height = 4,
    this.topMargin = 10,
    this.bottomMargin = 6,
    super.key,
  });
  final Color color;
  final double width, height, topMargin, bottomMargin;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
