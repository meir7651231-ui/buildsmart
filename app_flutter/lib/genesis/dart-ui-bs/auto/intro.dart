// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__tasks_screen:_Intro (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class Intro extends StatelessWidget {
  const Intro(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: BsTokens.space3),
        child: Text(
          text,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
      );
}
