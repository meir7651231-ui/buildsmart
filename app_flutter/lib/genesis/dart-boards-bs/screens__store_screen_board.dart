// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__store_screen.dart (בנייה-חכמה main) · מחווט: 17 · TODO: 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      active: section == StoreSection.all,
      badge: favItems.length,
      bold: false /* TODO-לוח: bool */,
      children: items
              .map(
                (item) => _SheetTile(
                  emoji: item.emoji,
                  label: item.title,
                  onTap: () {
                    Navigator.pop(context);
                    final svcIdx = _kServiceByEmoji[item.emoji];
                    if (svcIdx != null) {
                      _ServicesGrid._openSheet(context, svcIdx);
                    } else if (item.emoji == '🛒') {
                      ref.read(storeSectionProvider.notifier).state =
                          StoreSection.cart;
                    } else if (item.emoji == '📦') {
                      ref.read(storeSectionProvider.notifier).state =
                          StoreSection.orders;
                    }
                  },
                ),
              )
              .toList(),
      deliveryFee: deliveryFee,
      emoji: items
              .map(
                (item) => _SheetTile(
                  emoji: item.emoji,
                  label: item.title,
                  onTap: () {
                    Navigator.pop(context);
                    final svcIdx = _kServiceByEmoji[item.emoji];
                    if (svcIdx != null) {
                      _ServicesGrid._openSheet(context, svcIdx);
                    } else if (item.emoji == '🛒') {
                      ref.read(storeSectionProvider.notifier).state =
                          StoreSection.cart;
                    } else if (item.emoji == '📦') {
                      ref.read(storeSectionProvider.notifier).state =
                          StoreSection.orders;
                    }
                  },
                ),
              )
              .toList().emoji,
      icon: Icons.favorite_border,
      label: vatInclusive ? 'סכום ביניים (ללא מע"מ)' : 'סכום ביניים',
      qty: line.productQty,
      query: query,
      storeProjectChipItems: projects.map((p) => StoreProjectChipItem(label: p, active: p == selected, onTap: () => ref.read(cartProjectProvider.notifier).state = p)).toList(),
      storeSupplierHeaderItems: grouped.entries.map((entry) => StoreSupplierHeaderItem(name: entry.key)).toList(),
      subtotal: subtotal,
      total: total,
      value: _price(vatInclusive ? subtotal - vat : subtotal),
      vat: vat,
      vatInclusive: vatInclusive,
      t: StoreScreenTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
