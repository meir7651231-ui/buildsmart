// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__manager_copilot_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/input_bar.dart';
import '../dart-ui-bs/auto/typing.dart';
import '../dart-data-bs/auto/screens__manager_copilot_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ManagerCopilotScreenTokens {
  const ManagerCopilotScreenTokens();

}

class ManagerCopilotScreenComposed extends StatelessWidget {
  const ManagerCopilotScreenComposed({required this.onSend,VoidCallback, required this.controller, required this.enabled, required this.t, super.key});

  final VoidCallback onSend;
  final TextEditingController controller;
  final bool enabled;
  final ManagerCopilotScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Typing(
            
          ),
          InputBar(
            hintText: input_bar_hint_text,
            tooltip: input_bar_tooltip,
            controller: controller,
            enabled: enabled,
            onSend: onSend,
          ),
        ],
      );
}
