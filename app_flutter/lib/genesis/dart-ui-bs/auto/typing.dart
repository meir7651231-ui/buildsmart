// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__manager_copilot_screen:_Typing (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class Typing extends StatelessWidget {
  const Typing();
  @override
  Widget build(BuildContext context) => const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          // Directional: the typing dots sit on the assistant (leading) side —
          // `start` keeps the same visual inset under RTL and also flips for LTR.
          padding: EdgeInsetsDirectional.only(
              bottom: BsTokens.space3, start: BsTokens.space3),
          child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4)),
        ),
      );
}
