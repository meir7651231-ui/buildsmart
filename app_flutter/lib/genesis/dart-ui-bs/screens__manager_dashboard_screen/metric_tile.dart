// 🧼 אטום · MetricTile — אריח-KPI לבן: emoji, מספר-מותג גדול, תווית מושתקת.
// מוצא: _MetricTile. התרת-סבך: elementVisible(cfgId) ⇒ הקופסה מגדרת הרכבה;
// CfgText של התווית ⇒ הקופסה מזריקה את הטקסט-האפקטיבי; onTap = drill-down
// (כתיבת managerTabProvider לפי drillTab מה-content). null ⇒ לא-אינטראקטיבי.
import 'package:flutter/material.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.emoji, required this.value, required this.label,
    required this.surfaceColor, required this.borderColor,
    required this.valueColor, required this.labelColor,
    required this.radius, required this.padding, required this.gap,
    this.onTap, this.semanticsLabel, super.key,
  });

  final String emoji, value, label;
  final Color surfaceColor, borderColor, valueColor, labelColor;
  final double radius;

  /// EdgeInsets.symmetric(horizontal: space4, vertical: space4) במקור.
  final EdgeInsetsGeometry padding;

  /// BsTokens.space2 במקור (emoji⇄מספר).
  final double gap;
  final VoidCallback? onTap;

  /// הקופסה בונה: '$emoji $label: $value' (כמו במקור).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          SizedBox(height: gap),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 26,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      child: onTap == null
          ? card
          : Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(radius),
                child: card,
              ),
            ),
    );
  }
}
