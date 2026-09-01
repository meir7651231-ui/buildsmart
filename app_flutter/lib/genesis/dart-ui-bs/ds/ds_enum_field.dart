// שדה לנתון מתוך-קבוצה: ערך מרשימת-ערכים-מותרים (enum) · בחירה · מצב · סוג · דרגה.
// בורר על קבוצה סגורה שהוגדרה באפיון ({א|ב|ג}) — לא טקסט-חופשי. חוט-טהור מעל ds.
import 'package:flutter/material.dart';
import 'ds.dart';

class DsEnumField extends StatelessWidget {
  const DsEnumField({required this.label, required this.options, required this.value, required this.onChanged, super.key});
  final String label, value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cur = options.contains(value) ? value : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: DsTokens.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: DsTokens.cardAlt,
              borderRadius: BorderRadius.circular(DsTokens.rSm),
              border: Border.all(color: DsTokens.line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: cur,
                hint: const Text('בחר', style: TextStyle(color: DsTokens.faint, fontSize: 14)),
                icon: const Icon(Icons.expand_more, color: DsTokens.faint),
                items: options
                    .map((o) => DropdownMenuItem<String>(value: o, child: Text(o, style: const TextStyle(color: DsTokens.ink, fontSize: 14, fontWeight: FontWeight.w600))))
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
