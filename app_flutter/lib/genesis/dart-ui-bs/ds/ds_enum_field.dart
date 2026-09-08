// שדה לנתון מתוך-קבוצה: ערך מרשימת-ערכים-מותרים (enum) · בחירה · מצב · סוג · דרגה.
// בורר על קבוצה סגורה שהוגדרה באפיון ({א|ב|ג}) — לא טקסט-חופשי. חוט-טהור מעל ds.
import 'package:flutter/material.dart';
import 'ds.dart';

class DsEnumField extends StatelessWidget {
  const DsEnumField({required this.label, required this.options, required this.value, required this.onChanged, this.bare = false, super.key});
  final String label, value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  /// G13c · bare=true ⇒ הבורר בלבד (בלי תווית/ריפוד). false ⇒ ביט-זהה.
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final cur = options.contains(value) ? value : null;
    return Padding(
      padding: bare ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!bare) Text(label, style: TextStyle(color: lk.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
          if (!bare) const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: lk.cardAlt,
              borderRadius: BorderRadius.circular(lk.rSm),
              border: Border.all(color: lk.line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: cur,
                hint: Text('בחר', style: TextStyle(color: lk.faint, fontSize: 14)),
                icon: Icon(Icons.expand_more, color: lk.faint),
                items: options
                    .map((o) => DropdownMenuItem<String>(value: o, child: Text(o, style: TextStyle(color: lk.ink, fontSize: 14, fontWeight: FontWeight.w600))))
                    .toList(),
                onChanged: (v) => onChanged(v ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
