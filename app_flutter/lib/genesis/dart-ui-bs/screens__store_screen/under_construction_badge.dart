// 🧼 אטום · UnderConstructionBadge — תג-סטטוס קטן (רקע/מסגרת/דיו מוזרקים).
// מוצא: screens__store_screen.dart:3729-3748 (תג ה-🚧 של _ServiceSheet). התווית
// (t_eb0da3be) והפיגמנטים (0xFFFFF9C4/0xFFFFD600/0xFF795548) מוזרקים ע״י הקופסה;
// עטיפת CfgVisible = חיווט.
import 'package:flutter/material.dart';

class UnderConstructionBadge extends StatelessWidget {
  const UnderConstructionBadge({
    required this.label, required this.bgColor, required this.borderColor,
    required this.inkColor, super.key,
  });
  final String label;
  final Color bgColor, borderColor, inkColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(color: inkColor, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      );
}
