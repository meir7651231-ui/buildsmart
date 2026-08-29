// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_settings_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/courier_settings_screen.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/courier_settings_screen.g.dart';

class CourierSettingsScreenBoard extends ConsumerWidget {
  const CourierSettingsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CourierSettingsScreenComposed(
      onTap: () => Navigator.of(
                  context,
                ).push(LegalScreen.route(initialTab: LegalTab.terms)),
      onTap2: () => Navigator.of(
                  context,
                ).push(LegalScreen.route(initialTab: LegalTab.privacy)),
      t: CourierSettingsScreenTokens(),
    );
  }
}
