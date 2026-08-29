// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__lipskey_brand_screen.dart (בנייה-חכמה main) · מחווט: 7 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/lipskey_brand_screen.g.dart';

class LipskeyBrandScreenBoard extends ConsumerWidget {
  const LipskeyBrandScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LipskeyBrandScreenComposed(
      onTap: section.onTap,
      catCount: catCount,
      emoji: section.emoji,
      name: section.name,
      prodCount: prodCount,
      totalCats: kLipskeySections
                    .fold(0, (s, sec) => s + sec.entries.length),
      totalProducts: kLipskeyCatalog.length,
      t: LipskeyBrandScreenTokens(),
    );
  }
}
