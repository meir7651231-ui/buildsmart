// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__docs_readiness_gate.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/gate_button.dart';
import '../dart-ui-bs/auto/section_card.dart';
import '../dart-data-bs/auto/screens__docs_readiness_gate_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class DocsReadinessGateTokens {
  const DocsReadinessGateTokens({required this.accent});
  final Color accent;
}

class DocsReadinessGateComposed extends StatelessWidget {
  const DocsReadinessGateComposed({required this.onPressed, required this.lines, required this.t, super.key});

  final VoidCallback onPressed;
  final List<String> lines;
  final DocsReadinessGateTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SectionCard(
            title: section_card_title,
            lines: lines,
            accent: t.accent,
            emptyText: section_card_empty_text,
          ),
          GateButton(
            label: gate_button_label,
            onPressed: onPressed,
          ),
        ],
      );
}
