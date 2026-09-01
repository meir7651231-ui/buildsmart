// 🧼 אטום-משותף · PillButton — כפתור-גלולה (איחד ×6 עותקי _PillButton מ-trade_builder).
// מוצא: accessory_rule_editor.dart (origin/main) · verbatim, טוקנים מוזרקים.
import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    required this.label, required this.onTap,
    required this.brandColor, required this.disabledColor,
    required this.onAccentColor, required this.mutedColor,
    required this.pillRadius, this.enabled = true, super.key,
  });
  final String label;
  final VoidCallback onTap;
  final Color brandColor, disabledColor, onAccentColor, mutedColor;
  final double pillRadius;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true, enabled: enabled, label: label,
        child: Material(
          color: enabled ? brandColor : disabledColor,
          borderRadius: BorderRadius.circular(pillRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(pillRadius),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(label, textAlign: TextAlign.center,
                  style: TextStyle(color: enabled ? onAccentColor : mutedColor,
                      fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      );
}
