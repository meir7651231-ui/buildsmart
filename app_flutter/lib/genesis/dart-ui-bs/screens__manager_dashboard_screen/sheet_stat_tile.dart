// 🧼 אטום · SheetStatTile — אריח-סטטיסטיקה בתוך-גיליון (ערך 16 w800 + תווית 12,
// מסגרת, margin אופקי 4). איחד את tile() של _OrderDetailSheet + _CustomerDetailSheet
// (סוגר-פנימי זהה ×2 במקור). הערכים מפורמטים בקופסה.
import 'package:flutter/material.dart';

class SheetStatTile extends StatelessWidget {
  const SheetStatTile({
    required this.value, required this.label, required this.surfaceColor,
    required this.borderColor, required this.valueColor, required this.labelColor,
    required this.verticalPadding, super.key,
  });

  final String value, label;
  final Color surfaceColor, borderColor, valueColor, labelColor;

  /// BsTokens.space3 במקור.
  final double verticalPadding;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
            ],
          ),
        ),
      );
}
