// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__profile_screen:_FieldLabel (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _ink,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      );
}

const Color _ink = BsTokens.inkLight;
