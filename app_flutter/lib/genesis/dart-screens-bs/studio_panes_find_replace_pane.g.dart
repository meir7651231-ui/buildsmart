// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__studio__panes__find_replace_pane.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/placeholder.dart';
import '../dart-ui-bs/auto/wide_warning.dart';
import '../dart-data-bs/auto/screens__studio__panes__find_replace_pane_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class StudioPanesFindReplacePaneTokens {
  const StudioPanesFindReplacePaneTokens();

}

class StudioPanesFindReplacePaneComposed extends StatelessWidget {
  const StudioPanesFindReplacePaneComposed({required this.count, required this.msg, required this.t, super.key});


  final int count;
  final String msg;
  final StudioPanesFindReplacePaneTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Placeholder(
            msg: msg,
          ),
          WideWarning(
            label: wide_warning_label,
            count: count,
          ),
        ],
      );
}
