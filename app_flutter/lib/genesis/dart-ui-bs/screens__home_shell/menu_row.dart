// 🧼 אטום · MenuRow — שורת-פריט-תפריט: גליף + תווית (child של PopupMenuItem).
// מוצא: _MenuRow (screens__home_shell.dart:1306-1347) — המנגנון המשותף לכל 4 תפריטי-
// ה-⋮ (קטלוג/שיחות/התראות/חנות); ה-PopupMenuButton עצמו + הרשימות + ה-dispatch =
// חיווט-קופסה (ראו wiring_notes).
// התרת-סבך: cfgId/CfgText (דריסת-Studio) ⇒ labelSlot — הקופסה מזרימה CfgText;
// null ⇒ Text(label) רגיל, ביט-זהה לענף ה-id==null במקור. היו צרובים:
// BsTokens.inkLight ⇒ inkColor.
// שונה מ-PlaceholderRow שבמדף (ListTile עם trailing-badge) ומ-SheetTile של מסך-החנות
// (ListTile עם onTap) — כאן Row חשוף בלי הקשה (ההקשה = של ה-PopupMenuItem העוטף).
import 'package:flutter/material.dart';

class MenuRow extends StatelessWidget {
  const MenuRow({
    required this.emoji,
    required this.label,
    required this.inkColor,
    this.labelSlot,
    super.key,
  });

  final String emoji, label;
  final Color inkColor;

  /// slot-דריסה לתווית (CfgText בקופסה); null ⇒ Text(label).
  final Widget? labelSlot;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Flexible(
            child: labelSlot ??
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: inkColor, fontSize: 15),
                ),
          ),
        ],
      );
}
