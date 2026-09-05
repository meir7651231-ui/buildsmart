// 🧼 אטום · SettingsValidatedTextRow — תווית + שדה-טקסט שורה-אחת עם שגיאת-ולידציה.
// מוצא: screens__store_settings_screen.dart · _InlineTextRow (שורות 896–987), verbatim.
// ≠ אטום-המדף SettingsInlineTextRow (maxLines:2, בלי errorText/תת-כותרת): כאן שורה-אחת,
// errorText מוזרק (הקופסה מחשבת ולידציה — האטום רק מציג; מקור 288–293) ו-subtitleNote
// מוזרק (התווית באה מהתוכן; null ⇒ אין; מקור 952–960). דגל underConstruction וסימון
// _Inert לספירת-פעילים = ידע-קופסה. כל הצבעים פיגמנטים-מוזרקים (חוק-5).
import 'package:flutter/material.dart';

class SettingsValidatedTextRow extends StatefulWidget {
  const SettingsValidatedTextRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.labelColor,
    required this.inkColor,
    required this.mutedColor,
    required this.cursorColor,
    required this.hintColor,
    required this.fillColor,
    this.errorText,
    this.subtitleNote,
    super.key,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final Color labelColor;
  final Color inkColor;
  final Color mutedColor;
  final Color cursorColor;
  final Color hintColor;
  final Color fillColor;

  /// null ⇒ valid (no error row). Recomputed by the wiring box on each change.
  final String? errorText;

  /// null ⇒ no note row under the label.
  final String? subtitleNote;

  @override
  State<SettingsValidatedTextRow> createState() =>
      _SettingsValidatedTextRowState();
}

class _SettingsValidatedTextRowState extends State<SettingsValidatedTextRow> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant SettingsValidatedTextRow old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: TextStyle(color: widget.labelColor, fontSize: 13),
          ),
          if (widget.subtitleNote != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                widget.subtitleNote!,
                style: TextStyle(color: widget.mutedColor, fontSize: 12),
              ),
            ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            style: TextStyle(color: widget.inkColor),
            cursorColor: widget.cursorColor,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: widget.hintColor),
              errorText: widget.errorText,
              filled: true,
              fillColor: widget.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
