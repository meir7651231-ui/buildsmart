// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__studio__panes__theme_pane.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dart-screens-bs/studio_panes_theme_pane.g.dart';

class StudioPanesThemePaneBoard extends ConsumerWidget {
  const StudioPanesThemePaneBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudioPanesThemePaneComposed(
      swatchItems: _swatches.map((c) => SwatchItem(color: c, selected: c.toARGB32() == cfg.brand.toARGB32(), onTap: () => notifier.setThemeDraft(cfg.copyWith(brand: c)))).toList(),
      text: 'צבע מותג',
      t: StudioPanesThemePaneTokens(),
    );
  }
}
