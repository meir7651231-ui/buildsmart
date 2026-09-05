// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_certs_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/courier_certs_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_hr.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/courier_certs_screen.g.dart';

class CourierCertsScreenBoard extends ConsumerWidget {
  const CourierCertsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtl = TextEditingController();
    return CourierCertsScreenComposed(
      presetChipItems: const [] /* TODO-לוח: List<PresetChipItem> */,
      t: CourierCertsScreenTokens(),
    );
  }
}
