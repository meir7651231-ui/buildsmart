// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__studio__panes__theme_pane.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/studio/panes/theme_pane.dart';
import '../dart-screens-bs/studio_panes_theme_pane.g.dart';

class StudioPanesThemePaneBoard extends ConsumerWidget {
  const StudioPanesThemePaneBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudioPanesThemePaneComposed(
      ratio: 0.0 /* TODO-לוח: double */,
      swatchItems: const [] /* TODO-לוח: List<SwatchItem> */,
      text: 'צבע מותג',
      t: StudioPanesThemePaneTokens(),
    );
  }
}
