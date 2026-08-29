// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__store_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/quick_action.dart';
import '../dart-ui-bs/auto/sicha_sheet.dart';
import '../dart-ui-bs/auto/store_empty_state.dart';
import '../dart-ui-bs/auto/store_pill.dart';
import '../dart-ui-bs/auto/store_project_chip.dart';
import '../dart-ui-bs/auto/store_sheet_scaffold.dart';
import '../dart-ui-bs/auto/store_smart_qty_stepper.dart';
import '../dart-ui-bs/auto/store_step_btn.dart';
import '../dart-ui-bs/auto/store_summary_chip.dart';
import '../dart-ui-bs/auto/store_summary_line.dart';
import '../dart-ui-bs/auto/store_supplier_header.dart';
import '../dart-ui-bs/auto/summary_card.dart';
import '../dart-data-bs/auto/screens__store_screen_content.dart';
import '../dart-data-bs/screens__store_screen_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class StoreSupplierHeaderItem {
  const StoreSupplierHeaderItem({required this.name});
  final String name;
}

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class StoreProjectChipItem {
  const StoreProjectChipItem({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class StoreScreenTokens {
  const StoreScreenTokens({required this.color});
  final Color color;
}

class StoreScreenComposed extends StatelessWidget {
  const StoreScreenComposed({required this.onMinus, required this.onPlus, required this.onTap, required this.active, required this.badge, required this.bold, required this.children, required this.deliveryFee, required this.emoji, required this.icon, required this.label, required this.qty, required this.query, required this.storeProjectChipItems, required this.storeSupplierHeaderItems, required this.subtotal, required this.total, required this.value, required this.vat, required this.vatInclusive, required this.t, super.key});

  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onTap;
  final bool active;
  final int badge;
  final bool bold;
  final List<Widget> children;
  final int deliveryFee;
  final String emoji;
  final IconData icon;
  final String label;
  final int qty;
  final String query;
  final List<StoreProjectChipItem> storeProjectChipItems;
  final List<StoreSupplierHeaderItem> storeSupplierHeaderItems;
  final int subtotal;
  final int total;
  final String value;
  final int vat;
  final bool vatInclusive;
  final StoreScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          StoreSummaryChip(
            label: label,
            color: t.color,
          ),
          StorePill(
            label: label,
            active: active,
            onTap: onTap,
          ),
          QuickAction(
            icon: icon,
            label: label,
            onTap: onTap,
            badge: badge,
          ),
          SichaSheet(
            name: sicha_sheet_name,
            name2: sicha_sheet_name2,
            name3: sicha_sheet_name3,
            name4: sicha_sheet_name4,
            title: sicha_sheet_title,
            onTap: onTap,
          ),
          StoreSheetScaffold(
            title: summaryChips.title,
            emoji: emoji,
            children: children,
          ),
          StoreEmptyState(
            label: store_empty_state_label,
            label2: store_empty_state_label2,
            query: query,
          ),
          for (final entry in storeSupplierHeaderItems) ...[
          StoreSupplierHeader(
            fallback: store_supplier_header_fallback,
            name: entry.name,
          ),
          const SizedBox(height: 8),
        ],
          SummaryCard(
            label: summary_card_label,
            label2: summary_card_label2,
            label3: summary_card_label3,
            label4: summary_card_label4,
            value: summary_card_value,
            label5: summary_card_label5,
            subtotal: subtotal,
            vat: vat,
            deliveryFee: deliveryFee,
            total: total,
            vatInclusive: vatInclusive,
          ),
          for (final p in storeProjectChipItems) ...[
          StoreProjectChip(
            label: p.label,
            active: p.active,
            onTap: p.onTap,
          ),
          const SizedBox(height: 8),
        ],
          StoreSmartQtyStepper(
            message: store_smart_qty_stepper_message,
            message2: store_smart_qty_stepper_message2,
            label: store_smart_qty_stepper_label,
            label2: store_smart_qty_stepper_label2,
            qty: qty,
            onMinus: onMinus,
            onPlus: onPlus,
          ),
          StoreStepBtn(
            message: store_step_btn_message,
            message2: store_step_btn_message2,
            label: store_step_btn_label,
            label2: store_step_btn_label2,
            icon: icon,
            onTap: onTap,
          ),
          StoreSummaryLine(
            label: label,
            value: value,
            bold: bold,
          ),
        ],
      );
}
