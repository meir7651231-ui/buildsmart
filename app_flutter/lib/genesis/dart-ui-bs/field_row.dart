// 🎨 חוט-תצוגה · FieldRow — שדה-טופס נקי: תווית-מעל + קלט שורה-אחת ממולא, פינות
// מעוגלות והילת-מיקוד. אפס-דאטה — תווית · רמז · ערך · צבעים מוזרקים בחיווט; הבקר
// הפנימי שלו, מיקוד ע"י focusedBorder (בלי מאזין). חוק-1/חוק-5.
import 'package:flutter/material.dart';

class FieldRow extends StatefulWidget {
  const FieldRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.inkColor,
    required this.mutedColor,
    required this.accentColor,
    required this.fillColor,
    required this.borderColor,
    super.key,
  });

  final String label, hint, value;
  final ValueChanged<String> onChanged;
  final Color inkColor, mutedColor, accentColor, fillColor, borderColor;

  @override
  State<FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<FieldRow> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant FieldRow old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) _ctrl.text = widget.value;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 5),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.mutedColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              style: TextStyle(color: widget.inkColor, fontSize: 15),
              cursorColor: widget.accentColor,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: TextStyle(color: widget.mutedColor, fontSize: 14),
                filled: true,
                fillColor: widget.fillColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: widget.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: widget.accentColor, width: 1.6),
                ),
              ),
            ),
          ],
        ),
      );
}
