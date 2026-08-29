// 🧼 אטום · SupplierHeader — כותרת-קבוצת-ספק בסל: תווית + זמן-אספקה מוזרקים.
// מוצא: screens__store_screen.dart:2131 (_SupplierHeader). קידומת-הגליף 🏪 והמונח
// t_67ea9596 (זמן-אספקה, CfgText) היו צרובים ⇒ הקופסה מפרמטת label + leadTimeLabel.
import 'package:flutter/material.dart';

class SupplierHeader extends StatelessWidget {
  const SupplierHeader({
    required this.label, required this.leadTimeLabel,
    required this.inkColor, required this.mutedColor, super.key,
  });
  final String label, leadTimeLabel;
  final Color inkColor, mutedColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: inkColor, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(leadTimeLabel, style: TextStyle(color: mutedColor, fontSize: 11)),
          ],
        ),
      );
}
