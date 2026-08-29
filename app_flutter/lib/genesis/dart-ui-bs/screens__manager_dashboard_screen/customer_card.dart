// 🧼 אטום · CustomerCard — כרטיס-לקוח לבן: glyph, שם, שורת-משנה, תגי-חשבון/תפקיד,
// גלולת-סטטוס, פס-אשראי ושורת-האשראי. מוצא: _CustomerCard.
// התרת-סבך: customerCreditProvider/customerScoreProvider/featEnabled ⇒ הקופסה
// מחשבת creditLine/pct ומרכיבה scorePill רק כשהשער דלוק; התגים (⏳/✓/תפקיד) =
// סלוט badges שהקופסה בונה מ-TintedTag; onTap = פתיחת גיליון-הפרטים.
import 'package:flutter/material.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    required this.glyph, required this.name, required this.subLabel,
    required this.creditLine, required this.onTap, required this.statusPill,
    required this.creditBar, required this.surfaceColor, required this.borderColor,
    required this.inkColor, required this.mutedColor, required this.radius,
    required this.padding, required this.gap, required this.sectionGap,
    this.badges, this.scorePill, this.semanticsLabel, super.key,
  });

  final String glyph, name, subLabel, creditLine;
  final VoidCallback onTap;

  /// סלוטים: גלולת-סטטוס (TintedTag) · פס-אשראי (CreditBar) · תגי-חשבון/תפקיד ·
  /// גלולת-RFM (מגודרת manager.scoring בקופסה).
  final Widget statusPill, creditBar;
  final Widget? badges, scorePill;
  final Color surfaceColor, borderColor, inkColor, mutedColor;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// BsTokens.space2 / BsTokens.space3 במקור.
  final double gap, sectionGap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semanticsLabel,
        child: Material(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(glyph, style: const TextStyle(fontSize: 20)),
                      SizedBox(width: gap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: inkColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subLabel,
                              style: TextStyle(color: mutedColor, fontSize: 13),
                            ),
                            if (badges != null) ...[
                              const SizedBox(height: 4),
                              badges!,
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: gap),
                      statusPill,
                    ],
                  ),
                  if (scorePill != null) ...[
                    SizedBox(height: gap),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: scorePill,
                    ),
                  ],
                  SizedBox(height: sectionGap),
                  creditBar,
                  const SizedBox(height: 6),
                  Text(
                    creditLine,
                    style: TextStyle(color: mutedColor, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
