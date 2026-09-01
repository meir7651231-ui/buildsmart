// 🧼 אטום · SheetScaffold — שלד-bottom-sheet: ידית + כותרת (גליף+טקסט) + ילדים.
// מוצא: screens__store_screen.dart:1039 (_SheetScaffold); subtitle אופציונלי ממזג גם את
// כותרת _ServiceSheet (3677-3695) — אותו מנגנון, שורת-משנה נוספת. הילדים = slot
// (הקופסה מרכיבה sheet_tile / contact_tile / service_tile לפי התוכן).
import 'package:flutter/material.dart';

class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    required this.emoji, required this.title, required this.children,
    required this.handleColor, required this.inkColor,
    this.subtitle, this.subtitleColor,
    this.bottomPadding = 24, super.key,
  });
  final String emoji, title;
  final List<Widget> children;
  final Color handleColor, inkColor;
  final String? subtitle;
  final Color? subtitleColor;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$emoji $title',
                style: TextStyle(color: inkColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(subtitle!, style: TextStyle(color: subtitleColor, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );
}
