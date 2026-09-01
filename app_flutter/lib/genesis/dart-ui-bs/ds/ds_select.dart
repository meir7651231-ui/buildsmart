// שדה לנתון קשר: בורר-רשומה מישות-אחרת · הפניה · שיוך · קישור · בחירה מרשימה חיה.
// שומר את מזהה-היעד (__id) — לא את מחרוזת-התצוגה — כך שהקשר שורד שינוי-שם ומצביע יציב.
// מציג את שם-היעד. חוט-טהור מעל ds + חנות.
import 'package:flutter/material.dart';
import 'ds.dart';
import 'ds_store.dart';

class DsSelect extends StatelessWidget {
  const DsSelect({required this.label, required this.entity, required this.value, required this.onChanged, super.key});
  final String label, entity, value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        final opts = appStore.options(entity); // (id → display)
        final ids = opts.map((e) => e.key).toSet();
        final cur = ids.contains(value) ? value : null;
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
                child: opts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text('אין $entity עדיין — הוסף כדי לקשר', style: const TextStyle(color: DsTokens.faint, fontSize: 13)),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: cur,
                          hint: Text('בחר $entity', style: const TextStyle(color: DsTokens.faint, fontSize: 14)),
                          icon: const Icon(Icons.expand_more, color: DsTokens.faint),
                          items: opts
                              .map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.ink, fontSize: 14, fontWeight: FontWeight.w600))))
                              .toList(),
                          onChanged: (v) => onChanged(v ?? ''),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
