// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__studio__panes__find_replace_pane.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dart-screens-bs/studio_panes_find_replace_pane.g.dart';

class StudioPanesFindReplacePaneBoard extends ConsumerWidget {
  const StudioPanesFindReplacePaneBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudioPanesFindReplacePaneComposed(
      count: hits.length,
      msg: 'הקלד טקסט לחיפוש על-פני הרכיבים שנערכו.',
      t: StudioPanesFindReplacePaneTokens(),
    );
  }
}
