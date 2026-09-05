// 🧼 אטום · ProgressStatRow — שורת-שלב בצינור: תווית + ספירה + פס-יחסי צבוע.
// מוצא: _PipelineRow. התרת-סבך: fraction = count/max מחושב בקופסה (מנוע-הצינור),
// onTap = כתיבת managerTabProvider (טאב-ההזמנות); trackColor = שקע-theme
// (surfaceContainerHighest) מוזרק.
import 'package:flutter/material.dart';

class ProgressStatRow extends StatelessWidget {
  const ProgressStatRow({
    required this.label, required this.countLabel, required this.fraction,
    required this.barColor, required this.trackColor, required this.inkColor,
    required this.pillRadius, required this.bottomGap,
    this.onTap, this.semanticsLabel, super.key,
  });

  final String label, countLabel;
  final double fraction;
  final Color barColor, trackColor, inkColor;
  final double pillRadius;

  /// BsTokens.space3 במקור.
  final double bottomGap;
  final VoidCallback? onTap;

  /// הקופסה בונה: '$label: $count' (כמו במקור).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                countLabel,
                style: TextStyle(
                  color: inkColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(pillRadius),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      child: onTap == null
          ? row
          : Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, child: row),
            ),
    );
  }
}
