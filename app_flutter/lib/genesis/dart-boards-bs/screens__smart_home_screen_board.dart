// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__smart_home_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/screens/stock_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/home_content_order.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/smart_home_screen.g.dart';

class SmartHomeScreenBoard extends ConsumerWidget {
  const SmartHomeScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmartHomeScreenComposed(
      child: null /* TODO-לוח: Widget */,
      emoji: '' /* TODO-לוח: String */,
      subtitle: '' /* TODO-לוח: String? */,
      title: '' /* TODO-לוח: String */,
      t: SmartHomeScreenTokens(),
    );
  }
}
