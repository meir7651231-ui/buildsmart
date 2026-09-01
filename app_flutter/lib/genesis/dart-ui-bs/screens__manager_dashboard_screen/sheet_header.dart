// 🧼 אטום · SheetHeader — ראש-גיליון ממורכז: glyph 34, כותרת 20 w800, תת-כותרת 13.
// איחד את ראש _OrderDetailSheet ('📦'+id+'שלב · מי') ואת ראש _CustomerDetailSheet
// ('👷'+שם+תגית) — מנגנון זהה ×2; הטקסטים מפורמטים בקופסה.
import 'package:flutter/material.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    required this.glyph, required this.title, required this.subtitle,
    required this.titleColor, required this.subtitleColor, required this.gap,
    super.key,
  });

  final String glyph, title, subtitle;
  final Color titleColor, subtitleColor;

  /// BsTokens.space2 במקור (glyph⇄כותרת).
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(glyph, style: const TextStyle(fontSize: 34), textAlign: TextAlign.center),
          SizedBox(height: gap),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: subtitleColor, fontSize: 13),
          ),
        ],
      );
}
