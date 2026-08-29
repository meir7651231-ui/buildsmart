// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_attendance_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 8.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_hr.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/courier_attendance_screen.g.dart';

class CourierAttendanceScreenBoard extends ConsumerWidget {
  const CourierAttendanceScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CourierAttendanceScreenComposed(
      onPressed: () {} /* TODO-לוח */,
      date: '' /* TODO-לוח: String */,
      enabled: false /* TODO-לוח: bool */,
      header: true,
      inText: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      outText: '' /* TODO-לוח: String */,
      totalText: '' /* TODO-לוח: String */,
      value: '' /* TODO-לוח: String */,
      t: CourierAttendanceScreenTokens(),
    );
  }
}
