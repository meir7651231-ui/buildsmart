// 🧼 אטום · OrderRowCard — כרטיס-הזמנה לבן: כותרת-id + גלולת-שלב, שורת-משנה,
// סלוט-קשר, עוקב-שלבים, כותרת-תחתית + פעולה/תג-הושלם. מוצא: _OrderRow.
// נבדק OrderCard מהמדף — כרטיס-קטלוג (stage/items/sum אנכי, width קבוע) ⇒ מבנה שונה.
// התרת-סבך: כל התוויות מפורמטות בקופסה (orderRowContent tpl); _StagePill/
// _MiniTracker/ContactActions/כפתור-הקידום = סלוטי-Widget (חוק-1: אטום לא מייבא אטום).
import 'package:flutter/material.dart';

class OrderRowCard extends StatelessWidget {
  const OrderRowCard({
    required this.idLabel, required this.subLabel, required this.footerLabel,
    required this.onTap, required this.stagePill, required this.tracker,
    required this.trailing, required this.surfaceColor, required this.borderColor,
    required this.inkColor, required this.mutedColor, required this.radius,
    required this.padding, required this.sectionGap,
    this.contact, this.semanticsLabel, super.key,
  });

  /// כותרת-המזהה (glyph+id) — מפורמטת בקופסה מ-orderRowContent.idTpl.
  final String idLabel;

  /// שורת מי·אתר — מפורמטת בקופסה.
  final String subLabel;

  /// שורת פריטים·סכום — מפורמטת בקופסה מ-orderRowContent.footerTpl.
  final String footerLabel;
  final VoidCallback onTap;

  /// סלוטים: גלולת-שלב (TintedTag), עוקב (MiniStageTracker),
  /// פעולה/תג-סיום (PillCtaButton/TintedTag), פעולות-קשר (ContactActions).
  final Widget stagePill, tracker, trailing;
  final Widget? contact;
  final Color surfaceColor, borderColor, inkColor, mutedColor;
  final double radius;

  /// EdgeInsets.all(space4) במקור.
  final EdgeInsetsGeometry padding;

  /// BsTokens.space3 במקור (עוקב⇄שכנים).
  final double sectionGap;
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
                    children: [
                      Expanded(
                        child: Text(
                          idLabel,
                          style: TextStyle(
                            color: inkColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      stagePill,
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subLabel,
                    style: TextStyle(color: mutedColor, fontSize: 13),
                  ),
                  if (contact != null) contact!,
                  SizedBox(height: sectionGap),
                  tracker,
                  SizedBox(height: sectionGap),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          footerLabel,
                          style: TextStyle(
                            color: inkColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      trailing,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
