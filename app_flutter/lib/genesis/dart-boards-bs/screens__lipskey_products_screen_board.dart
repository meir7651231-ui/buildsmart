// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__lipskey_products_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 10.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/data/catalog_lens.dart';
import 'package:buildsmart/data/chip_hierarchy.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:buildsmart/screens/lens_selector_row.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/state/catalog_lens_state.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/services.dart';
import '../dart-screens-bs/lipskey_products_screen.g.dart';

class LipskeyProductsScreenBoard extends ConsumerWidget {
  const LipskeyProductsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LipskeyProductsScreenComposed(
      onTap: () {} /* TODO-לוח */,
      count: 0 /* TODO-לוח: int */,
      icon: Icons.remove,
      isOpen: false /* TODO-לוח: bool */,
      label: '' /* TODO-לוח: String */,
      label2: '' /* TODO-לוח: String */,
      message: '' /* TODO-לוח: String */,
      message2: '' /* TODO-לוח: String */,
      smartTree: false /* TODO-לוח: bool */,
      title: '' /* TODO-לוח: String */,
      word: '' /* TODO-לוח: String */,
      t: LipskeyProductsScreenTokens(),
    );
  }
}
