// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__lipskey_product_sheet.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 16.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/score_band.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/features/card_keyboard/hop_stack.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/services.dart';
import '../dart-screens-bs/lipskey_product_sheet.g.dart';

class LipskeyProductSheetBoard extends ConsumerWidget {
  const LipskeyProductSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LipskeyProductSheetComposed(
      onChanged: () {} /* TODO-לוח */,
      onMarkDone: () {} /* TODO-לוח */,
      body: '' /* TODO-לוח: String */,
      body2: '' /* TODO-לוח: String */,
      emoji: '' /* TODO-לוח: String */,
      emphasized: false /* TODO-לוח: bool */,
      label: '' /* TODO-לוח: String */,
      label2: '' /* TODO-לוח: String */,
      message: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      pickerOptionItems: const [] /* TODO-לוח: List<PickerOptionItem> */,
      qty: 0 /* TODO-לוח: int */,
      stageRowItems: const [] /* TODO-לוח: List<StageRowItem> */,
      subtitle: '' /* TODO-לוח: String? */,
      tag: '' /* TODO-לוח: String */,
      text: 'אין קבוצה',
      title2: '' /* TODO-לוח: String */,
      t: LipskeyProductSheetTokens(),
    );
  }
}
