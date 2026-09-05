// 🧼 חוט-תצוגה · QuickToolsList — רשימת-כלים. מנגנון-בלבד: הכלים מוזרקים
// (כבר מסוננים ע"י הקופסה לפי השערים), הפעולות callbacks. אפס תוכן צרוב.
// מוצא: _QuickTools (smart_home_screen.dart) אחרי חילוץ-הדאטה.
import 'package:flutter/material.dart';

typedef QuickTool = ({String emoji, String title, String sub, VoidCallback onTap});

class QuickToolsList extends StatelessWidget {
  const QuickToolsList({
    required this.tools, required this.cardColor, required this.inkColor,
    required this.mutedColor, required this.borderColor, required this.radius,
    super.key,
  });
  final List<QuickTool> tools;
  final Color cardColor, inkColor, mutedColor, borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in tools)
            InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: r.onTap,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: borderColor),
                ),
                child: Row(children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.title, style: TextStyle(color: inkColor, fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(r.sub, style: TextStyle(color: mutedColor, fontSize: 12)),
                    ]),
                  ),
                ]),
              ),
            ),
        ],
      );
}
