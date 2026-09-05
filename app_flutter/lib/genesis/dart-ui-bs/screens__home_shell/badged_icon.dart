// 🧼 אטום · BadgedIcon — אייקון עם תג-עיגול-ספירה בפינה (minWidth/minHeight 15).
// מוצא: _BadgedIcon (screens__home_shell.dart:963-1002) — היה כבר טהור-IO ונקי-דאטה.
// התרת-סבך יחידה: התקרה count>9 ⇒ ׳9+׳ עברה לקופסה — האטום מקבל badgeLabel מוכן
// (null ⇒ אייקון חשוף, כמו count==0 במקור). היו צרובים: BsTokens.brand ·
// Colors.white ⇒ badgeFillColor/badgeTextColor.
// שונה מ-CartFabButton (תג-מלבני-ממוסגר על FAB) — כאן עיגול-מלא על אייקון חשוף.
import 'package:flutter/material.dart';

class BadgedIcon extends StatelessWidget {
  const BadgedIcon({
    required this.icon,
    required this.badgeLabel,
    required this.badgeFillColor,
    required this.badgeTextColor,
    super.key,
  });

  final IconData icon;

  /// טקסט-התג המפורמט בקופסה (התקרה 9+ = דין-קופסה); null ⇒ בלי תג.
  final String? badgeLabel;
  final Color badgeFillColor, badgeTextColor;

  @override
  Widget build(BuildContext context) {
    final label = badgeLabel;
    if (label == null) return Icon(icon);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          top: -5,
          right: -6,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: badgeFillColor,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
            child: Text(
              label,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
