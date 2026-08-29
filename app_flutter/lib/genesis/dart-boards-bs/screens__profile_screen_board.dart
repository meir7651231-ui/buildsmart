// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__profile_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/login_sheet.dart';
import 'package:buildsmart/screens/rewards_hub_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/role_request_sheet.dart';
import 'package:buildsmart/screens/role_requests_inbox_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/role_requests.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/profile_screen.g.dart';

class ProfileScreenBoard extends ConsumerWidget {
  const ProfileScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileScreenComposed(
      onTap: () {} /* TODO-לוח */,
      validator: (_) {} /* TODO-לוח */,
      controller: TextEditingController() /* TODO-לוח: TextEditingController */,
      label: '' /* TODO-לוח: String */,
      number: false /* TODO-לוח: bool */,
      text: 'פרטים אישיים',
      t: ProfileScreenTokens(),
    );
  }
}
