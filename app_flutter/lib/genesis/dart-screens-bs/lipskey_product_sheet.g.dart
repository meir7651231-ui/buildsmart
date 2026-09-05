// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__lipskey_product_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/empty_hint.dart';
import '../dart-ui-bs/auto/lipskey_product_sheet_divider.dart';
import '../dart-ui-bs/auto/picker_option.dart';
import '../dart-ui-bs/auto/qty_stepper.dart';
import '../dart-ui-bs/auto/section_title.dart';
import '../dart-ui-bs/auto/zoom_hint.dart';
import '../dart-data-bs/auto/screens__lipskey_product_sheet_content.dart';
import '../dart-data-bs/auto/screens__lipskey_product_sheet_content2.dart';
import '../dart-data-bs/screens__lipskey_product_sheet_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class PickerOptionItem {
  const PickerOptionItem({required this.value, required this.isSelected, required this.onTap});
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class LipskeyProductSheetTokens {
  const LipskeyProductSheetTokens();

}

class LipskeyProductSheetComposed extends StatelessWidget {
  const LipskeyProductSheetComposed({required this.onChanged, required this.pickerOptionItems, required this.qty, required this.subtitle, required this.text, required this.t, super.key});

  final ValueChanged<int> onChanged;
  final List<PickerOptionItem> pickerOptionItems;
  final int qty;
  final String? subtitle;
  final String text;
  final LipskeyProductSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          LipskeyProductSheetDivider(
            
          ),
          SectionTitle(
            emoji: section_title_emoji,
            title: lineBomSheet.title,
            subtitle: subtitle,
          ),
          QtyStepper(
            qty: qty,
            onChanged: onChanged,
          ),
          ZoomHint(
            fallback: zoom_hint_fallback,
          ),
          EmptyHint(
            text,
          ),
          for (final opt in pickerOptionItems) ...[
          PickerOption(
            value: opt.value,
            isSelected: opt.isSelected,
            onTap: opt.onTap,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
