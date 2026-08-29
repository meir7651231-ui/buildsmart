// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_settings_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/worker_settings_screen.g.dart';

class WorkerSettingsScreenBoard extends ConsumerWidget {
  const WorkerSettingsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerSettingsScreenComposed(
      onTap: () => Navigator.of(context).push(NotifSettingsScreen.route()),
      onTap2: () => Navigator.of(
                context,
              ).push(LegalScreen.route(initialTab: LegalTab.privacy)),
      fallback: '' /* TODO-לוח: String */,
      fallback2: '' /* TODO-לוח: String */,
      title: '' /* TODO-לוח: String */,
      t: WorkerSettingsScreenTokens(),
    );
  }
}
