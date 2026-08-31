// ✨ קלט · DsToggleTile — שדה לנתון דו-ערכי: מתג · פעיל · סטטוס · מצב · האם ·
// כן · לא · נכלל · מאושר · חסום. תווית + מתג. חוט-טהור: אפס-דאטה, material בלבד.
// (התיאור-העצמי הזה הוא ה-he שהמנוע אוחז לפיו — הידע חי על האטום, לא במנוע.)
import 'package:flutter/material.dart';
import 'ds.dart';

class DsToggleTile extends StatefulWidget {
  const DsToggleTile({required this.label, super.key});
  final String label;
  @override
  State<DsToggleTile> createState() => _DsToggleTileState();
}

class _DsToggleTileState extends State<DsToggleTile> {
  bool _on = false;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(widget.label, style: const TextStyle(color: DsTokens.ink, fontSize: 14.5, fontWeight: FontWeight.w600))),
            Switch(
              value: _on,
              onChanged: (v) => setState(() => _on = v),
              activeTrackColor: DsTokens.accent,
              thumbColor: WidgetStateProperty.all(Colors.white),
            ),
          ],
        ),
      );
}
