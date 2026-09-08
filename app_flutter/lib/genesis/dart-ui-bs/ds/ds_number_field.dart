// ✨ קלט · DsNumberField — שדה לנתון מספרי: מספר · סכום · מחיר · תקציב · עלות ·
// כמות · אחוז · שעות · שטח · רווח · יתרה · דירוג · ציון · ערך. תווית + קלט-מספרי.
// חוט-טהור: אפס-דאטה, material בלבד. (התיאור-העצמי הזה הוא ה-he שהמנוע אוחז לפיו.)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ds.dart';

class DsNumberField extends StatefulWidget {
  const DsNumberField({required this.label, required this.value, required this.onChanged, this.bare = false, super.key});
  final String label, value;
  final ValueChanged<String> onChanged;
  /// G13c · bare=true ⇒ שדה-הקלט בלבד (בלי תווית/ריפוד). false ⇒ ביט-זהה.
  final bool bare;
  @override
  State<DsNumberField> createState() => _DsNumberFieldState();
}

class _DsNumberFieldState extends State<DsNumberField> {
  late final TextEditingController _c = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant DsNumberField o) {
    super.didUpdateWidget(o);
    if (widget.value != _c.text) _c.text = widget.value;
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return Padding(
        padding: widget.bare ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.bare) Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 6),
              child: Text(widget.label, style: TextStyle(color: lk.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            TextField(
              controller: _c,
              onChanged: widget.onChanged,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
              style: TextStyle(color: lk.ink, fontSize: 15, fontWeight: FontWeight.w600),
              cursorColor: lk.accent,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: lk.cardAlt,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(lk.rSm), borderSide: BorderSide(color: lk.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(lk.rSm), borderSide: BorderSide(color: lk.accent, width: 1.6)),
              ),
            ),
          ],
        ),
      );
  }
}
