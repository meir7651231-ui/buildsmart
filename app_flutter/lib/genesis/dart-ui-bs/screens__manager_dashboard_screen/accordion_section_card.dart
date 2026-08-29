// 🧼 אטום · AccordionSectionCard — מקטע-אקורדיון לבן: כותרת-לחיצה (emoji, כותרת+
// תת-כותרת, תג-ספירה, שברון ▾/‹) + גוף-נגלה. מוצא: _ManageSection.
// התרת-סבך: CfgText של הכותרת ⇒ טקסט-אפקטיבי מהקופסה; HelpTarget ⇒ סלוט
// wrapHeader; badge = סלוט CountBadge; open/onTap = state-האקורדיון של הקופסה.
import 'package:flutter/material.dart';

class AccordionSectionCard extends StatelessWidget {
  const AccordionSectionCard({
    required this.emoji, required this.title, required this.sub,
    required this.expanded, required this.onTap, required this.child,
    required this.surfaceColor, required this.borderColor,
    required this.inkColor, required this.mutedColor, required this.radius,
    required this.headerPadding, required this.bodyPadding, required this.gap,
    this.badge, this.wrapHeader, this.semanticsLabel,
    this.chevronExpanded = '▾', this.chevronCollapsed = '‹', super.key,
  });

  final String emoji, title, sub;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;
  final Color surfaceColor, borderColor, inkColor, mutedColor;
  final double radius;

  /// EdgeInsets.all(space4) / EdgeInsetsDirectional.fromSTEB(space4,0,space4,space4).
  final EdgeInsetsGeometry headerPadding, bodyPadding;

  /// BsTokens.space2 במקור (הרווחים הקטנים בכותרת).
  final double gap;
  final Widget? badge;

  /// סלוט-קופסה: עטיפת-הכותרת (HelpTarget #31).
  final Widget Function(Widget header)? wrapHeader;
  final String? semanticsLabel;
  final String chevronExpanded, chevronCollapsed;

  @override
  Widget build(BuildContext context) {
    final header = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(
          padding: headerPadding,
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              SizedBox(width: gap * 1.5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: inkColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: gap),
                          badge!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(color: mutedColor, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              SizedBox(width: gap),
              Text(
                expanded ? chevronExpanded : chevronCollapsed,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: semanticsLabel,
            child: wrapHeader == null ? header : wrapHeader!(header),
          ),
          if (expanded) Padding(padding: bodyPadding, child: child),
        ],
      ),
    );
  }
}
