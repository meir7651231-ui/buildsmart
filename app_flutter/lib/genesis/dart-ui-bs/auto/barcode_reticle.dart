// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__camera_sheet:_BarcodeReticle (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class BarcodeReticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240, height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: BsTokens.brand, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
