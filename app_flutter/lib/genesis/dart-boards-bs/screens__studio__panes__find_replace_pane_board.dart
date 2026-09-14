// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__studio__panes__find_replace_pane.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/studio/panes/find_replace_pane.dart';
import '../dart-screens-bs/studio_panes_find_replace_pane.g.dart';

class StudioPanesFindReplacePaneBoard extends ConsumerWidget {
  const StudioPanesFindReplacePaneBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudioPanesFindReplacePaneComposed(
      count: 0 /* TODO-לוח: int */,
      msg: 'הקלד טקסט לחיפוש על-פני הרכיבים שנערכו.',
      t: StudioPanesFindReplacePaneTokens(),
    );
  }
}
