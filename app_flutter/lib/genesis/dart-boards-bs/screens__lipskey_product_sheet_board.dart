// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__lipskey_product_sheet.dart (בנייה-חכמה main) · מחווט: 14 · TODO: 3.
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
      onMarkDone: e.value.onMarkDone,
      body: e.value.body,
      body2: e.value.body2,
      emoji: '' /* TODO-לוח: String */,
      emphasized: e.value.emphasized,
      label: e.value.label,
      label2: e.value.label2,
      message: e.value.message,
      name: e.value.name,
      pickerOptionItems: options.map((opt) => PickerOptionItem(value: opt.$1, isSelected: opt.$2.sku == currentSku, onTap: () => onSelect(opt.$2))).toList(),
      qty: _qty,
      stageRowItems: .entries.map((e) => StageRowItem(onTap: () => setState(() =>
                                _activeStage =
                                    _activeStage == e.key ? null : e.key))).toList(),
      subtitle: '' /* TODO-לוח: String? */,
      tag: e.value.tag,
      text: 'אין קבוצה',
      title2: e.value.title2,
      t: LipskeyProductSheetTokens(),
    );
  }
}
