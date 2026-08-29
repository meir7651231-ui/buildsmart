// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__catalog_settings_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/home_content_reorder.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/recent_searches.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/catalog_settings_screen.g.dart';

class CatalogSettingsScreenBoard extends ConsumerWidget {
  const CatalogSettingsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatalogSettingsScreenComposed(
      onTap: () => Navigator.of(context).push(ProfileScreen.route()),
      onTap2: () => Navigator.of(
                context,
              ).push(LegalScreen.route(initialTab: LegalTab.privacy)),
      t: CatalogSettingsScreenTokens(),
    );
  }
}
