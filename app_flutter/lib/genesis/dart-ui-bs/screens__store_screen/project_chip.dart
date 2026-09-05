// 🧼 אטום · ProjectChip — צ׳יפ-בחירת-פרויקט (GestureDetector, בלי ריפל — כמו במקור).
// מוצא: screens__store_screen.dart:1905 (_ProjectChip). שמות-הפרויקטים = דאטה-קופסה
// (projectsProvider + checkoutProjectSeeds ב-content); הבחירה = cartProjectProvider בקופסה.
import 'package:flutter/material.dart';

class ProjectChip extends StatelessWidget {
  const ProjectChip({
    required this.label, required this.active, required this.onTap,
    required this.activeColor, required this.activeInkColor,
    required this.idleColor, required this.idleInkColor, super.key,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor, activeInkColor, idleColor, idleInkColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? activeColor : idleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? activeInkColor : idleInkColor,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
}
