// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__docs_readiness_gate.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/gate_button.dart';
import '../dart-ui-bs/auto/section_card.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class DocsReadinessGateTokens {
  const DocsReadinessGateTokens({required this.accent});
  final Color accent;
}

class DocsReadinessGateComposed extends StatelessWidget {
  const DocsReadinessGateComposed({required this.onPressed,VoidCallback, required this.emptyText, required this.label, required this.lines, required this.title, required this.t, super.key});

  final VoidCallback onPressed;
  final String? emptyText;
  final String label;
  final List<String> lines;
  final String title;
  final DocsReadinessGateTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SectionCard(
            title: title,
            lines: lines,
            accent: t.accent,
            emptyText: emptyText,
          ),
          GateButton(
            label: label,
            onPressed: onPressed,
          ),
        ],
      );
}
