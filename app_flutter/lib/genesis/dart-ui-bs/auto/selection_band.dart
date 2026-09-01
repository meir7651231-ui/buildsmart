// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: features__catalog_config__wheel_picker:_SelectionBand (בנייה-חכמה main) · צרור-4
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class SelectionBand extends StatelessWidget {
  const SelectionBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kItemExtent,
      margin: const EdgeInsets.symmetric(horizontal: BsTokens.space2),
      decoration: BoxDecoration(
        color: _kBandFill,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        border: Border.all(color: _kBandLine, width: 1.2),
      ),
    );
  }
}

const double _kItemExtent = 36;

const Color _kBandFill = Color(0x14FF7A18);

const Color _kBandLine = Color(0x66FF7A18);
