// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__notif_settings_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 9.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/notif_settings_screen.g.dart';

class NotifSettingsScreenBoard extends ConsumerWidget {
  const NotifSettingsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotifSettingsScreenComposed(
      onChanged: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      onTap2: () {} /* TODO-לוח */,
      onTap3: () {} /* TODO-לוח */,
      onTap4: () {} /* TODO-לוח */,
      label: '' /* TODO-לוח: String */,
      requiresServer: false /* TODO-לוח: bool */,
      underConstruction: false /* TODO-לוח: bool */,
      value: false /* TODO-לוח: bool */,
      t: NotifSettingsScreenTokens(),
    );
  }
}
