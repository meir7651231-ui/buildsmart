// ✨ קלט · DsField — שדה לנתון טקסט חופשי: שם · כתובת · תיאור · הערה · מיקום ·
// טקסט · פרטים · כותרת. תווית-מעל + קלט מעוגל עם הילת-מיקוד. חוט-טהור: אפס-דאטה.
// (התיאור-העצמי הזה הוא ה-he שהמנוע אוחז לפיו — הידע חי על האטום, לא במנוע.)
import 'package:flutter/material.dart';
import 'ds.dart';

class DsField extends StatefulWidget {
  const DsField({required this.label, required this.hint, required this.value, required this.onChanged, this.bare = false, super.key});
  final String label, hint, value;
  final ValueChanged<String> onChanged;
  /// G13c · bare=true ⇒ שדה-הקלט בלבד (בלי תווית/ריפוד) — נכנס לחריץ-ה-control של אטום-forge שמצייר את התווית. false ⇒ ביט-זהה.
  final bool bare;
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
              style: TextStyle(color: lk.ink, fontSize: 15, fontWeight: FontWeight.w500),
              cursorColor: lk.accent,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: TextStyle(color: lk.faint, fontSize: 14),
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
