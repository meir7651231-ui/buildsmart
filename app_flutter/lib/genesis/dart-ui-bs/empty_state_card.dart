// 🧼 אטום-משותף · EmptyStateCard — מצב-ריק (איחד _EmptyAccessories/Categories/Trades ×3).
// הגליף והטקסט מוזרקים (היו צרובים: '🧩'+'אין עדיין אביזרים') — אפס-דאטה.
import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    required this.glyph, required this.message,
    required this.surfaceColor, required this.mutedColor, required this.borderColor,
    required this.radius, super.key,
  });
  final String glyph, message;
  final Color surfaceColor, mutedColor, borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
        ),
        child: Column(children: [
          Text(glyph, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      );
}
