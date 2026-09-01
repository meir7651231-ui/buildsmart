// 🧼 אטום · AttentionRow — שורת "דורש-טיפול": נקודת-חומרה, תג-צבוע, כותרת, שברון.
// מוצא: _AttentionRow. התרת-סבך: הקופסה ממפה AttentionItem ⇒ (tagLabel, title,
// accentColor לפי sev) ו-onTap = כתיבת managerTabProvider ל-item.navTab.
import 'package:flutter/material.dart';

class AttentionRow extends StatelessWidget {
  const AttentionRow({
    required this.tagLabel, required this.title, required this.accentColor,
    required this.onTap, required this.gap, required this.tagFontSize,
    required this.titleFontSize, super.key,
  });

  final String tagLabel, title;
  final Color accentColor;
  final VoidCallback onTap;

  /// BsTokens.space2 במקור (גם הריפוד-האנכי וגם הרווחים).
  final double gap;

  /// BsTokens.typeLabel / BsTokens.typeBody במקור.
  final double tagFontSize, titleFontSize;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: gap),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
              SizedBox(width: gap),
              Container(
                padding: EdgeInsets.symmetric(horizontal: gap, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tagLabel,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: tagFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: titleFontSize)),
              ),
              const Icon(Icons.chevron_left, size: 18),
            ],
          ),
        ),
      );
}
