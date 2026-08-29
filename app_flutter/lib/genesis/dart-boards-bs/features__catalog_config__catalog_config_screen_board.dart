// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: features__catalog_config__catalog_config_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/features/catalog_config/catalog_config_screen.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/features/catalog_config/browse_model.dart';
import 'package:buildsmart/features/catalog_config/catalog_config_flags.dart';
import 'package:buildsmart/features/catalog_config/config_card.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/catalog_config_catalog_config_screen.g.dart';

class CatalogConfigCatalogConfigScreenBoard extends ConsumerStatefulWidget {
  const CatalogConfigCatalogConfigScreenBoard({super.key});

  @override
  ConsumerState<CatalogConfigCatalogConfigScreenBoard> createState() => _CatalogConfigCatalogConfigScreenBoardState();
}

class _CatalogConfigCatalogConfigScreenBoardState extends ConsumerState<CatalogConfigCatalogConfigScreenBoard> {
  int _matIdx = 0;

  @override
  Widget build(BuildContext context) {
    return CatalogConfigCatalogConfigScreenComposed(
      count: 0 /* TODO-לוח: int */,
      index: _matIdx,
      t: CatalogConfigCatalogConfigScreenTokens(),
    );
  }
}
