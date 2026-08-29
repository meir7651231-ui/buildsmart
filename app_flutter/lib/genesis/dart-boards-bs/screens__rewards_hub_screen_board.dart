// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__rewards_hub_screen.dart (בנייה-חכמה main) · מחווט: 3 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/services.dart';
import '../dart-screens-bs/rewards_hub_screen.g.dart';

class RewardsHubScreenBoard extends ConsumerWidget {
  const RewardsHubScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RewardsHubScreenComposed(
      coins: rw.coins,
      finTileItems: _tiles.map((t) => FinTileItem(ic: t.ic, title: t.t, sub: t.id == 'challenges'
                        ? '${rw.challenges.length} פעילים'
                        : t.s, onTap: () => Navigator.of(context)
                        .push(_RewardsFeatureScreen.route(t.id)))).toList(),
      ic: '' /* TODO-לוח: String */,
      sub: '' /* TODO-לוח: String */,
      title: orgTerm(ref, 'brand.club', AppBrand.club),
      t: RewardsHubScreenTokens(),
    );
  }
}
