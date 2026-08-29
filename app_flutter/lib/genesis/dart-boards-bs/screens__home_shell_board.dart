// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__home_shell.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/consent_modal.dart';
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/onboarding_screen.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/role_request_sheet.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:buildsmart/screens/updates_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/directory.dart';
import 'package:buildsmart/state/help_mode.dart';
import 'package:buildsmart/state/intel/screen_view.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/org_gates.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/version.g.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/home_shell.g.dart';

class HomeShellBoard extends ConsumerWidget {
  const HomeShellBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomeShellComposed(
      cfgId: '' /* TODO-לוח: String? */,
      count: unreadCount,
      emoji: '' /* TODO-לוח: String */,
      icon: currentIndex == 2
                          ? Icons.notifications
                          : Icons.notifications_outlined,
      label: '' /* TODO-לוח: String */,
      t: HomeShellTokens(),
    );
  }
}
