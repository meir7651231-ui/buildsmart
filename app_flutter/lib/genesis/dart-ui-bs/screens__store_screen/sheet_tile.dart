// 🧼 אטום · SheetTile — שורת-sheet: גליף-leading + תווית. שונה מ-PlaceholderRow שבמדף
// (שם trailing-badge, כאן leading-גליף). מוצא: screens__store_screen.dart:1088 (_SheetTile).
// onTap חובה — טוסט-ברירת-המחדל של המקור (t_f862ee5a) עבר לקופסה (אין fx באטום).
import 'package:flutter/material.dart';

class SheetTile extends StatelessWidget {
  const SheetTile({
    required this.emoji, required this.label, required this.onTap,
    required this.inkColor, super.key,
  });
  final String emoji, label;
  final VoidCallback onTap;
  final Color inkColor;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 22)),
        title: Text(label, style: TextStyle(color: inkColor, fontSize: 15)),
        onTap: onTap,
      );
}
