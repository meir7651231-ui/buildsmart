// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__store_settings_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 12.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/services.dart';
import '../dart-screens-bs/store_settings_screen.g.dart';

class StoreSettingsScreenBoard extends ConsumerWidget {
  const StoreSettingsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StoreSettingsScreenComposed(
      onChanged: () {} /* TODO-לוח */,
      onTap: () => showToast(context, '$label — בבנייה'),
      buttonLabel: '' /* TODO-לוח: String */,
      children: const [] /* TODO-לוח: List<Widget> */,
      errorText: null /* TODO-לוח: String? */,
      fallback: '' /* TODO-לוח: String */,
      hint: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      subtitleNote: null /* TODO-לוח: String? */,
      underConstruction: false /* TODO-לוח: bool */,
      value: '' /* TODO-לוח: String */,
      value2: false /* TODO-לוח: bool */,
      value22: 0 /* TODO-לוח: int */,
      t: StoreSettingsScreenTokens(cursorColor: const Color(0xFF223047) /* TODO-לוח: טוקן */, fieldWidth: 12 /* TODO-לוח: טוקן */, fillColor: const Color(0xFF223047) /* TODO-לוח: טוקן */, hintColor: const Color(0xFF223047) /* TODO-לוח: טוקן */, inkColor: const Color(0xFF223047) /* TODO-לוח: טוקן */, labelColor: const Color(0xFF223047) /* TODO-לוח: טוקן */, mutedColor: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
