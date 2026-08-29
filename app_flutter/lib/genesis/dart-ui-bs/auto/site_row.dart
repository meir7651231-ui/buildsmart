// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__budget_screen:_SiteRow (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class SiteRow extends StatelessWidget {
  const SiteRow({required this.name, required this.value});
  final String name;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
                child: Text('🏗️ $name',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _ink))),
            Text('$value ›',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
          ],
        ),
      );
}

const _ink = BsTokens.inkLight;
