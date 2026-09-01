// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__site_hub_screen:_CardDone (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';

class CardDone extends StatelessWidget {
  const CardDone(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 9),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _kOk,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      );
}

const Color _kOk = Color(0xFF1F8A4C);
