// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__finder_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/repositories/catalog_local.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/finder_screen.g.dart';

class FinderScreenBoard extends ConsumerWidget {
  const FinderScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FinderScreenComposed(
      children: const [] /* TODO-לוח: List<Widget> */,
      t: FinderScreenTokens(),
    );
  }
}
