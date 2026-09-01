// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__budget_screen:_Tappable (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';

class Tappable extends StatelessWidget {
  const Tappable({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: child,
      );
}
