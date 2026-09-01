// שדה לנתון קשר-רבים: בחירה-מרובה של רשומות מישות-אחרת · שיוך-רבים · רשימת-הפניות.
// שומר רשימת-מזהים (מופרדת-פסיק), מציג שבבים נשלפים + הוספה מהרשומות החיות. חוט-טהור.
import 'package:flutter/material.dart';
import 'ds.dart';
import 'ds_store.dart';

class DsMultiSelect extends StatelessWidget {
  const DsMultiSelect({required this.label, required this.entity, required this.value, required this.onChanged, super.key});
  final String label, entity, value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        final ids = value.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty).toList();
        final opts = appStore.options(entity);
        final remaining = opts.where((o) => !ids.contains(o.key)).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: DsTokens.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (ids.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final id in ids)
                        Container(
                          padding: const EdgeInsets.only(left: 4, right: 10, top: 4, bottom: 4),
                          decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(appStore.displayOf(entity, id).isEmpty ? id : appStore.displayOf(entity, id),
                                style: const TextStyle(color: DsTokens.accentDark, fontSize: 12.5, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => onChanged((ids.where((x) => x != id)).join(',')),
                              child: const Icon(Icons.close, size: 15, color: DsTokens.accentDark),
                            ),
                          ]),
                        ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: DsTokens.cardAlt,
                  borderRadius: BorderRadius.circular(DsTokens.rSm),
                  border: Border.all(color: DsTokens.line),
                ),
                child: remaining.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(opts.isEmpty ? 'אין $entity עדיין — הוסף כדי לקשר' : 'כל ה$entity נבחרו',
                            style: const TextStyle(color: DsTokens.faint, fontSize: 13)),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: null,
                          hint: Text('הוסף $entity', style: const TextStyle(color: DsTokens.faint, fontSize: 14)),
                          icon: const Icon(Icons.add, color: DsTokens.faint),
                          items: remaining
                              .map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.ink, fontSize: 14, fontWeight: FontWeight.w600))))
                              .toList(),
                          onChanged: (v) => onChanged(([...ids, if (v != null) v]).join(',')),
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
