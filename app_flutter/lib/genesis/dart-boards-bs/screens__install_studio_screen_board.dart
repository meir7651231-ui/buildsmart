// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__install_studio_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:buildsmart/logic/price_estimate.dart';
import 'package:buildsmart/screens/audit_screen.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:buildsmart/state/saved_projects.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/widgets/chain_diagram.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/install_studio_screen.g.dart';

class InstallStudioScreenBoard extends ConsumerWidget {
  const InstallStudioScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InstallStudioScreenComposed(
      onTap: () => Navigator.pop(context),
      broken: false /* TODO-לוח: bool */,
      flow: 0.0 /* TODO-לוח: double */,
      t: InstallStudioScreenTokens(from: const Color(0xFF223047) /* TODO-לוח: טוקן */, to: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
