// ✨ קלט · DsToggleTile — שדה לנתון דו-ערכי: מתג · פעיל · האם · כן · לא · נכלל ·
// מאושר · חסום · נגיש. תווית + מתג (ערך 'true'/'false'). חוט-טהור: אפס-דאטה, material בלבד.
// (התיאור-העצמי הזה הוא ה-he שהמנוע אוחז לפיו — הידע חי על האטום, לא במנוע.)
import 'package:flutter/material.dart';
import 'ds.dart';

class DsToggleTile extends StatelessWidget {
  const DsToggleTile({required this.label, this.value = '', this.onChanged, super.key});
  final String label, value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final on = value == 'true' || value == '1' || value == 'כן';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: DsTokens.ink, fontSize: 14.5, fontWeight: FontWeight.w600))),
          Switch(
            value: on,
            onChanged: onChanged == null ? null : (v) => onChanged!(v ? 'true' : 'false'),
            activeTrackColor: DsTokens.accent,
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }
}
