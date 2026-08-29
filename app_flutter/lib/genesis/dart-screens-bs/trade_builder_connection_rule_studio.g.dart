// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__trade_builder__connection_rule_studio.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/connector_tile.dart';
import '../dart-ui-bs/auto/empty_connectors.dart';
import '../dart-ui-bs/auto/rule_inspect_dialog.dart';
import '../dart-ui-bs/auto/section_header.dart';
import '../dart-ui-bs/auto/trade_builder_accessory_rule_editor_pill_button.dart';
import '../dart-data-bs/auto/screens__trade_builder__connection_rule_studio_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TradeBuilderConnectionRuleStudioTokens {
  const TradeBuilderConnectionRuleStudioTokens();

}

class TradeBuilderConnectionRuleStudioComposed extends StatelessWidget {
  const TradeBuilderConnectionRuleStudioComposed({required this.onDelete, required this.onPressed, required this.onPressed2, required this.onTap, required this.enabled, required this.label, required this.methodLabelHe, required this.nameHe, required this.title, required this.t, super.key});

  final VoidCallback onDelete;
  final VoidCallback onPressed;
  final VoidCallback onPressed2;
  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final String methodLabelHe;
  final String nameHe;
  final String title;
  final TradeBuilderConnectionRuleStudioTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          RuleInspectDialog(
            fallback: rule_inspect_dialog_fallback,
            fallback2: rule_inspect_dialog_fallback2,
            fallback3: rule_inspect_dialog_fallback3,
            methodLabelHe: methodLabelHe,
            onPressed: onPressed,
            onPressed2: onPressed2,
          ),
          SectionHeader(
            title,
          ),
          EmptyConnectors(
            fallback: empty_connectors_fallback,
          ),
          ConnectorTile(
            label: connector_tile_label,
            tooltip: connector_tile_tooltip,
            nameHe: nameHe,
            onDelete: onDelete,
          ),
          TradeBuilderAccessoryRuleEditorPillButton(
            label: label,
            onTap: onTap,
            enabled: enabled,
          ),
        ],
      );
}
