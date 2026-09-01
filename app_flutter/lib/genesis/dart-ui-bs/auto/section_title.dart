// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__lipskey_product_sheet:_SectionTitle (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(
      {required this.emoji, required this.title, this.subtitle});
  final String emoji;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text(emoji,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 11)),
              ),
            ],
          ],
        ),
      );
}
