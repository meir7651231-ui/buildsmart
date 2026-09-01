// 🧼 אטום · SettingsNumberRow — תווית משמאל + שדה-ספרות צר בקצה השורה.
// מוצא: screens__store_settings_screen.dart · _NumberRow (שורות 989–1087), verbatim.
// אין מקבילה במדף (נבדק: grep digitsOnly / TextInputType.number על new/dart-ui-bs ⇒ ריק).
// underConstruction הוחלף ב-subtitleNote מוזרק (התווית מהתוכן; null ⇒ אין); סימון _Inert
// לספירת-פעילים = ידע-קופסה. פרסור int.tryParse??0 נשאר כאן — מנגנון-קלט, לא לוגיקת-מוצר.
// כל הצבעים פיגמנטים-מוזרקים; רוחב-השדה טוקן-עיצוב כפרמטר (מקור: 100).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsNumberRow extends StatefulWidget {
  const SettingsNumberRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.inkColor,
    required this.mutedColor,
    required this.cursorColor,
    required this.fillColor,
    this.subtitleNote,
    this.fieldWidth = 100,
    super.key,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final Color inkColor;
  final Color mutedColor;
  final Color cursorColor;
  final Color fillColor;

  /// null ⇒ no note row under the label.
  final String? subtitleNote;

  final double fieldWidth;

  @override
  State<SettingsNumberRow> createState() => _SettingsNumberRowState();
}

class _SettingsNumberRowState extends State<SettingsNumberRow> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.value.toString(),
  );

  @override
  void didUpdateWidget(covariant SettingsNumberRow old) {
    super.didUpdateWidget(old);
    final current = int.tryParse(_ctrl.text) ?? 0;
    if (widget.value != current) {
      _ctrl.text = widget.value.toString();
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(color: widget.inkColor, fontSize: 14),
                ),
                if (widget.subtitleNote != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      widget.subtitleNote!,
                      style: TextStyle(color: widget.mutedColor, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: widget.fieldWidth,
            child: TextField(
              controller: _ctrl,
              style: TextStyle(color: widget.inkColor),
              cursorColor: widget.cursorColor,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              onChanged: (v) => widget.onChanged(int.tryParse(v) ?? 0),
            ),
          ),
        ],
      ),
    );
  }
}
