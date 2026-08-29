// 🧼 חוט-תצוגה · TitledSection — כותרת-סקציה + תוכן (התבנית של כל סקציות-הבית).
// הכותרת מוזרקת (homeSectionTitles), אפס טקסט צרוב.
import 'package:flutter/material.dart';

class TitledSection extends StatelessWidget {
  const TitledSection({required this.title, required this.inkColor, required this.child, super.key});
  final String title;
  final Color inkColor;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: TextStyle(color: inkColor, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          child,
        ],
      );
}
