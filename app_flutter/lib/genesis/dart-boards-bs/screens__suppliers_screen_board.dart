// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__suppliers_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/suppliers_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_brand_screen.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/suppliers_screen.g.dart';

class SuppliersScreenBoard extends ConsumerWidget {
  const SuppliersScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SuppliersScreenComposed(
      onTap: () {} /* TODO-לוח */,
      emoji: '' /* TODO-לוח: String */,
      subtitle: '' /* TODO-לוח: String */,
      title: '' /* TODO-לוח: String */,
      t: SuppliersScreenTokens(),
    );
  }
}
