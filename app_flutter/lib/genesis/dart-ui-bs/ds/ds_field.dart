// ✨ קלט · DsField — שדה לנתון טקסט חופשי: שם · כתובת · תיאור · הערה · מיקום ·
// טקסט · פרטים · כותרת. תווית-מעל + קלט מעוגל עם הילת-מיקוד. חוט-טהור: אפס-דאטה.
// (התיאור-העצמי הזה הוא ה-he שהמנוע אוחז לפיו — הידע חי על האטום, לא במנוע.)
import 'package:flutter/material.dart';
import 'ds.dart';

class DsField extends StatefulWidget {
  const DsField({required this.label, required this.hint, required this.value, required this.onChanged, super.key});
  final String label, hint, value;
  final ValueChanged<String> onChanged;
  @override
  State<DsField> createState() => _DsFieldState();
}

class _DsFieldState extends State<DsField> {
  late final TextEditingController _c = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant DsField o) {
    super.didUpdateWidget(o);
    if (widget.value != _c.text) _c.text = widget.value;
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 6),
              child: Text(widget.label, style: const TextStyle(color: DsTokens.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            TextField(
              controller: _c,
              onChanged: widget.onChanged,
              style: const TextStyle(color: DsTokens.ink, fontSize: 15, fontWeight: FontWeight.w500),
              cursorColor: DsTokens.accent,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: const TextStyle(color: DsTokens.faint, fontSize: 14),
                filled: true,
                fillColor: DsTokens.cardAlt,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DsTokens.rSm), borderSide: const BorderSide(color: DsTokens.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DsTokens.rSm), borderSide: const BorderSide(color: DsTokens.accent, width: 1.6)),
              ),
            ),
          ],
        ),
      );
}
