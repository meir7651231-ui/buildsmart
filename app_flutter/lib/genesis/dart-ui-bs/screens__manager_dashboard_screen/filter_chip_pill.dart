// 🧼 אטום · FilterChipPill — צ׳יפ-סינון: נבחר = מילוי-מותג, אחרת מתאר בהיר.
// איחד את chip() של _OrderStageChips + _CustomerStatusChips + _AccountFilterChips
// (מנגנון זהה ×3; ההבדל היחיד — פורמט-התווית '$label ($count)' — אצל הקופסה).
// התרת-סבך: עטיפת-HelpTarget (#31) והרכבת-השורה (Wrap spacing space2) = קופסה.
import 'package:flutter/material.dart';

class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    required this.label, required this.selected, required this.onTap,
    required this.activeFillColor, required this.surfaceColor,
    required this.activeTextColor, required this.inkColor,
    required this.outlineColor, required this.pillRadius, super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeFillColor, surfaceColor, activeTextColor, inkColor, outlineColor;
  final double pillRadius;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? activeFillColor : surfaceColor,
        borderRadius: BorderRadius.circular(pillRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(pillRadius),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(pillRadius),
              border: selected ? null : Border.all(color: outlineColor),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? activeTextColor : inkColor,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      );
}
