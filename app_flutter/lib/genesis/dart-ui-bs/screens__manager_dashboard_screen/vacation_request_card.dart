// 🧼 אטום · VacationRequestCard — כרטיס-בקשת-חופשה: כותרת (glyph·שם·טווח),
// גלולת-סטטוס להוחלטה, סיבה, ושורת-פעולות לממתינה. מוצא: _VacationRequestRow.
// התרת-סבך: _isCourierVacationRequest ⇒ הקופסה בוחרת glyph (🛵/🦺 מה-content)
// ומפרמטת titleLabel; statusPill (TintedTag 'אושרה'/'נדחתה') וכפתורי ✅/❌
// (PillCtaButton עטופי-HelpTarget, vac-approve/vac-reject keys) = סלוטים.
import 'package:flutter/material.dart';

class VacationRequestCard extends StatelessWidget {
  const VacationRequestCard({
    required this.titleLabel, required this.surfaceColor,
    required this.borderColor, required this.inkColor, required this.mutedColor,
    required this.padding, required this.actionsGap,
    this.reason = '', this.statusPill, this.actions, super.key,
  });

  final String titleLabel, reason;
  final Widget? statusPill, actions;
  final Color surfaceColor, borderColor, inkColor, mutedColor;

  /// EdgeInsets.all(space3) במקור.
  final EdgeInsetsGeometry padding;

  /// BsTokens.space3 במקור (הרווח לפני שורת-הפעולות).
  final double actionsGap;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    titleLabel,
                    style: TextStyle(
                      color: inkColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (statusPill != null) statusPill!,
              ],
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(reason, style: TextStyle(color: mutedColor, fontSize: 12.5)),
            ],
            if (actions != null) ...[
              SizedBox(height: actionsGap),
              actions!,
            ],
          ],
        ),
      );
}
