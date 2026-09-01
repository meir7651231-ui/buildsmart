// 🧼 אטום · PendingCheckRow — שורת-רשימת-אישור: צ׳קבוקס + שם(·תפקיד) + תג-ממתין.
// מוצא: _PendingRow. התרת-סבך: DirectoryEntry ⇒ label מפורמט בקופסה
// (pendingRowContent.nameWithRoleTpl + bsRoleLabels); התג והצבע מה-content.
import 'package:flutter/material.dart';

class PendingCheckRow extends StatelessWidget {
  const PendingCheckRow({
    required this.label, required this.tagLabel, required this.tagColor,
    required this.checked, required this.enabled, required this.onChanged,
    required this.inkColor, required this.activeColor, required this.gap,
    super.key,
  });

  final String label, tagLabel;
  final Color tagColor, inkColor, activeColor;
  final bool checked, enabled;
  final ValueChanged<bool> onChanged;

  /// BsTokens.space2 במקור.
  final double gap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: enabled ? () => onChanged(!checked) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                activeColor: activeColor,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              SizedBox(width: gap),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: gap),
              Text(
                tagLabel,
                style: TextStyle(
                  color: tagColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
}
