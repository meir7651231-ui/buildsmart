// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__lipskey_brand_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/lipskey_brand_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import '../dart-screens-bs/lipskey_brand_screen.g.dart';

class LipskeyBrandScreenBoard extends ConsumerWidget {
  const LipskeyBrandScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LipskeyBrandScreenComposed(
      onTap: () {} /* TODO-לוח */,
      catCount: 0 /* TODO-לוח: int */,
      emoji: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      prodCount: 0 /* TODO-לוח: int */,
      totalCats: kLipskeySections
                    .fold(0, (s, sec) => s + sec.entries.length),
      totalProducts: kLipskeyCatalog.length,
      t: LipskeyBrandScreenTokens(),
    );
  }
}
