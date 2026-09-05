// 🧼 אטום · SmartCartLineCard — כרטיס-שורת-סל-חכם: thumb, כותרת+מותג, סטפר, סה״כ,
// הסרה, ורשימת-אביזרים. מוצא: screens__store_screen.dart:1941 (_SmartCartRow).
// התרת-סבך: cartLineThumb (productBySku, שכבת-דאטה) ⇒ thumb כ-Widget-slot;
// smartCartProvider (setLineQty/remove) ⇒ stepper-slot + onRemove; התוויות מפורמטות
// בקופסה: titleLabel (שם × כמות) · totalLabel (₪) · removeLabel (t_a530b6eb) ·
// accessories כרשומות (emoji/label-שם×כמות/priceLabel).
import 'package:flutter/material.dart';

typedef SmartCartAccessory = ({String emoji, String label, String priceLabel});

class SmartCartLineCard extends StatelessWidget {
  const SmartCartLineCard({
    required this.thumb, required this.titleLabel, required this.brandName,
    required this.totalLabel, required this.removeLabel, required this.onRemove,
    required this.stepper, required this.accessories,
    required this.surfaceColor, required this.accentColor,
    required this.inkColor, required this.mutedColor,
    required this.accessoryInkColor, required this.dividerColor,
    required this.removeIconColor, super.key,
  });
  final Widget thumb, stepper;
  final String titleLabel, brandName, totalLabel, removeLabel;
  final VoidCallback onRemove;
  final List<SmartCartAccessory> accessories;
  final Color surfaceColor, accentColor, inkColor, mutedColor;
  final Color accessoryInkColor, dividerColor, removeIconColor;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: thumb,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleLabel,
                        style: TextStyle(color: inkColor, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(brandName, style: TextStyle(color: mutedColor, fontSize: 11)),
                    ],
                  ),
                ),
                stepper,
                const SizedBox(width: 8),
                Text(
                  totalLabel,
                  style: TextStyle(color: accentColor, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  tooltip: removeLabel,
                  icon: Icon(Icons.close, color: removeIconColor, size: 18),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  // יעד-הקשה ≥48dp (a11y) — הוויזואליה ללא-שינוי.
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ],
            ),
            if (accessories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Divider(height: 1, color: dividerColor),
              const SizedBox(height: 6),
              for (final a in accessories)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(a.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          a.label,
                          style: TextStyle(color: accessoryInkColor, fontSize: 12),
                        ),
                      ),
                      Text(a.priceLabel, style: TextStyle(color: mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      );
}
