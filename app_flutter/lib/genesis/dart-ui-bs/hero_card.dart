// 🧼 חוט-תצוגה · HeroCard — כרטיס-הירו אחיד (תכנון-חיבור/מאתר-על/קטלוג-מגדיר/
// כרטיס-פנימי — 4 ההירואים = מנגנון-אחד + 4 שורות-דאטה). אפס תוכן צרוב.
import 'package:flutter/material.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    required this.glyph, required this.title, required this.sub, required this.onTap,
    required this.cardColor, required this.inkColor, required this.mutedColor,
    required this.borderColor, required this.radius, this.trailing, super.key,
  });
  final String glyph, title, sub;
  final VoidCallback onTap;
  final Color cardColor, inkColor, mutedColor, borderColor;
  final double radius;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: Row(children: [
            if (glyph.isNotEmpty) ...[
              Text(glyph, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: inkColor, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(color: mutedColor, fontSize: 12.5)),
              ]),
            ),
            trailing ?? Icon(Icons.chevron_left, color: mutedColor),
          ]),
        ),
      );
}
