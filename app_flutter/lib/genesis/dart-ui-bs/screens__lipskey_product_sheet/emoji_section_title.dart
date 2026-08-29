// 🧼 אטום · EmojiSectionTitle — כותרת-סקציה: גליף + כותרת (+תת-כותרת) בשורה אחת.
// מוצא: screens__lipskey_product_sheet.dart:1990-2028 (_SectionTitle).
// ≠ TitledSection שבמדף (כותרת-מעל-תוכן, 16/w800, בלי גליף/תת-כותרת) — מנגנון אחר.
import 'package:flutter/material.dart';

class EmojiSectionTitle extends StatelessWidget {
  const EmojiSectionTitle({
    required this.emoji,
    required this.title,
    required this.inkColor,
    required this.subtitleColor,
    this.subtitle,
    super.key,
  });
  final String emoji, title;
  final String? subtitle;
  final Color inkColor, subtitleColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: inkColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: subtitleColor, fontSize: 11)),
              ),
            ],
          ],
        ),
      );
}
