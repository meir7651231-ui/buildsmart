// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__catalog_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/acc_row.dart';
import '../dart-ui-bs/auto/axis_chip.dart';
import '../dart-ui-bs/auto/catalog_count_badge.dart';
import '../dart-ui-bs/auto/chip_wrap.dart';
import '../dart-ui-bs/auto/company_catalog_import_card.dart';
import '../dart-ui-bs/auto/empty_section.dart';
import '../dart-ui-bs/auto/facet_chip.dart';
import '../dart-ui-bs/auto/facet_row.dart';
import '../dart-ui-bs/auto/mini_qty_btn.dart';
import '../dart-ui-bs/auto/saved_version_chip.dart';
import '../dart-ui-bs/auto/section_header.dart';
import '../dart-ui-bs/auto/sheet_section.dart';
import '../dart-ui-bs/auto/tree_coming_soon.dart';
import '../dart-ui-bs/auto/value_chip.dart';
import '../dart-data-bs/auto/screens__catalog_screen_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class FacetRowItem {
  const FacetRowItem({required this.label, required this.desc, required this.count, required this.onTap});
  final String label;
  final String desc;
  final int count;
  final VoidCallback onTap;
}

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class SavedVersionChipItem {
  const SavedVersionChipItem({required this.label, required this.onLoad, required this.onDelete});
  final String label;
  final VoidCallback onLoad;
  final VoidCallback onDelete;
}

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class AxisChipItem {
  const AxisChipItem({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CatalogScreenTokens {
  const CatalogScreenTokens({required this.color});
  final Color color;
}

class CatalogScreenComposed extends StatelessWidget {
  const CatalogScreenComposed({required this.onQtyChanged,ValueChanged<int>, required this.onSelect,void Function(String), required this.onTap,VoidCallback, required this.onToggle,ValueChanged<bool>?, required this.activeMatch, required this.axisChipItems, required this.child, required this.count, required this.emoji, required this.expanded, required this.facetRowItems, required this.icon, required this.isSelected, required this.label, required this.name, required this.options, required this.price, required this.qty, required this.savedVersionChipItems, required this.selected, required this.selected2, required this.text, required this.title, required this.value, required this.why, required this.t, super.key});

  final ValueChanged<int> onQtyChanged;
  final void Function(String) onSelect;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggle;
  final List<String>? activeMatch;
  final List<AxisChipItem> axisChipItems;
  final Widget child;
  final int count;
  final String emoji;
  final bool expanded;
  final List<FacetRowItem> facetRowItems;
  final IconData icon;
  final bool isSelected;
  final String label;
  final String name;
  final List<String> options;
  final int? price;
  final int qty;
  final List<SavedVersionChipItem> savedVersionChipItems;
  final String? selected;
  final bool selected2;
  final String text;
  final String title;
  final String value;
  final String why;
  final CatalogScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          CompanyCatalogImportCard(
            label: company_catalog_import_card_label,
            label2: company_catalog_import_card_label2,
            label3: company_catalog_import_card_label3,
            label4: company_catalog_import_card_label4,
            onTap: onTap,
          ),
          SectionHeader(
            title,
          ),
          EmptySection(
            fallback: empty_section_fallback,
            emoji: emoji,
            label: label,
          ),
          for (final o in facetRowItems) ...[
          FacetRow(
            label2: facet_row_label2,
            label: o.label,
            desc: o.desc,
            count: o.count,
            onTap: o.onTap,
          ),
          const SizedBox(height: 8),
        ],
          TreeComingSoon(
            fallback: tree_coming_soon_fallback,
            fallback2: tree_coming_soon_fallback2,
            title: title,
            emoji: emoji,
          ),
          CatalogCountBadge(
            label: label,
            count: count,
            color: t.color,
          ),
          SheetSection(
            title: title,
            value: value,
            expanded: expanded,
            onToggle: onToggle,
            child: child,
          ),
          ChipWrap(
            options: options,
            selected: selected,
            onSelect: onSelect,
          ),
          for (final v in savedVersionChipItems) ...[
          SavedVersionChip(
            message: saved_version_chip_message,
            label2: saved_version_chip_label2,
            message2: saved_version_chip_message2,
            label3: saved_version_chip_label3,
            label: v.label,
            onLoad: v.onLoad,
            onDelete: v.onDelete,
          ),
          const SizedBox(height: 8),
        ],
          AccRow(
            label: acc_row_label,
            label2: acc_row_label2,
            name: name,
            emoji: emoji,
            why: why,
            price: price,
            onTap: onTap,
            label3: acc_row_label3,
            label4: acc_row_label4,
            selected: selected2,
            qty: qty,
            onToggle: onToggle,
            onQtyChanged: onQtyChanged,
            activeMatch: activeMatch,
          ),
          MiniQtyBtn(
            label: mini_qty_btn_label,
            label2: mini_qty_btn_label2,
            icon: icon,
            onTap: onTap,
          ),
          ValueChip(
            text: text,
          ),
          for (final axis in axisChipItems) ...[
          AxisChip(
            label: axis.label,
            isSelected: axis.isSelected,
            onTap: axis.onTap,
          ),
          const SizedBox(height: 8),
        ],
          FacetChip(
            label: label,
            count: count,
            isSelected: isSelected,
            onTap: onTap,
          ),
        ],
      );
}
