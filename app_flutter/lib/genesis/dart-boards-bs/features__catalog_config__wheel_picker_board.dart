// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: features__catalog_config__wheel_picker.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/features/catalog_config/wheel_picker.dart';
import 'package:buildsmart/theme/tokens.dart';
import '../dart-screens-bs/catalog_config_wheel_picker.g.dart';

class CatalogConfigWheelPickerBoard extends ConsumerWidget {
  const CatalogConfigWheelPickerBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatalogConfigWheelPickerComposed(

      t: CatalogConfigWheelPickerTokens(),
    );
  }
}
