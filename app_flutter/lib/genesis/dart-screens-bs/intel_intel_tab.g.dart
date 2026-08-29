// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__intel__intel_tab.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/intel_intro.dart';
import '../dart-data-bs/auto/screens__intel__intel_tab_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class IntelIntelTabTokens {
  const IntelIntelTabTokens();

}

class IntelIntelTabComposed extends StatelessWidget {
  const IntelIntelTabComposed({required this.t, super.key});



  final IntelIntelTabTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          IntelIntro(
            label: intel_intro_label,
            fallback: intel_intro_fallback,
            fallback2: intel_intro_fallback2,
          ),
        ],
      );
}
