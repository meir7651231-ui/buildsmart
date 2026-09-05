// 🧼 אטום · DirectoryRow — שורת-בחירת-איש-קשר: גליף-leading גדול (24) + שם +
// תת-תווית-תפקיד אופציונלית + chevron-trailing; onTap null ⇒ שורה מנוטרלת.
// מוצא: שני ענפי _NewChatSheet — רשימת-הסוגים הקבועה (screens__home_shell.dart:
// 1433-1449) ושורת-הספרייה החיה _directoryRow (1500-1541) — אותו מנגנון-ListTile;
// ההבדל = subtitle (אין/יש) ו-onTap ננטרל בלי-זהות (myUid ריק) — שניהם props.
// התרת-סבך: directoryProvider/currentUidProvider/chatEngineProvider + _roleBadge ⇒
// הקופסה גוזרת emoji/title/subtitle (roleBadges ב-content) ומספקת onTap
// (pop + createOrGetThread + openChatThread או openNewChatWith). היו צרובים:
// BsTokens.inkLight · 0xFF888888 ⇒ inkColor/mutedColor/trailingColor.
// שונה מ-SheetTile של מסך-החנות (גליף 22, בלי trailing/subtitle, onTap חובה)
// ומ-ContactTile שם (אווטאר-בעיגול-צבוע) — עוגנים בגוף.
import 'package:flutter/material.dart';

class DirectoryRow extends StatelessWidget {
  const DirectoryRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.inkColor,
    required this.mutedColor,
    required this.trailingColor,
    super.key,
  });

  final String emoji, title;

  /// תווית-תפקיד מתחת לשם; null או ריקה ⇒ בלי subtitle (כמו badge.label.isEmpty במקור).
  final String? subtitle;

  /// null ⇒ שורה מנוטרלת (חגורת-ההגנה של המקור על uid חסר).
  final VoidCallback? onTap;
  final Color inkColor, mutedColor, trailingColor;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(title, style: TextStyle(color: inkColor, fontSize: 15)),
      subtitle: sub == null || sub.isEmpty
          ? null
          : Text(sub, style: TextStyle(color: mutedColor, fontSize: 12)),
      trailing: Icon(Icons.chevron_left, color: trailingColor),
      onTap: onTap,
    );
  }
}
