// ✨ קלט · DsNumberField — שדה לנתון מספרי: מספר · סכום · מחיר · תקציב · עלות ·
// כמות · אחוז · שעות · שטח · רווח · יתרה · דירוג · ציון · ערך. תווית + מונה −/+.
// חוט-טהור: אפס-דאטה, material בלבד. (התיאור-העצמי הזה הוא ה-he שהמנוע אוחז לפיו.)
import 'package:flutter/material.dart';
import 'ds.dart';

class DsNumberField extends StatefulWidget {
  const DsNumberField({required this.label, super.key});
  final String label;
  @override
  State<DsNumberField> createState() => _DsNumberFieldState();
}

class _DsNumberFieldState extends State<DsNumberField> {
  int _v = 0;
  Widget _btn(IconData i, VoidCallback f) => InkResponse(
        onTap: f,
        radius: 22,
        child: Container(
          width: 34, height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(9)),
          child: Icon(i, size: 18, color: DsTokens.accentDark),
        ),
      );
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(widget.label, style: const TextStyle(color: DsTokens.ink, fontSize: 14.5, fontWeight: FontWeight.w600))),
            _btn(Icons.remove, () => setState(() => _v--)),
            Container(width: 48, alignment: Alignment.center, child: Text('$_v', style: const TextStyle(color: DsTokens.ink, fontSize: 18, fontWeight: FontWeight.w800))),
            _btn(Icons.add, () => setState(() => _v++)),
          ],
        ),
      );
}
