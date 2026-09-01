// 🧼 אטום · ProfileHeaderRow — כותרת כרטיס-הפרופיל: עיגול-אווטאר 56dp (אות-ראשונה
// או אייקון-fallback) + שם גדול (22/w900) + כפתור-סגירה. מוצא: גוף _ProfileCard,
// שורת-הכותרת (screens__home_shell.dart:1604-1649).
// התרת-סבך: userProfileProvider + דין-האורח (שם ריק ⇒ תווית-אורח מ-content +
// אייקון-person) ⇒ הקופסה מזריקה name מוכן ו-initial (null ⇒ fallbackIcon);
// Navigator.pop ⇒ onClose; tooltip-הסגירה ⇒ content. היו צרובים: 0xFFFFF0E3 ·
// BsTokens.brandDark · BsTokens.inkLight · 0xFF888888 · BsTokens.space3 ⇒ params.
import 'package:flutter/material.dart';

class ProfileHeaderRow extends StatelessWidget {
  const ProfileHeaderRow({
    required this.name,
    required this.initial,
    required this.fallbackIcon,
    required this.closeTooltip,
    required this.onClose,
    required this.avatarFillColor,
    required this.avatarInkColor,
    required this.nameColor,
    required this.closeColor,
    required this.gap,
    super.key,
  });

  final String name;

  /// האות-הראשונה של השם (characters.first בקופסה); null ⇒ fallbackIcon (אורח).
  final String? initial;
  final IconData fallbackIcon;
  final String closeTooltip;
  final VoidCallback onClose;
  final Color avatarFillColor, avatarInkColor, nameColor, closeColor;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final ch = initial;
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: avatarFillColor,
            shape: BoxShape.circle,
          ),
          child: ExcludeSemantics(
            child: ch != null
                ? Text(
                    ch,
                    style: TextStyle(
                      color: avatarInkColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  )
                : Icon(fallbackIcon, color: avatarInkColor, size: 28),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: nameColor,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: closeColor),
          tooltip: closeTooltip,
          onPressed: onClose,
        ),
      ],
    );
  }
}
