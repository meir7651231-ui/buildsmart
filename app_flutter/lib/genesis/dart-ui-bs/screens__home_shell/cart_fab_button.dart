// 🧼 אטום · CartFabButton — ה-FAB העגול של הסל: מסגרת-היקף לבנה + אייקון-עגלה +
// תג-ספירה ממוסגר בפינה (minWidth 18). מוצא: גוף CartFab, המשתנה fab
// (screens__home_shell.dart:417-456).
// התרת-סבך: smartCartProvider + fold-הכמויות ⇒ הקופסה מחשבת ומזריקה countLabel
// (null ⇒ בלי תג, כמו count==0 במקור); openCart (dial-reset + ניווט-טאב + maybePop)
// ⇒ onPressed. heroTag נשאר prop (זהות-אנימציה של הקופסה). היו צרובים:
// BsTokens.brand · Colors.white · bsOnAccent(context) · Theme.of(surface) ⇒ params.
// שונה מ-BadgedIcon שבתיקייה זו (תג-עיגול-מלא על אייקון חשוף) — כאן תג-מלבני ממוסגר
// על FAB שלם; ומ-CountBadge של מסך-המנהל (גלולה עצמאית, לא overlay-פינה).
import 'package:flutter/material.dart';

class CartFabButton extends StatelessWidget {
  const CartFabButton({
    required this.heroTag,
    required this.onPressed,
    required this.countLabel,
    required this.fillColor,
    required this.ringColor,
    required this.iconColor,
    required this.badgeFillColor,
    required this.badgeBorderColor,
    required this.badgeTextColor,
    super.key,
  });

  final Object heroTag;
  final VoidCallback onPressed;

  /// טקסט-התג המפורמט בקופסה; null ⇒ אין תג (סל ריק).
  final String? countLabel;
  final Color fillColor, ringColor, iconColor;
  final Color badgeFillColor, badgeBorderColor, badgeTextColor;

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: fillColor,
        foregroundColor: ringColor,
        elevation: 4,
        shape: CircleBorder(side: BorderSide(color: ringColor, width: 2)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(Icons.shopping_cart, color: iconColor, size: 26),
            if (countLabel != null)
              Positioned(
                top: -10,
                right: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: badgeFillColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeBorderColor, width: 1.5),
                  ),
                  child: Text(
                    countLabel!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
