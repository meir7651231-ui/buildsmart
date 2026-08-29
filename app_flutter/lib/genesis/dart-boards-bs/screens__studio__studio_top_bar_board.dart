// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__studio__studio_top_bar.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dart-screens-bs/studio_studio_top_bar.g.dart';

class StudioStudioTopBarBoard extends ConsumerWidget {
  const StudioStudioTopBarBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudioStudioTopBarComposed(
      count: count,
      t: StudioStudioTopBarTokens(),
    );
  }
}
