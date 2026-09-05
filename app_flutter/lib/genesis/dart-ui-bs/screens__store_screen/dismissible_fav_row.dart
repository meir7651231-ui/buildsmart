// 🧼 אטום · DismissibleFavRow — מעטפת-החלקה-למועדפים: swipe endToStart מסמן/מבטל
// מועדף (confirmDismiss מחזיר false — השורה לא נמחקת). מוצא:
// screens__store_screen.dart:1415 (_DismissibleStoreRow). הילד = slot (הקופסה מרכיבה
// store_hub_row) — כך האטום לא מייבא אטום (חוק-1).
import 'package:flutter/material.dart';

class DismissibleFavRow extends StatelessWidget {
  const DismissibleFavRow({
    required this.dismissKey, required this.isFav, required this.onFavToggle,
    required this.child, required this.backgroundColor, required this.favColor,
    super.key,
  });
  final Key dismissKey;
  final bool isFav;
  final VoidCallback onFavToggle;
  final Widget child;
  final Color backgroundColor, favColor;

  @override
  Widget build(BuildContext context) => Dismissible(
        key: dismissKey,
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          onFavToggle();
          return false;
        },
        background: ColoredBox(color: backgroundColor),
        secondaryBackground: ColoredBox(
          color: favColor.withValues(alpha: 0.15),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 20),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: favColor,
                size: 26,
              ),
            ),
          ),
        ),
        child: child,
      );
}
