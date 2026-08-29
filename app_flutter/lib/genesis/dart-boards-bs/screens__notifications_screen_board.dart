// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__notifications_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/notifications_screen.g.dart';

class NotificationsScreenBoard extends ConsumerWidget {
  const NotificationsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationsScreenComposed(
      onTap: () => Navigator.of(context).push(NotifSettingsScreen.route()),
      fallback: '' /* TODO-לוח: String */,
      label: item,
      t: NotificationsScreenTokens(),
    );
  }
}
