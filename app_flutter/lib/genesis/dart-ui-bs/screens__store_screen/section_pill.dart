// 🧼 אטום · SectionPill — גלולת-בחירת-סקשן עם מצב active (צבע+משקל מתחלפים).
// מוצא: screens__store_screen.dart:740 (_Pill). שונה מ-PillButton שבמדף (אין שם active).
// היו צרובים: BsTokens.brand · bsOnAccent · Theme.of(surfaceContainerHighest) · 0xFF595959
// ⇒ activeColor/activeInkColor/idleColor/idleInkColor. הקופסה כותבת storeSectionProvider.
import 'package:flutter/material.dart';

class SectionPill extends StatelessWidget {
  const SectionPill({
    required this.label, required this.active, required this.onTap,
    required this.activeColor, required this.activeInkColor,
    required this.idleColor, required this.idleInkColor, super.key,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor, activeInkColor, idleColor, idleInkColor;

  @override
  Widget build(BuildContext context) => Material(
        color: active ? activeColor : idleColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: active ? activeInkColor : idleInkColor,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
}
