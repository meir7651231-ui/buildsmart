// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__store_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 18.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:buildsmart/screens/finance_hub_sheets.dart';
import 'package:buildsmart/screens/order_notif_sheet.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/cart_lists_state.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/intel/intel_bus.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/share_seam.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/state/telemetry.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_field.dart';
import 'package:buildsmart/widgets/smart_input/nav/category_suggestion_strip.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/store_screen.g.dart';

class StoreScreenBoard extends ConsumerWidget {
  const StoreScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StoreScreenComposed(
      onMinus: () {} /* TODO-לוח */,
      onPlus: () {} /* TODO-לוח */,
      onTap: () {
                    Navigator.pop(context);
                    showToast(context, 'שיחה עם ${c.name} — בבנייה');
                  },
      active: false /* TODO-לוח: bool */,
      badge: 0 /* TODO-לוח: int */,
      bold: false /* TODO-לוח: bool */,
      children: const [] /* TODO-לוח: List<Widget> */,
      deliveryFee: 0 /* TODO-לוח: int */,
      emoji: '' /* TODO-לוח: String */,
      icon: Icons.favorite_border,
      label: '' /* TODO-לוח: String */,
      qty: 0 /* TODO-לוח: int */,
      query: '' /* TODO-לוח: String */,
      storeProjectChipItems: const [] /* TODO-לוח: List<StoreProjectChipItem> */,
      storeSupplierHeaderItems: const [] /* TODO-לוח: List<StoreSupplierHeaderItem> */,
      subtotal: 0 /* TODO-לוח: int */,
      total: 0 /* TODO-לוח: int */,
      value: '' /* TODO-לוח: String */,
      vat: 0 /* TODO-לוח: int */,
      vatInclusive: false /* TODO-לוח: bool */,
      t: StoreScreenTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
