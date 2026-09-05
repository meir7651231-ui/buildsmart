// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__notif_settings_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 1.
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
      onTap: () {} /* TODO-לוח */,
      t: NotifSettingsScreenTokens(),
    );
  }
}
